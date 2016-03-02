require 'mediawiki_api'

class Bough
  include Cinch::Plugin

  def initialize *args
    super
    @wiki = MediawikiApi::Client.new 'https://cclub.cs.wmich.edu/w/api.php'
    @wiki.log_in config[:username], config[:password]
    @nest = @bot.plugins.find {|p| /Nest/ =~ p.class.name}
  end
  set :prefix, /^@/
  set :suffix, /$/

  def logout
    @wiki.action :logout, token_type: false
  end
end

