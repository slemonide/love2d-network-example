# love2d-network-example
A simple UDP client/server model in lua

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
