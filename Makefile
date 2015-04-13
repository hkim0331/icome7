isc:
	install -m 0755 icome.sh /edu/bin/icome
	install -m 0755 icome.rb /home/hkim/bin/icome7.rb

ucome:
	install -m 0644 ucome.service /etc/init.d/ucome
	install -m 0755 ucome.rb ucome-backup.sh ucome-quit.rb /opt/icome7/bin
	update-rc.d ucome defaults

clean:
	${RM} *~ *.bak .#*

