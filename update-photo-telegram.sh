#!/bin/sh

set -eu

get_photo_cdn_url() {
	/usr/bin/curl -L "https://t.me/$1" 2>/dev/null |
		/usr/bin/awk -F src= '/tgme_page_photo_image/{print $2}' |
		/bin/sed 's/"\([^"]*\)".*/\1/'
}

URL="$(get_photo_cdn_url "$1")"
/usr/bin/curl -L "$URL" > tg_profile.jpg 2>/dev/null
