#!/bin/sh

nohup UCOME='druby://150.69.90.80:9007' /home/t/hkimura/bin/icome7.rb &
if [ -e /edu/bin/watch-ss ]; then
    nohup /edu/bin/watch-ss &
fi



