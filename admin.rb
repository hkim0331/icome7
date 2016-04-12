#!/usr/bin/env ruby
# coding: utf-8
# UI なしでも動作できたほうがいい。

require 'drb'

VERSION = "1.0"
UPDATE  = "2016-04-12"

def debug(s)
  STDERR.puts "debug: " + s if $debug
end

def usage
  print <<EOF
usage:
  [display|message]  message
  [upload|get] local (base dir is user's HOME)
  list
  delete n
  reset
  version
  quit
  - download remote as (not yet)
  - exec command  (not yet. impossible, jruby?)
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
  when /--(uri)|(ucome)/
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
    when /^display/
      ucome.push(cmd)
    when /delete\s+(\d+)/
      ucome.delete($1.to_i)
    when /^upload/
      ucome.push(cmd)
    when /^download/
      ucome.push(cmd)
    when /^exec/
      ucome.push(cmd)
    when /^version/
      puts VERSION
    when /^reset/
      ucome.reset
    when /^quit/
      ucome.reset
      exit(0)
    else
      usage()
    end
   end
   ucome.reset
   exit(0)
end
DRb.thread.join
