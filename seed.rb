#!/usr/bin/env ruby

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
File.foreach("data/icome.txt") do |line|
  next if line =~ /^#/
  line = line.strip
  id,sid,date,time = line.split
  next if id.nil?
  who[sid] = uhour(time)
end

ucome = Ucome.new
#puts who.count
who.each do |sid, entry|
  #puts "#{sid} wed#{entry}"
  ucome.insert(sid, "wed#{entry}", "a2015")
  ucome.update(sid, '2015-04-08', "wed#{entry}", "a2015")
end
