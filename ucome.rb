#!/usr/bin/env ruby
# jgem install bson_ext errored.
# so ruby.

require 'drb'
require 'mongo'

DEBUG = true
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

def debug(s)
  puts s if DEBUG
end

class Ucome
  def initialize
  end

  def insert(sid, uhour)
  end

  def update(sid, date, uhour)
  end

  def find(sid, uhour)
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
