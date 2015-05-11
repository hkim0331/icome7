# icome7

icome version 7.

rewrote icome6 from scratch with backend mongodb.

## require

````
gem install mongo -v 1.12.1
gem install bson_ext
````

## develop

prep mongodb:

````
localhost$ ./start-mongo.sh
````

launch ucome:

````
localhost$ ./ucome.rb --uri druby://127.0.0.1:9007
````

then icome.

````
localhost$  ./icome.rb --uri druby://127.0.0.1:9007
````

## production

### orange

````
# service mongodb start
# service ucome start
````

ucome は hkim 権限で起動する。

### isc

````
isc$ /edu/bin/icome
````

### isc admin

````
hkimura$ ~/icome7/admin.rb
````


## author

hiroshi.kimura.0331@gmail.com

