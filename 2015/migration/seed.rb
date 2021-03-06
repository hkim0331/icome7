#!/usr/bin/env ruby
# coding: utf-8
# ucome を一旦止め、seed.rb単独で動作させること。

require './ucome.rb'

def uhour(time)
  return 1 if "08:50:00" <= time and time <= "10:20:00"
  return 2 if "10:30:00" <= time and time <= "12:00:00"
  return 3 if "13:00:00" <= time and time <= "14:30:00"
  return 4 if "14:40:00" <= time and time <= "16:10:00"
  return 5 if "16:20:00" <= time and time <= "17:50:00"
  return 0
end

who = Hash.new
debug "read seed.txt."
File.foreach("seed.txt") do |line|
  next if line =~ /^#/
  line = line.strip
  id,sid,date,time = line.split
  next if id.nil?
  who[sid] = uhour(time)
end
debug "who.count: #{who.count}"

ucome = Ucome.new
who.each do |sid, entry|
  ucome.insert(sid, "wed#{entry}", "a2015")
  ucome.update(sid, '2015-04-08', "wed#{entry}", "a2015")
end
