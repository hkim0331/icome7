#!/usr/bin/env jruby
# coding: utf-8
# swing. so jruby.

require 'drb'
require 'socket'
require 'date'

DEBUG = true
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

PREFIX = {'j' => '10',
          'k' => '11',
          'm' => '12',
          'n' => '13',
          'o' => '14',
          'p' => '15'}

def debug(s)
  puts s if DEBUG
end

# hkim or hkimura does not has PREFIX
def uid2sid(uid)
  PREFIX[uid[0]] + uid[1,6]
rescue
  uid
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

end

class Icome
  def initialize(ucome)
    @ucome = ucome
    @ip = IPSocket::getaddress(Socket::gethostname)
    @uid = ENV['USER']
    @sid = uid2sid(@uid)
  end

  def setup_ui
    UI.new(self)
  end

  def attend
    debug "attend"
  end

  def show
    debug "show"
  end

  def quit
    java.lang.System.exit(0) unless ENV['UCOME']
  end

  def echo(s)
    @ucome.echo(s)
  end
end

#
# main starts here
#

DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)

icome = Icome.new(ucome)
icome.setup_ui

debug ucome.echo("hello, ucome.")
debug icome.echo("hello, ucome via icome.")

Thread.new do
  while true do
    sleep icome.interval
  end
end

DRb.thread.join
