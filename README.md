# icome7

icome version 7.
rewrite icome6 with backend mongodb.

## require

````
gem install mongo -v 1.12.1
gem install bson_ext
````

## usage

mongodb:

````
mongo$ ./start-mongodh.sh
````

server:

````
orange$ UCOME='druby://150.69.90.80:9007' ./ucome.rb
````

client:

````
isc$ UCOME='druby://150.69.90.80:9007' ./icome.rb
````

## author

hiroshi.kimura.0331@gmail.com

