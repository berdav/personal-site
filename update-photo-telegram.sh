#!/bin/sh

set -eu

get_photo_cdn_url() {
	/usr/bin/curl -L "https://t.me/$1" 2>/dev/null |
		/usr/bin/awk -F src= '/tgme_page_photo_image/{print $2}' |
		/bin/sed 's/"\([^"]*\)".*/\1/'
}

get_description_text() {
	/usr/bin/curl -L "https://t.me/$1" 2>/dev/null |
		/usr/bin/awk -F "[<>]" '/class="tgme_page_description/{print $3}'
}

get_description() {
	D="$(get_description_text "$1")"
	L="$(echo "$D" | wc -l)"

	C="$(( $(echo "$D" | wc -c) - 1 ))"
	C="$(( $C > 80 ? 80 : $C ))"

	echo "$D" | fold | convert \
		-page "900x$(( $L * 30))+0+0" \
		-font Helvetica \
		-style Normal \
		-background none \
		-gravity Center \
		-undercolor white \
		-fill black \
		-pointsize 22 text:- +repage \
		-background white \
		-flatten \
		tg_bio.jpg
}

URL="$(get_photo_cdn_url "$1")"
/usr/bin/curl -L "$URL" > tg_profile.jpg 2>/dev/null

get_description "$1"
chmod 644 tg_bio.jpg
