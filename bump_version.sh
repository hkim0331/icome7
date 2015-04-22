#!/usr/bin/env dash
# -*- mode: Shell-script; coding: utf-8; -*-

if [ ! $# = 1 ]; then
    echo usage: $0 VERSION
    exit
fi

if [ -e /Users ]; then
    SED="gsed"
else
    SED="sed"
fi

VERSION=$1
TODAY=`date +%F`

RB_FILES="icome.rb ucome.rb admin.rb"
for i in ${RB_FILES}; do
    ${SED} -i.bak \
           -e "/^ *VERSION *=/c\
VERSION = \"${VERSION}\"" \
           -e "/^ *UPDATE *=/c\
UPDATE  = \"${TODAY}\"" $i
done

# sh script does not allow spaces around '='.
SH_SCRIPT="icome.sh"
for i in ${SH_SCRIPT}; do
	${SED} -i.bak \
		-e "/^ *VERSION/c\
VERSION=\"${VERSION}\"" $i
done

echo ${VERSION} > VERSION
