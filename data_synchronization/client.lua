local curses = require "curses"
local socket = require "socket"
local udp = socket.udp()
udp:settimeout(0)
udp:setpeername("localhost", 12345)


local function printf (fmt, ...)
    return print (string.format (fmt, ...))
end

world = {}

local id = tostring(math.random(99999))
udp:send(string.format("%s %s $", id, 'connect'))

-- To display Lua errors, we must close curses to return to
-- normal terminal mode, and then write the error to stdout.
local function err (err)
    curses.endwin ()
    print "Caught an error:"
    print (debug.traceback (err, 2))
    os.exit (2)
end

local function main ()
    math.randomseed(os.time())

    local stdscr = curses.initscr ()

    curses.cbreak ()
    curses.echo (false)	-- not noecho !
    curses.nl (false)	-- not nonl !

    while (true) do
        repeat
            local data, msg = udp:receive()
            if data then
                world = loadstring(data)()
            end
        until not data

        stdscr:clear ()
        for x,next in ipairs(world) do
            for y,val in ipairs(next) do
                stdscr:mvaddstr (y - 1, x - 1, val)
            end
        end
        stdscr:refresh ()
        os.execute("sleep 0.1")

        if (math.random() > 0.9) then
            udp:send(string.format("%s %s %d %d %s", id, 'set', math.random(60), math.random(10), math.random() > 0.5 and "O" or "X"))
        end
    end
end

xpcall (main, err)