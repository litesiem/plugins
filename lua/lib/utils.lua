local p = {}

function p.map(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        t[k] = f(v)
    end
    return t
end

function p.filter(tbl, f)
    local t = {}
    for k, v in pairs(tbl) do
        if f(k, v) then
            t[k] = v
        end
    end
    return t
end

function p.dump(o)
    if type(o) == 'table' then
        local s = '{\n'
        for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. p.dump(v) .. ',\n'
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function p.contains(tbl, val)
    for _, value in ipairs(tbl) do
        if value == val then
            return true
        end
    end

    return false
end

function p.printf(s, ...)
    return io.write(s:format(...))
end

-- Returns the sorted keys of table `tbl`
function p.keys(tbl)
    local keyset = {}
    local n = 0

    for k, _ in pairs(tbl) do
        n = n + 1
        keyset[n] = k
    end

    table.sort(keyset)
    return keyset
end

function p.isdigit(v)
    return tonumber(v, 10) ~= nil
end

function p.ios8601(t, sep)
    if sep == nil then
        sep = "T"
    end

    return os.date("!%Y-%m-%d" .. sep .. "%TZ", t)
end

-- remove trailing and leading whitespace from string.
function p.trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

return p
