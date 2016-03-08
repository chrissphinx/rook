require 'redis'

class Nest
  include Cinch::Plugin
  hook :pre, :for => [:match], :method => lambda {|m| m.user.nick != "fish"}

  def initialize *args
    super
    @redis = Redis.new port: config[:port], password: config[:password]
  end
  set :prefix, /^@/
  set :suffix, /\z/

  match /set ([a-z][a-zA-Z0-9_]+)\s(.+)/, method: :set
  def set m, k, v
    m.reply @redis.set k, v
  end

  match /get ([a-z][a-zA-Z0-9_]+)/, method: :get
  def get m, k
    m.reply @redis.get k
  end

  match /keys (.+)/, method: :search
  def search m, s
    m.reply @redis.keys(s).join(", ")
  end

  match /keys/, method: :keys
  def keys m
    m.reply @redis.keys().join(", ")
  end

  match /del (.+)/, method: :del
  def del m, ks
    m.reply @redis.del(*ks.split(" "))
  end

  def shutdown
    @redis.shutdown
  end
end

