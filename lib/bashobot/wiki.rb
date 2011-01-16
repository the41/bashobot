require 'cinch'
require 'mechanize'
require 'uri'

class Wiki
  include Cinch::Plugin
  prefix '!wiki'
  suffix ''
  react_on :message
  
  match /\s*(.*)/i, method: :find_wiki_page

  timer 86400, method: :refresh_wiki
  
  def wiki
    synchronize(:wiki) do
      @wiki ||= Mechanize.new.get("http://wiki.basho.com/")
    end
  end         
  
  def find_wiki_page(message, match)
    words = match.split(/\W+/).map {|w| Regexp.new(w.downcase, Regexp::IGNORECASE) }
    (wiki / "#sidebar" / "a").each do |link|
      if words.any? {|w| link.inner_html =~ w }
        message.reply "[Riak wiki] #{URI.join('http://wiki.basho.com', link['href'])}"
      end
    end
  end

  def refresh_wiki
    synchronize(:wiki) do
      @wiki = Mechanize.new.get("http://wiki.basho.com/")
    end
  end
end