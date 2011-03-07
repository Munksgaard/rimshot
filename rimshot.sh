#!/bin/bash

FILE=~/rimshot.mp3
LOCK=/tmp/rimshot_lock
CHANNELS=(Master PCM Speaker)

if [ -f $LOCK ]; then
    exit
fi

touch $LOCK

# hash map implementation from: http://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash/2225712#2225712

hput() {
    eval "$1""$2"='$3'
}

hget() {
    eval echo '${'"$1$2"'#hash}'
}

function get_max() {
    amixer get $1 | grep Limits | awk '{print $5}'
}

function get_volume() {
    amixer get $1 | awk -F'[]%[]' '/%/ { print $2 }' | head -n 1
}

STATE=$(amixer get Master | awk -F'[]%[]' '/%/ { print $7 }')

for c in ${CHANNELS[@]}; do
    hput vols $c $(get_volume $c)
    amixer -q set $c $(get_max $c)
done

amixer -q set Master on

mplayer $FILE

amixer -q set Master $STATE

for c in ${CHANNELS[@]}; do
    amixer -q set $c $(hget vols $c)
done

rm -f $LOCK
