# love2d-network-example
A simple UDP client/server model in lua

## ping_pong

A simple UDP ping-pong. Client sends pings to the server, and the server
responds with pongs.

## number_sync

Synchronizes a number between clients. At any moment in time, any client
could change the number and the server would have to notify other clients.

## number_sync_advanced

Same thing as number_sync, but has disconnect messages and
network profiling.

# Model
The world is made from one server and arbitrary number of clients.
Server has a table of unspecified objects and a table of clients.

Each object has an index and data.
Each client field on the server has an unique id and a table of known objects.

## The client
Client has an id, a table of known objects and a table of updates.
When client is changed by the user, a change is recorded in the updates table and is then sent to the server when it is time.

When a client receives updates from the server, it updates the table of known objects and, if an update overrides an element of
table of updates, removes that element from the updates table.
