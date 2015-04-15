#!/usr/bin/env jruby
# coding: utf-8
# use swing. so jruby.

require 'drb'
require 'socket'
require 'date'

DEBUG = true
VERSION = "0.6.1"
UPDATE  = "2015-04-13"
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

def exists_icome?()
  IO.popen("ps ax | grep [i]come") do |p|
    lines = p.readlines
    return !lines.empty?
  end
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

    # only show quit button in development.
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

  # attend を打った時間をチェックする。
  def attend
    now = Time.now
    today, time, zone = now.to_s.split
    u_hour = WDAY[now.wday] + uhour(time).to_s
    term = this_term()
    db = "#{@icome7}/#{term}-#{u_hour}"

    # FIXME, a2015 special.
    # コマンド引数にスイッチを取るようにするか？
    unless DEBUG
      unless u_hour =~ /(wed1)|(wed2)/
        @ui.dialog("授業時間じゃありません。")
        return
      end
    end

    # first time?
    unless File.exists?(db)
      return unless @ui.query?("#{u_hour} を受講しますか？")
    end

    if already_checked?(db, today)
      @ui.dialog("出席記録は一回の授業にひとつで十分。")
      return
    else
      @ucome.insert(@sid, u_hour, term)
    end

    @ucome.update(@sid, today, u_hour, term)
    log(db, today)
    @record = nil
    @ui.dialog("出席を記録しました。<br>"+
               "学生番号:#{@sid}<br>"+
               "端末番号:#{@ip.split(/\./)[3]}")
  end

  def this_term()
    now = Time.now
    t = "b"
    if (4 <= now.month and now.month < 10)
      t = "a"
    end
    "#{t}#{now.year}"
  end

  # 答えを @record にキャッシュする。
  def show
    uhours = find_uhours()
    return if uhours.empty?
    if uhours.count == 1
      uhour = uhours[0]
    else
      raise "not implemented: if he takes two or more classes."
    end
    debug "#{__method__}: #{@sid} #{uhour}"
    @record = @ucome.find(@sid, uhour, this_term()) if @record.nil?
    @ui.dialog(@record.sort.join('<br>'))
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

  def already_checked?(db, today)
    debug "db: #{db}, today: #{today}"
    return false unless File.exists?(db)
    r = %r{#{today}}
    File.foreach(db) do |line|
      debug "line: #{line}"
      return true if line =~ r
    end
    false
  end

  def log(db,today)
    File.open(db,"a") do |fp|
      fp.puts today
    end
  end

  def echo(s)
    @ucome.echo(s)
  end
end

#
# main starts here
#
if exists_icome?()
  debug "another icome process exists."
  return
end
DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)
icome = Icome.new(ucome)
icome.setup_ui

#debug ucome.echo("hello, ucome.")
#debug icome.echo("hello, ucome via icome.")

# polling admin commands.
Thread.new do
  while true do
    sleep POLLING_INTERVAL
    #    debug icome.echo("hello, ucome via icome.")
  end
end

DRb.thread.join
