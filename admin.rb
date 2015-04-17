#!/usr/bin/env ruby
# coding: utf-8
# UI なしでも動作できたほうがいい。

require 'drb'

VERSION = "0.8.3"
UPDATE  = "2015-04-17"

DEBUG = (ENV['DEBUG'] || false)
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

def debug(s)
  STDERR.puts "debug: " + s if DEBUG
end

def usage
  print <<EOF
usage:
  delete n
  display message
  download remote
  exec command
  list
  (re)start
  upload local
  quit
EOF
end

#
# main starts here
#

DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)

Thread.new do
  puts "type 'quit' to quit"
   while (print "> "; cmd = STDIN.gets)
    case cmd
    when /list/
      puts ucome.list
    when /display/
      ucome.push(cmd)
    when /delete\s+(\d+)/
      ucome.delete($1.to_i)
    when /upload\s+.+/
      ucome.push(cmd)
    when /download\s+.+/
      ucome.push(cmd)
    when /exec/
      ucome.push(cmd)
    when /(re)?start/
      ucome.refresh
    when /quit/
      exit(0)
    else
      usage()
    end
  end
end
DRb.thread.join
