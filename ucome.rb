#!/usr/bin/env ruby
# jgem install bson_ext errored.
# so ruby.

gem "mongo","1.12.1"
require 'mongo'
require 'drb'

DEBUG = true
VERSION = "0.1.1"

UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
HOST = (ENV['UCOME_HOST'] || '127.0.0.1')
PORT = (ENV['UCOME_PORT'] || '27017')
DB   = (ENV['UCOME_DB'] || 'ucome')
def debug(s)
  STDERR.puts s if DEBUG
end

class Ucome
  def initialize
    @conn  = Mongo::Connection.new(HOST, PORT)
    @db    = @conn[DB]
    @users = @db['users']
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
