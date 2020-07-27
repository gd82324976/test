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

# START: copy from P3TERX/debugger-action/script.sh
# Install tmate on macOS or Ubuntu
echo Setting up tmate...
if [ -x "$(command -v apt-get)" ]; then
    curl -fsSL git.io/tmate.sh | bash
elif [ -x "$(command -v brew)" ]; then
    brew install tmate
else
    exit 1
fi

# Generate ssh key if needed
[ -e ~/.ssh/id_rsa ] || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ""

# Run deamonized tmate
echo Running tmate...
tmate -S /tmp/tmate.sock new-session -d
tmate -S /tmp/tmate.sock wait tmate-ready
# END: copy from P3TERX/debugger-action/script.sh

[ -n "`ps -aux | grep tmate`" ] && echo "##[set-env name=SKIP_DEBUGGER;]yes"

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

if [ -n "$WAIT_TO_CONNSSH" -a -S /tmp/tmate.sock ]; then
echo -e "After connecting you can run 'touch /tmp/keepalive' to disable the 30m timeout"

# START: copy from P3TERX/debugger-action/script.sh
# Wait for connection to close or timeout in 30 min
timeout=$((30 * 60))
while [ -S /tmp/tmate.sock ]; do
    sleep 1
    timeout=$(($timeout - 1))

    if [ ! -f /tmp/keepalive ]; then
        if ((timeout < 0)); then
#            echo Waiting on tmate connection timed out!
#            sudo init 0
            echo "Connection timed out!" && break
        fi
    fi
done
# END: copy from P3TERX/debugger-action/script.sh
fi
