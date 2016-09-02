all: fix-2016-01-07

import-2016-01-03: 2016-01-03.csv
	mongoimport -d ucome -c b2015 --upsert --file $?

fix-2016-01-07: import-2016-01-03
	echo db.b2015b.update(
	echo {uhour: "thr1"},{'$addToSet': {attends: "2016-01-07"}}
	echo {multi: true})

fix-2015-10-02: 2015-10-02-fixed.csv
	mongoimport -d ucome -c b2015 --upsert --file $?

2015-10-02-fixed.csv: 2015-10-02.csv
	ruby fix-2015-10-02.rb

clean:
	${RM} 2015-10-02-fixed.csv


