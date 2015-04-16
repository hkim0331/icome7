#!/usr/bin/env jruby
# coding: utf-8
# use swing. so jruby.

require 'drb'
require 'socket'
require 'date'

VERSION = "0.8.1"
UPDATE  = "2015-04-16"

DEBUG = (ENV['DEBUG'] || false)
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
PREFIX = {'j' => '10',
          'k' => '11',
          'm' => '12',
          'n' => '13',
          'o' => '14',
          'p' => '15'}
WDAY = %w{sun mon tue wed thr fri sat}
POLLING_INTERVAL = 3

def debug(s)
  STDERR.puts "debug: " + s if DEBUG
end

def uid2sid(uid)
  PREFIX[uid[0]] + uid[1,6]
rescue
  uid
end

def uhour(time)
  return 1 if "08:50:00" <= time and time <= "10:20:00"
  return 2 if "10:30:00" <= time and time <= "12:00:00"
  return 3 if "13:00:00" <= time and time <= "14:30:00"
  return 4 if "14:40:00" <= time and time <= "16:10:00"
  return 5 if "16:20:00" <= time and time <= "17:50:00"
  return 0
end

class UI
  include Java
  include_package 'java.awt'
  include_package 'javax.swing'

  def initialize(icome)
    @icome = icome
    frame = JFrame.new('icome7')
    frame.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout::Y_AXIS))

    button = JButton.new('出席')
    button.add_action_listener do |e|
      @icome.attend
    end
    panel.add(button)

    button = JButton.new('記録')
    button.add_action_listener do |e|
      @icome.show
    end
    panel.add(button)

    button = JButton.new('提出物')
    button.add_action_listener do |e|
      @icome.status
    end
    panel.add(button)

    # quit button in development only.
    unless ENV['UCOME']
      button = JButton.new('Quit')
      button.add_action_listener do |e|
        @icome.quit
      end
      panel.add(button)
    end

    frame.add(panel)
    frame.pack
    frame.set_visible(true)
  end

  def dialog(s)
    JOptionPane.showMessageDialog(
      nil, "<html>#{s}</html>", 'icome', JOptionPane::INFORMATION_MESSAGE)
  end

  def query?(s)
    ans = JOptionPane.showConfirmDialog(
      nil, "<html>#{s}</html>", 'icome', JOptionPane::YES_NO_OPTION)
    ans == JOptionPane::YES_OPTION
  end
end

class Icome
  attr_accessor :interval

  def initialize(ucome)
    @ucome = ucome
    @sid = uid2sid(ENV['USER'])
    @ip = IPSocket::getaddress(Socket::gethostname)
    @interval = 5
    @icome7 = File.expand_path("~/.icome7")
    @record = nil
    Dir.mkdir(@icome7) unless Dir.exists?(@icome7)
  end

  def setup_ui
    @ui = UI.new(self)
  end

  def attend
    now = Time.now
    today, time, zone = now.to_s.split
    u_hour = WDAY[now.wday] + uhour(time).to_s
    term = this_term()
    db = "#{@icome7}/#{term}-#{u_hour}"

    unless DEBUG
      unless u_hour =~ /(wed1)|(wed2)/
        self.dialog("授業時間じゃありません。")
        return
      end
    end

    records = @ucome.find(@sid, u_hour, term)
    debug "records: #{records}, #{@sid}, #{u_hour}, #{term}"
    if records
      if records.include?(today)
        @ui.dialog("出席記録は一回の授業にひとつで十分。")
        return
      end
      @ucome.update(@sid, today, u_hour, term)
      @ui.dialog("出席を記録しました。<br>"+
                 "学生番号:#{@sid}<br>"+
                 "端末番号:#{@ip.split(/\./)[3]}")
    else
      if @ui.query?("#{u_hour} を受講しますか？")
        @ucome.insert(@sid, u_hour, term)
        memo(db, today)
      end
    end
  end

  def this_term()
    now = Time.now
    t = "b"
    if (4 <= now.month and now.month < 10)
      t = "a"
    end
    "#{t}#{now.year}"
  end

  def show
    #FIXME
    uhours = find_uhours()
    if uhours.empty?
      @ui.dialog("記録がありません。")
      return
    end
    if uhours.count == 1
      uhour = uhours[0]
    else
      @ui.dialog("複数の授業を取っているようです。")
      return
      #raise "not implemented: if he takes two or more classes."
    end
    record = @ucome.find(@sid, uhour, this_term())
    if record
      @ui.dialog(record.sort.join('<br>'))
    else
      @ui.dialog("記録がありません。変ですね。")
    end
  end

  def quit
    java.lang.System.exit(0) unless ENV['UCOME']
  end

  def find_uhours
    Dir.entries(@icome7).
      find_all{|x| x =~ /^[ab]/}.
      collect{|x| x.split(/-/)[1]}
  end

  def first_time?(u_hour)
    not File.exist?(File.join(@icome7,uhour))
  end

  def checked?(db, today)
    debug "#{__method__} db: #{db}, today: #{today}"
    return false unless File.exists?(db)
    r = %r{#{today}}
    File.foreach(db) do |line|
      debug "line: #{line}"
      return true if line =~ r
    end
    false
  end

  def memo(db,today)
    File.open(db,"a") do |fp|
      fp.puts today
    end
  end

  def dialog(s)
    @ui.dialog(s)
  end

  def echo(s)
    @ucome.echo(s)
  end

  def upload(local)
    it = File.join(ENV['HOME'], local)
    debug "#{__method__} #{it}, #{File.basename(local)}, #{File.open(it).read}"
    @ucome.upload(@sid, File.basename(local), File.open(it).read)
  end

  def status()
    msg = @ucome.status(@sid)
    @ui.dialog(msg.join("<p>"))
  end

  def download(remote)
    debug "#{__method__} #{remote}"
  end

  # jruby では無理。
  def exec(command)
    puts "無理。"
  end
end

#
# main starts here
#
DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)
icome = Icome.new(ucome)
icome.setup_ui

#debug ucome.echo("hello, ucome.")
#debug icome.echo("hello, ucome via icome.")

# polling admin commands.
next_cmd = 1
Thread.new do
  while true do
    cmd = ucome.fetch(next_cmd)
    if cmd.nil?
      sleep POLLING_INTERVAL
      next
    end
    debug "cmd: #{cmd}"
    case cmd
    when /^display (.*)$/
      icome.dialog($1)
    when /^upload\s+(\S+)/
      icome.upload($1)
    when /^download\s+(\S+)/
      icome.download($1)
    when /^exec/
      icome.exec(cmd)
    else
      puts "error: #{cmd}"
    end
    next_cmd += 1
  end
end

DRb.thread.join
