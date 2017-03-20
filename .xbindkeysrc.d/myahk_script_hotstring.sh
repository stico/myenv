#!/bin/sh

hotstring=$(zenity --entry --text "Hotstirng?" --entry-text "ffdate")
case "$hotstring" in
	"ffweb")
		xdotool type --delay 10 --clearmodifiers "g-cs@yy.com,g-yy-web@yy.com,g-java-bpt@yy.com,linyi6@yy.com"
		;;
	"ffdate")
		xdotool type --delay 10 --clearmodifiers "$(date "+%Y-%m-%d")"
		;;
	"fgdate")
		xdotool type --delay 10 --clearmodifiers "_$(date "+%Y-%m-%d")"
		;;
	"fftime")
		xdotool type --delay 10 --clearmodifiers "$(date "+%H-%M-%S")"
		;;
	"ffdati")
		xdotool type --delay 10 --clearmodifiers "$(date "+%Y-%m-%d_%H-%M-%S")"
		;;
	"ffip")
		xdotool type --delay 10 --clearmodifiers "/sbin/ifconfig | sed -n -e '/inet addr/s/.*inet addr:\([.0-9]*\).*/\1/p'"
		;;
	"ffpay")
		xdotool type --delay 10 --clearmodifiers "pay.duowan.com"
		;;
	"ffmain")
		xdotool type --delay 10 --clearmodifiers '
public class T {
public static void main(String[] args) {
System.out.println("hello");
}
}
'
		;;
	*)
		;;
esac
