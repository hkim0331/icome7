#!/bin/sh
# それぞれ別々のターミナルで動かさなくちゃ。

./start-mongodb.sh
./ucome.rb --debug --uri druby://127.0.0.1:9007
./icome.rb --debug --ucome druby://127.0.0.1:9007
./admin.rb --debug --ucome druby://127.0.0.1:9007
