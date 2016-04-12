#!/bin/sh
TERM=b2015
mongoexport -d ucome -c ${TERM} -o /opt/icome7/csv/`date +%F`.csv

