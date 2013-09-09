#!/bin/sh

hotstring=$(zenity --entry --text "Hotstirng?" --entry-text "ffdate")
case "$hotstring" in
	"ffdate")
		xdotool type --clearmodifiers "$(date "+%Y-%m-%d")"
		;;
	"fgdate")
		xdotool type --clearmodifiers "_$(date "+%Y-%m-%d")"
		;;
	"fftime")
		xdotool type --clearmodifiers "$(date "+%H-%M-%S")"
		;;
	"ffdati")
		xdotool type --clearmodifiers "$(date "+%Y-%m-%d_%H-%M-%S")"
		;;
	"ffpay")
		xdotool type --clearmodifiers "pay.duowan.com"
		;;
	*)
		;;
esac
