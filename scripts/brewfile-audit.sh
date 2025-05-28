#!/usr/bin/env bash

# brewfile-audit.sh — compares installed formulae to what's declared in Brewfile
# Shows any installed top-level formula that is NOT declared in the Brewfile
brew leaves | sort > /tmp/current-brews.txt

grep '^brew ' Brewfile | \
  cut -d'"' -f2 | \
  sort > /tmp/declared-brews.txt

comm -23 /tmp/current-brews.txt /tmp/declared-brews.txt
