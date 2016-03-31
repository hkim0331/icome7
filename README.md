# icome7

icome version 7.

rewrote icome6 from scratch with backend mongodb.

## require

````sh
$ gem install mongo -v 1.12.1
$ gem install bson_ext
````

## develop

prep mongodb:

````sh
localhost$ ./start-mongo.sh
````

launch ucome:

````sh
localhost$ ./ucome.rb --uri druby://127.0.0.1:9007
````

then icome.

````sh
localhost$  ./icome.rb --uri druby://127.0.0.1:9007
````

## production

### orange

````sh
# service mongodb start
# service ucome start
````

ucome runs under hkim privilege.

### isc

````sh
isc$ /edu/bin/icome
````

### isc admin

````sh
hkimura$ ~/icome7/admin.rb
````
* display message
* upload dir/file ...
  upload local:~/dir/file as remote:/srv/icome7/upload/uid/file
  `dir/` is omitted.


## author

hiroshi.kimura.0331@gmail.com

