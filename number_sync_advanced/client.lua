local socket = require "socket"
local curses = require "curses"
local udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 12345)
math.randomseed(os.time())

local id = tostring(math.random(100000,999999))
local updateNum = 0

-- connect
udp:send(string.format("%d %s %s %s", os.time(), id, 'connect', "$"))

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
curses.curs_set(0)

local log = {}
local function shift_log()
    if (#log > 10) then
        for i = 1, #log do
            log[i] = log[i + 1]
        end
    end
end

while (true) do
    stdscr:erase ()
    stdscr:idcok(false)
    stdscr:idlok(false)

    repeat
        local data, msg = udp:receive()
        if data then
            local state, time, origin = data:match("^(%S*) (%S*) (.*)")
            table.insert(log, {
                updateNum = updateNum,
                data = state,
                time = time,
                origin = origin,
                delay = os.time() - tonumber(time)
            })
            shift_log()
            updateNum = updateNum + 1
        end
    until not data

    if (math.random() > 0.9995) then
        local msg = ""

        for i = 1, 1000 do
            msg = msg .. tostring(math.random(99999999))
        end

        udp:send(string.format("%d %s %s %s", os.time(), id, 'set', msg))
    end

    stdscr:mvaddstr(0, 0, "Client id: " .. id)
    stdscr:mvaddstr(1, 0, "Update    World State    Delay (ms)    Origin")
    for i = 1, #log do
        stdscr:mvaddstr(i + 1, 0, log[i].updateNum)
        stdscr:mvaddstr (i + 1, 10, log[i].data:sub(0, 11))
        stdscr:mvaddstr(i + 1, 25, log[i].delay)
        stdscr:mvaddstr(i + 1, 39, log[i].origin)
    end
    stdscr:refresh ()
end