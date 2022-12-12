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

function p.printf(s,...)
    return io.write(s:format(...))
end

return p
