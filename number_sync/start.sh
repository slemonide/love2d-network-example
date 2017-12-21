#!/bin/bash

# Start the server and spawn clients

xterm -e lua server.lua &

sleep 1

for (( c=1; c<=20; c++ )) do
	xterm -e lua client.lua &
done
