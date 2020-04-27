#!/bin/sh

today=$(date -Iseconds)

sed \
  -e "s/^draft: false/date: $today/" \
  -e "s/^lastmod:.*/lastmod: $today/"
