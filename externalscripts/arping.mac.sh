#!/usr/bin/env bash

ARPING_BIN=arping

## Extended configuration ##
SENDER_BIN=/usr/bin/zabbix_sender

## Advancced configuration ##
TIMEOUT=20

IP_ITEM='arping.ip'
TIME_ITEM='arping.time'
SERVER_OR_PROXY_IP='127.0.0.1'

HOSTCONN="$1"
HOSTHOST="$2"

## End of configuration ##


OUTPUT=`"$ARPING_BIN" -w "$TIMEOUT" -c 2 "$HOSTCONN"`

MAC=` echo "$OUTPUT" | grep -m 1 -o ' \[..:..:..:..:..:..\] '            | tr -d '[] '           | head -1`

IP=`  echo "$OUTPUT" | grep -m 1 -o 'ARPING .\+ from' | sed 's/ARPING //;s/ from//'              | head -1`

TIME=`echo "$OUTPUT" | grep -m 1 -o '\][[:space:]]\+[0-9]\+\.[0-9]\+ms$' | tr -d '[[:alpha:]] ]' | head -1`

if [[ "$OUTPUT" == \!* ]] ||
   [[ "$OUTPUT" == \.* ]] ||
   [[ "$OUTPUT" == *\):[[:space:]]index\=* ]]
then
	echo `basename "$0"`': Only iproute-arping is currently supported. Terminating.'
	exit 1
fi

echo "$MAC"

SENDER_DATA="\"$HOSTHOST\" $IP_ITEM   \"$IP\"
             \"$HOSTHOST\" $TIME_ITEM \"$TIME\""

echo "$SENDER_DATA" | "$SENDER_BIN" -z "$SERVER_OR_PROXY_IP" -i - >/dev/null 2>&1

