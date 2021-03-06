local socket = require "socket"
local curses = require "curses"
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 12345)

local world = "0"
local numUpdates = 0
local clients = {}

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err (err)
    curses.endwin ()
    print "Caught an error:"
    print (debug.traceback (err, 2))
    os.exit (2)
end

local stdscr = curses.initscr ()

curses.cbreak ()
curses.echo (false)	-- not noecho !
curses.nl (false)	-- not nonl !

while (true) do
    stdscr:clear ()

    local data, ip, port = udp:receivefrom()
    if (data) then
        local id, cmd, parms = data:match("^(%S*) (%S*) (.*)")
        if (cmd == "connect") then
            table.insert(clients, {
                ip = ip,
                port = port
            })
        elseif (cmd == "set") then
            world = parms
            numUpdates = numUpdates + 1
        else
            err("Unknown command:", data)
        end
    end

    local numClients = 0
    for _, client in ipairs(clients) do
        if (not client.world or (client.world and client.world ~= world)) then
            udp:sendto(world, client.ip, client.port)
            client.world = world
        end

        numClients = numClients + 1
    end
    stdscr:mvaddstr (0, 0, "Number of clients: " .. numClients)
    stdscr:mvaddstr (1, 0, "Updates received: " .. numUpdates)
    stdscr:refresh ()
    os.execute("sleep 0.01")
end