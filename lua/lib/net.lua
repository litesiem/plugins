local time = require('posix.time')

local dir = (...):match("(.-)[^%.]+$")
local socket = require(dir .. "socket")

local p = {}

local HOST_RESOLV_CACHE = {}
local HOST_BLACK_LIST = {}
local HOST_RESOLV_DYNAMIC_CACHE = {}

-- Translates a host name to IPv4 address
function p.resolv(host)
    host = string.lower(host)
    local addr = host

    if HOST_RESOLV_CACHE[host] ~= nil then
        return HOST_RESOLV_CACHE[host]
    end

    if HOST_RESOLV_DYNAMIC_CACHE[host] ~= nil then
        -- Return the first IP assigned to the host
        return HOST_RESOLV_CACHE[host][1]
    end

    local dns_query = true
    if HOST_BLACK_LIST[host] ~= nil then
        if HOST_BLACK_LIST[host] - time.time() <= 120 then
            dns_query = false
        end
    end


    if dns_query then
        addr = socket.gethostbyname(host)[1]
        HOST_RESOLV_CACHE[host] = addr
        HOST_BLACK_LIST[host] = time.time()

        if addr == nil then
            addr = host
            HOST_BLACK_LIST[host] = time.time()
        end
    end

    return addr
end

return p
