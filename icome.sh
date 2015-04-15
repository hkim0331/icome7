#!/bin/sh

# singleton check
if [ `ps ax | grep icome7.rb` ]; then
    echo 1
else
    echo 2
fi
exit(0)

echo "icome は起動に 5 秒くらいかかります。"
UCOME='druby://150.69.90.80:9007' nohup /home/t/hkimura/bin/icome7.rb 2>/dev/null &
if [ -e /edu/bin/watch-ss ]; then
    nohup /edu/bin/watch-ss 2>/dev/null &
fi
