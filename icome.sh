#!/bin/sh

UCOME='druby://150.69.90.80:9007' nohup /home/t/hkimura/bin/icome7.rb 2>/dev/null &
if [ -e /edu/bin/watch-ss ]; then
    nohup /edu/bin/watch-ss 2>/dev/null &
fi
