#!/usr/bin/env jruby
# coding: utf-8
# use swing. so jruby.
# main で初期化している。
# $debug = false
#
# BUG: 年が変わっても年度は一緒。2016-01-07

require 'date'
require 'drb'
require 'socket'

VERSION = "1.2"
UPDATE  = "2016-05-27"
WDAY = %w{ sun mon tue wed thr fri sat }
INTERVAL = 5
MAX_UPLOAD_SIZE  = 5000000

PREFIX = {'j' => '10', 'k' => '11', 'm' => '12', 'n' => '13',
          'o' => '14', 'p' => '15', 'q' => '16' }

def uid2sid(uid)
  PREFIX[uid[0]] + uid[1,6]
rescue
  uid
end

def debug(s)
  STDERR.puts "debug: " + s if $debug
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
    frame.set_undecorated(true)
#    frame.set_default_close_operation(JFrame::DO_NOTHING_ON_CLOSE)
    panel = JPanel.new
    panel.set_layout(BoxLayout.new(panel, BoxLayout::Y_AXIS))

    button = JButton.new('出席を記録する')
    button.add_action_listener do |e|
      @icome.attend
    end
    panel.add(button)

    button = JButton.new('過去記録を見る')
    button.add_action_listener do |e|
      @icome.show
    end
    panel.add(button)

    # 2016-05-20, gtypist
    button = JButton.new('5/18 gtypist')
    button.add_action_listener do |e|
      @icome.gtypist('May 18')
    end
    panel.add(button)

    # 2016-05-20, gtypist all
    # off by gtypist_stage, 2016-05-30
    # button = JButton.new('gtypist all')
    # button.add_action_listener do |e|
    #   @icome.gtypist_all()
    # end
    # panel.add(button)

    # 2016-05-20, gtypist-stage
    %w{Q1 Q2 Q3 Q4 Q5}.each do |s|
      button = JButton.new("gtypist #{s}")
      button.add_action_listener do |e|
        @icome.gtypist_stage(s)
      end
      panel.add(button)
    end

    # 2016-05
    # 2016-04-12, off.
    # button = JButton.new('個人課題')
    # button.add_action_listener do |e|
    #   @icome.status
    # end
    # panel.add(button)
    # #
    # # FIXME, 0.21 以降でやるべし。
    # button = JButton.new('グループ課題')
    # button.add_action_listener do |e|
    #   dialog("授業資料の「グループ課題提出」から提出してください。")
    # end
    # panel.add(button)

    # quit button in development only.
    if $debug
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
    JOptionPane.showMessageDialog(nil, "<html>#{s}</html>", "icome",
                                  JOptionPane::INFORMATION_MESSAGE)
  end

  def query?(s)
    ans = JOptionPane.showConfirmDialog(nil, "<html>#{s}</html>", "icome",
                                        JOptionPane::YES_NO_OPTION)
    ans == JOptionPane::YES_OPTION
  end

  def option_dialog(ss, query)
    ans = JOptionPane.showOptionDialog(nil,"<html>#{query}</html>", "icome",
                                       JOptionPane::YES_NO_OPTION,
                                       JOptionPane::QUESTION_MESSAGE,
                                       nil, ss, ss[0])
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
    Dir.mkdir(@icome7) unless Dir.exist?(@icome7)
  end

  def setup_ui
    @ui = UI.new(self)
  end

  def gtypist(pat)
    ret=[]
    File.foreach("#{ENV['HOME']}/.gtypist") do |line|
      if line =~ /#{pat}/
        ret.push "#{line.chomp}<br>"
      end
    end
    @ui.dialog(ret.join)
  end

  def gtypist_all()
    ret=[]
    IO.popen("/home/t/hkimura/bin/gtypist-check.rb") do |p|
      ret = p.readlines.map{|l| l.chomp}
    end
    @ui.dialog(ret.join('<br>'))
  end

  def gtypist_stage(s)
    ret=[]
    len = {'Q1' => 8, 'Q2' =>  8, 'Q3' => 10, 'Q4' => 11, 'Q5' => 9}
    IO.popen("/home/t/hkimura/bin/gtypist-check.rb") do |p|
      ret = p.readlines.map{|l| l.chomp}.find_all{|l| l =~ /#{s}/}
    end
    greeting = ""
    if ret.length >= len[s]
      greeting = "<p style='color:red;'>CLEAR!</p>"
    elsif ret.length == 0
      greeting = "<p style='color:blue;'>やっとかないと平常点つかない。</p>"
    end
    @ui.dialog(ret.join('<br>') + greeting)
  end

  def attend
    now = Time.now
    today, time, zone = now.to_s.split
    u_hour = WDAY[now.wday] + uhour(time).to_s
    term = this_term()
    db = "#{@icome7}/#{term}-#{u_hour}"

    unless $debug
      # 後期
      # unless u_hour =~ /(tue2)|(tue4)|(thr1)|(thr4)/
      # 前期
      unless u_hour =~ /(wed1)|(wed2)/
        self.dialog("授業時間じゃありません。")
        return
      end
    end

    records = @ucome.find(@sid, u_hour, term)
    debug "records:#{records},#{@sid},#{u_hour},#{term}"
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

  # FIXED: 2016-01-07
  def this_term()
    now = Time.now()
    t = "b"
    if (4 <= now.month and now.month < 10)
      t = "a"
    end
    year = now.year()
    if (now.month < 4)
      year -= 1
    end
    "#{t}#{year}"
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
      ret = @ui.option_dialog(uhours,
        "複数のクラスを受講しているようです。")
      return if ret < 0
      uhour = uhours[ret]
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

  # FIXME: query to db?
  def find_uhours
    Dir.entries(@icome7).
      find_all{|x| x =~ /^[ab]/}.collect{|x| x.split(/-/)[1]}
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

  def cowsay(s)
    system("xcowsay --at=400,400 #{s}")
  end

  def dialog(s)
    @ui.dialog(s)
  end

  def echo(s)
    @ucome.echo(s)
  end

  # FIXME: isc to isc? or ucome to isc?
  def download(remote, local)
    debug "#{__method__} #{remote}"
  end

  def upload(local)
    debug "upload #{local}"
    it = File.join(ENV['HOME'], local)
    if File.exists?(it)
      if File.size(it) < MAX_UPLOAD_SIZE
        @ucome.upload(@sid, File.basename(local), File.open(it).read)
      else
        @ui.dialog("too big: #{it}: #{File.size(it)}")
      end
    else
      # FIXME 日本語メッセージだと表示されない。
      @ui.dialog("did not find #{it}.")
    end
  end

  def status()
    msg = @ucome.status(@sid)
    if msg.empty?
      @ui.dialog("まだありません。")
    else
      @ui.dialog(msg.sort.join("<p>"))
    end
  end

  # jruby では無理。
  def exec(command)
    puts "無理。"
  end

end

#
# main starts here
#
$debug = (ENV['DEBUG'] || false)
ucome = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
while (arg = ARGV.shift)
  case arg
  when /--debug/
    $debug = true
  when /--version/
    puts VERSION
    exit
  when /--(uri)|(ucome)/
    ucome = ARGV.shift
  else
    raise "unknown option: #{arg}"
  end
end

debug "ucome: #{ucome}"

DRb.start_service
@ucome = DRbObject.new(nil, ucome)
icome = Icome.new(@ucome)
icome.setup_ui

debug "polloing..."
Thread.new do
  next_cmd = 0
  reset = 0
  while true do
    ucome_reset = @ucome.reset_count
    if ucome_reset > reset
      next_cmd = 0
      reset = ucome_reset
    end
    cmd = @ucome.fetch(next_cmd)
    debug "fetch:#{cmd}, reset: #{reset}, next_cmd: #{next_cmd}"
    if cmd.nil?
      sleep INTERVAL
      next
    end
    case cmd
    when /^x*cowsay\s+(.+)$/
      icome.cowsay($1)
    when /^display\s+(.+)$/
      icome.dialog($1)
    when /^upload\s+(\S+)/
      icome.upload($1)
    when /^download\s+(\S+)\s+(\S+)$/
      icome.download($1,$2)
    when /^exec/
      icome.exec(cmd)
    # BUG!
    when /reset (\d+)/
      next_cmd = $1.to_i
    else
      debug "error: #{cmd}"
    end
    next_cmd += 1
  end
end

DRb.thread.join
