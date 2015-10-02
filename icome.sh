#!/bin/sh

VERSION="0.20"

# debug
#ICOME=./icome.rb
ICOME=/home/t/hkimura/bin/icome7.rb
SS=/edu/bin/watch-ss

if [ "$1" = "--version" ]; then
	echo ${VERSION}
	exit
fi

# singleton check
ps ax | egrep '[i]come7.rb' >/dev/null
if [ "$?" -eq 0 ]; then
    echo "icome はすでに起動しています。"
    exit
fi

# launch icome
if [ -e ${ICOME} ]; then
    echo "icome の起動には 5 秒くらいかかります。"
    UCOME='druby://150.69.90.80:9007' nohup ${ICOME} 2>/dev/null &
fi

# additional scripts
if [ -e ${SS} ]; then
    nohup ${SS} 2>/dev/null &
fi
