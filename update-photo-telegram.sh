#!/bin/sh

set -eu

get_photo_cdn_url() {
	curl -L "https://t.me/$1" |
		awk -F src= '/tgme_page_photo_image/{print $2}' |
		sed 's/"\([^"]*\)".*/\1/'
}

URL="$(get_photo_cdn_url "$1")"
curl -L "$URL" > tg_profile.jpg
