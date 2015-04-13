#!/usr/bin/env jruby
# coding: utf-8
# swing. so jruby.

require 'drb'

VERSION = "0.4.1"
UCOME_URI = (ENV['UCOME'] || 'druby://127.0.0.1:9007')
DRb.start_service
ucome = DRbObject.new(nil, UCOME_URI)
ucome.quit
DRb.thread.join
