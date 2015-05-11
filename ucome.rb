#!/usr/bin/env ruby
# jgem install bson_ext errored. so ruby.
#
# format {
# sid: '12345678'
# uhour: 'wed3'
# atttends: [ '2014-04-12' ]
# }

VERSION = "0.11.1"
UPDATE  = "2015-05-11"

gem "mongo","1.12.1"
require 'mongo'
require 'drb'
require 'socket'

UPLOAD = if File.directory?("/srv/icome7/upload")
    "/srv/icome7/upload"
  else
    "./upload"
  end

def usage()
  print <<EOF
usage: #{$0} [--mongodb host:port:db]
             [--uri druby://address:port]
             [--version]
             [--usage]
EOF
end

def debug(s)
  STDERR.puts "debug: #{s}" if $debug
end

class Ucome
  def initialize(host, port, db)
    @conn = Mongo::Connection.new(host, port)
    @db   = @conn[db]
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
    debug "#{__method__} #{sid} #{name}"
    dir = File.join(UPLOAD,sid)
    Dir.mkdir(dir) unless File.directory?(dir)
    to = File.join(dir,Time.now.strftime("%F_#{name}"))
    File.open(to, "w") do |f|
      f.puts contents
    end
    debug "#{__method__} to: #{to}"
  end

  def status(sid)
    dir = File.join(UPLOAD, sid)
    if File.directory?(dir)
      Dir.entries(dir).delete_if{|x| x=~/^\./}
    else
      []
    end
  end

  def reset
    @commands = Commands.new
  end

end

class Commands

  def initialize
    @commands = []
  end

  def push(cmd)
    @commands.push(cmd)
  end

  # if out of range, returns nil. it's OK.
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
$debug  = (ENV['DEBUG'] || false)

uri  = (ENV['UCOME'] ||
        "druby://#{IPSocket::getaddress(Socket::gethostname)}:9007")
host = (ENV['MONGO_HOST'] || '127.0.0.1')
port = (ENV['MONGO_PORT'] || '27017')
db   = (ENV['UCOME_DB'] || 'ucome')

while (arg = ARGV.shift)
  case arg
  when /--mongodb/
    host,port,db = ARGV.shift.split(/:/)
  when /--uri/
    uri = ARGV.shift
  when /--version/
    puts VERSION
    exit(0)
  when /--debug/
    $debug = true
  when /--(usage)|(help)/
    usage()
    exit
  else
    raise "unknown option: #{arg}"
    usage()
  end
end

if __FILE__==$0
  DRb.start_service(uri, Ucome.new(host,port,db))
  puts DRb.uri
  DRb.thread.join
end
