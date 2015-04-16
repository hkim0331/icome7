#!/usr/bin/env ruby
# jgem install bson_ext errored.
# so ruby.
#
# format {
# sid: '12345678'
# uhour: 'wed3'
# atttends: [ '2014-04-12' ]
# }

gem "mongo","1.12.1"
require 'mongo'
require 'drb'

VERSION = "0.6.1"
UPDATE  = "2015-04-13"

DEBUG = (ENV['DEBUG'] || false)
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
HOST = (ENV['UCOME_HOST'] || '127.0.0.1')
PORT = (ENV['UCOME_PORT'] || '27017')
DB   = (ENV['UCOME_DB'] || 'ucome')

def debug(s)
  STDERR.puts "debug: "+s if DEBUG
end

class Ucome
  def initialize
    @conn = Mongo::Connection.new(HOST, PORT)
    @db   = @conn[DB]
  end

  def insert(sid, uhour, term)
    debug "#{__method__} #{sid} #{uhour} #{term}"
    @db[term].save({sid: sid, uhour: uhour, attends: []})
  end

  def update(sid, date, uhour, term)
    debug "#{__method__} #{sid} #{date} #{uhour} #{term}"
    @db[term].update({sid: sid, uhour: uhour},
                      {"$addToSet" => {attends: date}},
                      :multi => false);
  end

  def find(sid, uhour, term)
    debug "#{__method__} #{sid} #{uhour} #{term}"
    ret = @db[term].find_one({sid: sid, uhour: uhour})
    if ret.nil?
      nil
    else
      ret["attends"]
    end
  end

  def quit
    debug "will quit"
    exit(0)
  end

  def echo(s)
    s
  end

end

#
# main starts here.
#
if __FILE__==$0
  ucome = Ucome.new
  DRb.start_service(UCOME_URI, ucome)
  debug DRb.uri
  DRb.thread.join
end
