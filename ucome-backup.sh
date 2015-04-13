#!/bin/sh

mongoexport -d ucome -c a2015 -o /opt/icome7/log/`date +%F`.csv

