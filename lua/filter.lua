require "luarocks.loader" -- look for luarocks

local rex = require "rex_pcre"
local config = require "configs.linux-usergroupadd"
local u = require "utils"

-- Functions used in rules
local funcs = {}

function funcs.normalize_date(val)
    -- TODO: Handle dates
    return val
end

function funcs.translate(val)
    local translation = config.translation[val]
    return translation == "" and config.translation._DEFAULT_ or translation
end

--[[ Parse rules ]]

-- Precompile regexps
for _, rule in ipairs(config._rules) do
    rule.regexp = rex.new(rule.regexp)
end

-- Fields in rule to exclude from record
local ignore_fields = {"event_type", "precheck", "regexp"}

-- Regexp to parse rule.field.value e.g. "{normalize_date($date)}"
local rule_value_pattern = [[^\{(?P<fn>[a-z_]+)\(\$(?P<fn_arg>.+)\)|\$(?P<arg>.+)\}$]]
local rule_value_regex = rex.new(rule_value_pattern)
local C = {
    MATCH_FN_NAME="fn",
    MATCH_FN_ARG="fn_arg",
    MATCH_ARG="arg"
}

-- Returns a table containing parsed fields, or nil if no rule matched the input
local function parse_line(line)
    for i, rule in ipairs(config._rules) do
        -- Find precheck or skip rule
        if rule.precheck and rule.precheck ~= "" then
            if string.find(line, rule.precheck, 0, true) == nil then
                goto continue
            end
        end

        -- Match line against regexp
        ---@diagnostic disable-next-line: undefined-field
        local _, _, matches = rule.regexp:exec(line)
        if matches == nil then
            u.printf("line does not match rule %d\n", i)
            goto continue
        end

        -- 
        local record = { plugin_id=config.DEFAULT.plugin_id }

        -- Process rule fields
        for k, v in pairs(rule) do
            
            if u.contains(ignore_fields, k) then
                goto continue_inner
            end
            
            local _,_,rule_value = rule_value_regex:exec(v)

            if rule_value == nil then
                -- Primitive value
                ---@diagnostic disable-next-line: assign-type-mismatch
                record[k] = v
            elseif rule_value[C.MATCH_FN_NAME] then
                -- Function call
                local func = funcs[rule_value[C.MATCH_FN_NAME]]
                local arg = matches[rule_value[C.MATCH_FN_ARG]]
                local value = func(arg)
                if value then
                    record[k] = value
                end
            elseif rule_value[C.MATCH_ARG] then
                -- Regexp match
                local value = matches[rule_value[C.MATCH_ARG]]
                if value then
                    record[k] = value
                end
            else
                u.printf("unknown rule field value %s", v)
            end

            ::continue_inner::
        end

        do return record end
        
        ::continue::
    end

    return nil
end

-- timestamp - Unix timestamp with seconds
function filter(_, timestamp, record)
    local parsed = parse_line(record["message"])

    if parsed == nil then
        u.printf("dropping record %s...\n", string.sub(record["message"], 0, 5))
        return -1, timestamp, record
    end

    -- Type_int_key
    -- -1 drop 0 maintain 1 update 2 update record only
    return 2, timestamp, parsed
end

-- local parsed = parse_line("Feb 22 11:47:05 localhost useradd[6995]: new user: name=apache, UID=48, GID=48, home=/usr/share/httpd, shell=/sbin/nologin")
-- print(u.dump(parsed))
