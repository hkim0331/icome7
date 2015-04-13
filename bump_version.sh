#!/usr/bin/env dash
# -*- mode: Shell-script; coding: utf-8; -*-

if [ ! $# = 1 ]; then
    echo usage: $0 VERSION
    exit
fi
VERSION=$1
FILES="icome.rb ucome.rb"

# must use gsed?
SED="sed"
for i in ${FILES}; do
    ${SED} -i.bak "/^\s*VERSION\s*=/ c\
VERSION = \"${VERSION}\"" $i
done

echo ${VERSION} > VERSION
