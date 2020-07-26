#!/bin/bash

set -e

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

# Print connection info
DISPLAY=1
while [ $DISPLAY -le 3 ]; do
    echo ________________________________________________________________________________
    echo To connect to this session copy-n-paste the following into a terminal or browser:
    tmate -S /tmp/tmate.sock display -p '#{tmate_ssh}'
    tmate -S /tmp/tmate.sock display -p '#{tmate_web}'
    [ ! -f /tmp/keepalive ] && echo -e "After connecting you can run 'touch /tmp/keepalive' to disable the 30m timeout"
    DISPLAY=$(($DISPLAY + 1))
    sleep 30
done
