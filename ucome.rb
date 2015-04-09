#!/usr/bin/env ruby
# jgem install bson_ext errored.
# so ruby.

require 'drb'
require 'mongo'

DEBUG = true
VERSION = "0.1.1"

UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

def debug(s)
  STDERR.puts s if DEBUG
end

class Ucome
  def initialize
  end

  def insert(sid, uhour)
    debug "insert #{sid} #{uhour}"
  end

  def update(sid, date, uhour)
    debug "update #{sid} #{date} #{uhour}"
  end

  def find(sid, uhour)
    debug "find #{sid} #{uhour}"
    Time.now.to_s
  end

  def echo(s)
    s
  end

end

#
# main starts here.
#

ucome = Ucome.new
DRb.start_service(UCOME_URI, ucome)
debug DRb.uri
DRb.thread.join
