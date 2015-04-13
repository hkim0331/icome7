isc:
	install -m 0755 icome.sh /edu/bin/icome
	install -m 0755 icome.rb /home/t/hkimura/bin/icome7.rb

ucome:
	install -m 0755 ucome.service /etc/init.d/ucome
	install -m 0755 ucome.rb /opt/icome7/bin
	install -m 0755 ucome-backup.sh /etc/cron.weekly/ucome-backup
	update-rc.d ucome defaults

clean:
	${RM} *~ *.bak .#*

