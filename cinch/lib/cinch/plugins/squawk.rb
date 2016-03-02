require 'markovchat'

class Squawk
  include Cinch::Plugin

  def initialize *args
    super
    @mark = MarkovChat.new('squawk.db')
    if (File.exists?('squawk.db'))
      @mark.load
    end
    @anger = 0
    @silenced = false
    @silenced_at = nil
    @last = Time.now
  end
  set :prefix, /^@/
  set :suffix, /$/

  match /squawk reload/, method: :reload
  def reload m
    @mark = MarkovChat.new('squawk.db')
    File.open('raven.txt', 'r') do |f|
      f.each_line do |l|
        @mark.add_sentence(l)
      end
    end
    @mark.background_save
  end

  match /squawk add ([^\z]+)/, method: :add
  def add m, l
    @mark.add_sentence(l)
    @mark.background_save
    File.open('raven.txt', 'a') { |f| f.puts(l) }
  end

  match /squawk/, method: :squawk
  def squawk m
    if (@silenced_at != nil && ((Time.now - @silenced_at) / 100).to_i > @anger)
      @silenced = false
      @silenced_at = nil
      @anger = 0
    else
      @anger -= ((Time.now - @last) / 100).to_i
      if (@anger < 0) then @anger = 0 end
    end

    if (@silenced == false && @anger > 3)
      m.reply m.user.nick.upcase + ": FUCK OFF, I'M DONE LISTENING TO YOU."
      @silenced = true
      @silenced_at = Time.now
      return
    end

    if (!@silenced)
      n = (m.channel.users.keys.select { |u| u.nick != 'rook' }).sample.nick.upcase
      m.reply @mark.chat % n
      @last = Time.now
      @anger += 1
    end

    puts "@anger: " + @anger.to_s
  end

  def save
    @mark.save
  end
end
