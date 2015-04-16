#!/bin/sh

mongoexport -d ucome -c a2015 -o /opt/icome7/csv/`date +%F`.csv

