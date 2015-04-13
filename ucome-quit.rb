#!/usr/bin/env ruby
# coding: utf-8
# does not work. 2015-04-13

require 'drb'

UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)
ucome.quit
DRb.thread.join
