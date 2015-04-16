#!/bin/sh

# debug
ICOME=./icome.rb
#ICOME=/home/t/hkimura/bin/icome.rb
SS=/edu/bin/watch-ss

# check singleton
ps ax | egrep '[i]come.rb' >/dev/null
if [ "$?" -eq 0 ]; then
    echo "icome はすでに起動しています。"
    exit
fi

# icome
if [ -e ${ICOME} ]; then
    echo "icome の起動には 5 秒くらいかかります。"
    UCOME='druby://150.69.90.80:9007' nohup ${ICOME} 2>/dev/null &
fi

# additional scripts
if [ -e ${SS} ]; then
    nohup ${SS} 2>/dev/null &
fi
