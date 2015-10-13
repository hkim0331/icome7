all: fix-2015-10-02

fix-2015-10-02: 2015-10-02-fixed.csv
	mongoimport -d ucome -c b2015 --upsert --file $?

2015-10-02-fixed.csv: 2015-10-02.csv
	ruby fix-2015-10-02.rb

clean:
	${RM} 2015-10-02-fixed.csv


