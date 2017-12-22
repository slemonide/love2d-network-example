local socket = require "socket"
local curses = require "curses"
local udp = socket.udp()
udp:settimeout(0)
udp:setsockname('*', 12345)

local world = {
    state = "0",
    time = "0",
    origin = "server"
}
local numUpdates = 0
local clients = {}
local expect_response = {} -- Clients from which response is expected
local timeout = 1000 -- how many ms to wait before getting rid of the timed out client

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err(err)
    curses.endwin()
    print "Caught an error:"
    print (debug.traceback(err, 2))
    os.exit(2)
end

local stdscr = curses.initscr()

curses.cbreak()
curses.echo(false)	-- not noecho !
curses.nl(false)	-- not nonl !
curses.curs_set(0)

function main()
    while (true) do
        stdscr:erase ()
        stdscr:idcok(false)
        stdscr:idlok(false)

        local data, ip, port = udp:receivefrom()
        if (data) then
            local birth_time, id, cmd, parms = data:match("^(%S*) (%S*) (%S*) (.*)")
            if (cmd == "connect") then
                table.insert(clients, {
                    ip = ip,
                    port = port
                })
                udp:sendto(string.format("id %d", #clients), ip, port)
            elseif (cmd == "set") then
                if (clients[tonumber(id)]) then
                    if (parms ~= "none") then
                        world.state = parms
                        world.time = birth_time
                        world.origin = id
                        numUpdates = numUpdates + 1
                    end

                    expect_response[tonumber(id)] = nil
                end
            else
                error("Unknown command:", data)
            end
        end

        local numClients = 0
        for id, client in pairs(clients) do
            if (not client.state or (client.state and client.state ~= world.state)) then
                udp:sendto(string.format("update %s %s %s", world.time, world.origin, world.state), client.ip, client.port)
                expect_response[id] = expect_response[id] or math.floor(socket.gettime()*1000)
                client.state = world.state
            end
            if expect_response[id] then
                local dt = math.floor(socket.gettime()*1000) - expect_response[id]
                if dt > timeout then
                    clients[id] = nil
                    expect_response[id] = nil
                end
            end

            numClients = numClients + 1
        end
        stdscr:mvaddstr(0, 0, "Number of clients: " .. numClients)
        stdscr:mvaddstr(1, 0, "Updates received: " .. numUpdates)
        stdscr:refresh()
    end
end

xpcall(main, err)