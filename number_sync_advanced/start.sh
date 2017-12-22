#!/bin/bash

# Start the server and spawn clients

xterm -e lua server.lua &

sleep 1

if [ "$1" == "" ]; then
	max=10
else
	max=$1
fi

for (( c=1; c<=max; c++ )) do
	xterm -e lua client.lua &
done
