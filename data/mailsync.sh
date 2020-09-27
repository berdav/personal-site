#!/bin/sh

set -eu
mbsync -a
mairix -v -F
imapfilter
