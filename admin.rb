#!/usr/bin/env ruby
# coding: utf-8
# UI なしでも動作できたほうがいい。


require 'drb'

DEBUG = true

VERSION = "0.6.1"
UPDATE  = "2015-04-13"

UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')

def debug(s)
  STDERR.puts "debug: " + s if DEBUG
end

def usage
  print <<EOF
usage:
  delete n
  display message
  download remote local
  list
  upload local remote
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
    when /upload (\w+) (\w+)/
      ucome.push(cmd)
    when /download (\w+) (\w+)/
      ucome.push(cmd)
    when /display/
      ucome.push(cmd)
    when /list/
      puts ucome.list
    when /delete (\d+)/
      ucome.delete($1.to_i)
    when /quit/
      exit(0)
    else
      usage()
    end
  end
end
DRb.thread.join
