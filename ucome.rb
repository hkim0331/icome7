#!/usr/bin/env ruby
# jgem install bson_ext errored. so ruby.
#
# format {
# sid: '12345678'
# uhour: 'wed3'
# atttends: [ '2014-04-12' ]
# }

VERSION = "0.8.2"
UPDATE  = "2015-04-16"

gem "mongo","1.12.1"
require 'mongo'
require 'drb'

DEBUG = (ENV['DEBUG'] || false)
UPLOAD = if File.directory?("/srv/icome7/upload")
    "/srv/icome7/upload"
  else
    "./upload"
  end
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
HOST = (ENV['MONGO_HOST'] || '127.0.0.1')
PORT = (ENV['MONGO_PORT'] || '27017')
DB   = (ENV['UCOME_DB'] || 'ucome')

def debug(s)
  STDERR.puts "debug: "+s if DEBUG
end

class Ucome

  def initialize
    @conn = Mongo::Connection.new(HOST, PORT)
    @db   = @conn[DB]
    @commands = Commands.new
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

  # admin interface
  def push(cmd)
    @commands.push(cmd)
  end

  def list
    @commands.list
  end

  def delete(n)
    @commands.delete(n)
  end

  def fetch(n)
    @commands.get(n)
  end

  def upload(sid, name, contents)
    dir = File.join(UPLOAD,sid)
    Dir.mkdir(dir) unless File.directory?(dir)
    to = File.join(dir,Time.now.strftime("%F_#{name}"))
    File.open(to, "w") do |f|
      f.puts contents
    end
  end

  def status(sid)
    dir = File.join(UPLOAD, sid)
    if File.directory?(dir)
      Dir.entries(dir).delete_if{|x| x=~/^\./}
    else
      []
    end
  end

  # FIXME: method name
  def refresh
    @commands = Commands.new
    self.push("restart")
  end

end

class Commands

  def initialize
    @commands = []
  end

  def push(cmd)
    @commands.push(cmd)
  end

  def get(n)
    @commands[n]
  end

  def list
    ret = []
    @commands.each_with_index do |cmd, index|
      ret.push "#{index}: #{cmd}"
    end
    ret
  end

  def delete(n)
    @commands.delete_at(n)
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
