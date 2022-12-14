local ffi = require 'ffi'
local p = {}

ffi.cdef([[
struct hostent {
    char  *h_name;            /* official name of host */
    char **h_aliases;         /* alias list */
    int    h_addrtype;        /* host address type */
    int    h_length;          /* length of address */
    char **h_addr_list;       /* list of addresses */
};
struct hostent *gethostbyname(const char *name);

struct myaddr { uint8_t b1, b2, b3, b4; }; 
]])

function p.gethostbyname(name)
    local hostent = ffi.C.gethostbyname(tostring(name))
    if hostent == nil then
        return {}
    else
        -- The actual hostname
        -- ffi.string(hostent.h_name)

        local hosts = {}
        local i = 0
        while i < (hostent.h_length / 4) do
            local addr = ffi.cast('struct myaddr*', hostent.h_addr_list[i])
            ---@diagnostic disable-next-line: undefined-field
            hosts[i + 1] = string.format('%d.%d.%d.%d ', addr.b1, addr.b2, addr.b3, addr.b4)
            i = i + 1
        end

        return hosts
    end
end

return p
