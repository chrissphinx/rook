class Identify
  include Cinch::Plugin

  listen_to :connect, method: :identify
  def identify(m)
    if config[:username]
      User("nickserv").send("identify %s %s" % [config[:username], config[:password]])
    else
      User("nickserv").send("identify %s" % [config[:password]])
    end
  end

  match(/^Password accepted - you are now recognized\./, use_prefix: false, use_suffix: false, react_on: :private, method: :identified)
  def identified(m)
    if m.user == User("nickserv") && config[:type] == :nickserv
      debug "Identified with NickServ"
      @bot.handlers.dispatch :identified, m
    end
  end
end

