#!/bin/bash

tmate_bin=/usr/local/bin/tmate
sctext="$1"tmate_session
scdesp=
sckey=$2
tmate_msg=
tmate_ssh=
tmate_web=

[ -z "$2" ] && sckey=$WORKFLOW_SCKEY
if [ -z "$sckey" ]; then
	echo "SCKEY ERROR!"
	exit 1
fi

for i in $(seq 1 10)
do
	[ -x "$tmate_bin" ] && {
		[ -z "$scdesp" ] && scdesp="`"$tmate_bin" show-messages`"
		if [ -z "$scdesp" ]; then
			scdesp="`"$tmate_bin" -S /tmp/tmate.sock display -p '#{tmate_web}'`"
			[ -n "$scdesp" ] && scdesp="$scdesp"" && `"$tmate_bin" -S /tmp/tmate.sock display -p '#{tmate_ssh}'`"
		fi

		if [ -n "$scdesp" ]; then
			curl -o /dev/null --data-urlencode "text=$sctext" --data-urlencode "desp=$scdesp" https://sc.ftqq.com/$sckey.send
			break
		fi
	}

	sleep 1m
done
