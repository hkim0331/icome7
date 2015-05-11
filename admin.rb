#!/usr/bin/env ruby
# coding: utf-8
# UI なしでも動作できたほうがいい。

require 'drb'

VERSION = "0.10"
UPDATE  = "2015-05-11"

def debug(s)
  STDERR.puts "debug: " + s if $debug
end

def usage
  print <<EOF
usage:
  display message

  upload local (base user's HOME)
  (download remote as, not yet)
  (exec command, not yet. impossible.)

  list
  delete n
  reset

  quit
EOF
end

#
# main starts here
#
$debug = (ENV['DEBUG'] || false)
uri = 'druby://150.69.90.80:9007'
while (arg = ARGV.shift)
  case arg
  when /--help/
    usage()
    exit(0)
  when /--debug/
    $debug = true
  when /--uri/
    uri = ARGV.shift
  when /--version/
    puts VERSION
    exit
  end
end
debug "uri: #{uri}"

DRb.start_service
ucome = DRbObject.new(nil, uri)
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
    when /download\s+(\S+)\s+(\S+)/
      ucome.push(cmd)
    when /exec/
      ucome.push(cmd)
    when /reset/
      ucome.reset
    when /quit/
      ucome.reset
      exit(0)
    else
      usage()
    end
  end
end
DRb.thread.join
