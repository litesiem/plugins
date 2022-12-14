-- Translation of - https://github.com/jpalanco/alienvault-ossim/blob/f74359c0c027e42560924b5cff25cdf121e5505a/os-sim/agent/src/ParserUtil.py

local rex = require("rex_pcre")
local time = require('posix.time')

local dir = (...):match("(.-)[^%.]+$")
local u = require(dir .. "utils")

local p = {}

local DATE_REGEXPS = {
    -- DC 2/15/2012 12:00:36 PM
    ["001 - dc"] = rex.new(
        [[(?P<month>\d{1,2})/(?P<day>\d{1,2})/(?P<year>\d{4})\s+(?P<hour>\d{1,2}):(?P<minute>\d\d):(?P<second>\d\d)\s+(?P<pm_am>PM|AM)]]),
    -- Syslog -- Oct 27 10:50:46
    ["002 - syslog"] = rex.new(
        [[^(?P<month>\w+)\s+(?P<day>\d{1,2})\s+(?P<hour>\d{1,2}):(?P<minute>\d\d):(?P<second>\d\d)]]),
    -- apache-error-log -- Fri Aug 07 17:52:19 2009
    ["003 - apache"] = rex.new(
        [[(\w+)\s+(?P<month>\w+)\s+(?P<day>\d{1,2})\s+(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)\s+(?P<year>\d\d\d\d)]]),
    -- syslog-ng -- Oct 27 2007 10:50:46
    ["004 - syslog-ng"] = rex.new(
        [[(?P<month>\w+)\s+(?P<day>\d{1,2})\s+(?P<year>\d\d\d\d)\s+(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)]]),
    -- bind9 -- 10-Aug-2009 07:53:44
    ["005 - bind9"] = rex.new(
        [[(?P<day>\d{1,2})-(?P<month>\w+)-(?P<year>\d\d\d\d)\s+(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)]]),
    -- Snare -- Sun Jan 28 15:15:32 2007
    ["006 - snare"] = rex.new(
        [[\S+\s+(?P<month>\S+)\s+(?P<day>\d{1,2})\s+(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)\s+(?P<year>\d+)]]),
    -- snort -- 11/08-19:19:06
    ["007 - snort"] = rex.new(
        [[^(?P<month>\d\d)/(?P<day>\d\d)(/?(?P<year>\d\d))?-(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)]]),
    -- suricata - 03/20/2012-12:12:24.376349
    ["008 - suricata-http"] = rex.new(
        [[(?P<month>\d+)/(?P<day>\d+)/(?P<year>\d+)-(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- arpwatch -- Monday, March 15, 2004 15:39:19 +0000
    ["009 - arpwatch"] = rex.new(
        [[(\w+), (?P<month>\w+) (?P<day>\d{1,2}), (?P<year>\d{4}) (?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- heartbeat -- 2006/10/19_11:40:05
    -- raslog(1581) -- 2009/03/05-11:04:36
    ["010 - heartbeat"] = rex.new(
        [[(?P<year>\d+)/(?P<month>\d+)/(?P<day>\d{1,2})[_-](?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- netgear -- 11/03/2004 19:45:46
    ["011 - etgear"] = rex.new(
        [[(?P<day>\d{1,2})/(?P<month>\d+)/(?P<year>\d{4})\s(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- tarantella -- 2007/10/18 14:38:03
    ["012 - tarantella"] = rex.new(
        [[(?P<year>\d{4})/(?P<month>\d+)/(?P<day>\d{1,2})\s(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- citrix 02/28/2013:12:00:00
    ["013 - citrix"] = rex.new(
        [[(?P<month>(0?[1-9])|(1[0-2]))/(?P<day>(1[0-9])|(2[0-9])|(3[0-1])|(0?[0-9]))/(?P<year>\d{4}):(?P<hour>\d{1,2}):(?P<minute>\d{1,2}):(?P<second>\d{1,2})]]),
    -- OSSEC -- 2007 Nov 17 06:26:18
    -- Intrushield -- 2007-Nov-17 06:26:18 CET
    ["014 - ossec"] = rex.new(
        [[(?P<year>\d{4})[-\s](?P<month>\w{3})[-\s](?P<day>\d{2})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})]]),
    -- ibm applications -- 11/03/07 19:22:22
    -- apache -- 29/Jan/2007:17:02:20
    ["015 - ibm"] = rex.new(
        [[(?P<day>\d{1,2})/(?P<month>\w+)/(?P<year>\d+)[\s:](?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- lucent brick hhmmss
    -- hhmmss,timestamp
    ["016 - lucent1"] = rex.new([[^(?P<hour>\d\d)(?P<minute>\d\d)(?P<second>\d\d),(?P<timestamp>\d+)$]]),
    ["017 - lucent2"] = rex.new([[^(?P<hour>\d\d)(?P<minute>\d\d)(?P<second>\d\d)(?:\+|\-)$]]),
    ["018 - lucent3"] = rex.new([[^(?P<hour>\d\d)(?P<minute>\d\d)(?P<second>\d\d)$]]),
    -- rrd, nagios -- 1162540224
    ["019 - rdd"] = rex.new([[^(?P<timestamp>\d+)$]]),
    -- FileZilla -- 11.03.2009 19:45:46
    ["020 - FileZilla"] = rex.new(
        [[(?P<day>\d{1,2})\.(?P<month>\d+)\.(?P<year>\d{4})\s(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- hp eva -- 2 18 2009 14 9 52
    ["021 - eva"] = rex.new(
        [[(?P<month>\d{1,2}) (?P<day>\d{1,2}) (?P<year>\d{4}) (?P<hour>\d{1,2}) (?P<minute>\d{1,2}) (?P<second>\d{1,2})]]),
    -- Websense -- Wed 14 Apr 2010 12:35:10
    -- Websense2 -- 11 Jan 2011 09:44:18 AM
    -- nessus  12 May 2012 00:00:03
    ["022 - websense2"] = rex.new(
        [[(?P<day>\d{1,2})\s+(?P<month>\w{3})\s+(?P<year>\d{4})\s+(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d)(\s+(?P<pm_am>AM|PM))?]]),
    -- Exchange Message Tracking Log -- 2011-07-08T14:13:42.237Z
    ["023 - exchange"] = rex.new(
        [[(?P<year>\d+)-(?P<month>\d+)-(?P<day>\d{1,2})T(?P<hour>\d\d):(?P<minute>\d\d):(?P<second>\d\d).+]]),
    -- SonicWall -- 2011-05-12 07 59 01
    ["024 - sonnicwall"] = rex.new(
        [[(?P<year>\d{4})-(?P<month>\d+)-(?P<day>\d{1,2})\s(?P<hour>\d+)\s(?P<minute>\d+)\s(?P<second>\d+)]]),
    -- CSV format date -- 09/30/2011,10:56:11
    ["026 - csv"] = rex.new(
        [[(?P<month>[0-9][0-9])/(?P<day>[0-3][0-9])/(?P<year>\d{4})\,(?P<hour>[0-2][0-9]):(?P<minute>[0-6][0-9]):(?P<second>[0-6][0-9])]]),
    -- honeyd -- 2011-05-17-09:42:24
    ["027 - honeyd"] = rex.new(
        [[(?P<year>\d{4})-(?P<month>\d+)-(?P<day>\d+)-(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- Epilog de logparser 2011-11-21 06: 15:02
    ["028 - Epilog"] = rex.new(
        [[(?P<year>\d{4})-(?P<month>\d+)-(?P<day>\d+)\s+(?P<hour>\d+):\s+(?P<minute>\d+):(?P<second>\d+)]]),
    -- WMI -- 20111111084344.000000-000
    ["029 - wmi"] = rex.new(
        [[(?P<year>\d{4})(?P<month>\d{2})(?P<day>\d{2})(?P<hour>\d{2})(?P<minute>\d{2})(?P<second>\d{2}).]]),
    -- 20120202 12:12:12
    ["030 - spanish"] = rex.new(
        [[(?P<year>\d{4})(?P<month>\d{2})(?P<day>\d{2}) (?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})]]),
    -- SNMPTRAP -- mar 07 feb, 2012 - 08:39:49
    ["031 - snmptrap"] = rex.new(
        [[\S+\s+(?P<day>\d{2})\s(?P<month>\w+),\s(?P<year>\d{4})\s-\s(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})]]),
    -- CheckPoint-LML-raw - 1Feb2012;0:05:58/1Feb2012 0:05:58
    ["032 - CheckPoint"] = rex.new(
        [[(?P<day>\d{1,2})(?P<month>\w+)(?P<year>\d{4})(?:\s|;)+(?P<hour>\d{1,2}):(?P<minute>\d{1,2}):(?P<second>\d{1,2})]]),
    -- Lilian Date -- 11270 02:00:16
    -- Lilian is the number of days since the beginning of the Gregorian Calendar on October 15, 1582,
    ["033 - lilian"] = rex.new(
        [[(?P<lilian>(?P<lilian_year>\d{2})(?P<lilian_days>\d+)\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2}))]]),
    ["034 - bluecoat"] = rex.new(
        [[(?P<year>\d{4})-(?P<month>\d+)-(?P<day>\d+)\s+(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    ["035 - americanFMT"] = rex.new(
        [[(?P<month>\d{2})\/(?P<day>\d{2})\/(?P<year>\d{2,4})\s+(?P<hour>\d{2}):(?P<minute>\d{2}):(?P<second>\d{2})]]),
    -- Fortigate date=2015-03-17 time=22:03:55
    ["36 - fortigate"] = rex.new(
        [[(?P<year>\d{4})-(?P<month>\d+)-(?P<day>\d+)\s+time=(?P<hour>\d+):(?P<minute>\d+):(?P<second>\d+)]]),
    -- Sophos UTM format date -- 2014:09:06-00:00:06
    ["37 - Sophos UTM"] = rex.new(
        [[(?P<year>\d{4}):(?:\s)?(?P<month>\d+):(?P<day>\d+)-(?P<hour>\d{1,2}):(?P<minute>\d{1,2}):(?P<second>\d{1,2})]]),
}

FIXED_MONTH_TRANSLATE = {
    -- ENGLISH
    jan = 1,
    feb = 2,
    mar = 3,
    apr = 4,
    may = 5,
    jun = 6,
    jul = 7,
    aug = 8,
    sep = 9,
    oct = 10,
    nov = 11,
    dec = 12,
    january = 1,
    february = 2,
    march = 3,
    april = 4,
    -- May=5,
    june = 6,
    july = 7,
    august = 8,
    september = 9,
    october = 10,
    november = 11,
    december = 12,
    -- SPANISH
    ene = 1,
    -- feb=2,
    -- mar=3,
    abr = 4,
    -- may=5,
    -- jun=6,
    -- jul=7,
    ago = 8,
    -- sep=9,
    -- oct=10,
    -- nov=11,
    dic = 12,
    enero = 1,
    febrero = 2,
    marzo = 3,
    abril = 4,
    mayo = 5,
    junio = 6,
    julio = 7,
    agosto = 8,
    septiembre = 9,
    octubre = 10,
    noviembre = 11,
    diciembre = 12
}

function convert_month_name_to_digit(month)
    -- Converts month_name into digit from 1 to 12 respectively or leave it as is if fails to convert.
    -- Returns month as digit string

    local parsed = time.strptime(month, "%b")
    local m = month

    if parsed ~= nil then
        m = time.strftime('%m', parsed)
        return m
    end

    parsed = time.strptime(month, "%B")
    if parsed ~= nil then
        m = time.strftime('%m', parsed)
        return m
    end

    m = FIXED_MONTH_TRANSLATE[string.lower(month)]

    return (m == nil or m == "") and string.lower(month) or m
end

function normalize_date(input, american_format)
    -- For adding new date formats you should only add a new regexp in the above array

    if type(input) ~= 'string' or input == "" then
        return ""
    end

    local try_other = true
    local date_match_name = ""
    local result = nil
    local local_time = time.localtime(time.time())

    local current_year = local_time.tm_year
    local current_month = local_time.tm_mon
    local current_day = local_time.tm_mday

    if american_format then
        result = DATE_REGEXPS["035 - americanFMT"].tfind(input)
        if result ~= nil then
            date_match_name = "american_syslog"
            try_other = false
        end
    end

    if try_other then
        -- Keys must be sorted
        for _, name in ipairs(u.keys(DATE_REGEXPS)) do
            _, _, result = DATE_REGEXPS[name]:tfind(input)

            if result ~= nil then
                date_match_name = name
                break
            end
        end
    end


    if not result then
        return input
    end

    -- Return a table containing all the named subgroups of the match, keyed by the subgroup name
    -- Exclude subgroups with no match
    local groups = u.filter(result, function(k, v) return v ~= false and type(k) == 'string' end)

    -- put here all sanity transformations you need
    -- 'hour' in groups
    if groups['hour'] and groups['pm_am'] then
        hour = tonumber(groups['hour'])

        if string.lower(groups['pm_am']) == "pm" then
            groups['hour'] = tostring(hour == 12 and 0 or hour + 12)
        end
    end

    if groups['timestamp'] then
        local temp       = time.localtime(tonumber(groups['timestamp']))
        groups['year']   = temp[1]
        groups['month']  = temp[2]
        groups['day']    = temp[3]
        groups['hour']   = temp[4]
        groups['minute'] = temp[5]
        groups['second'] = temp[6]
    elseif groups['lilian'] then
        local parsed = time.strptime(groups['lilian'], "%y%j %H then%M then%S")
        if parsed == nil then
            return nil
        end
    end

    -- Fix year
    year = tostring(groups['year'] or current_year)
    if string.len(year) == 2 then
        year = string.format('20%s', year)
    end

    -- Fix month
    month = tostring(groups['month'] or current_month)

    if not u.isdigit(month) then
        month = convert_month_name_to_digit(month)
    end

    -- 31st Dic fix

    if tonumber(month) == 12 and tonumber(current_month) == 1 then
        year = tostring(tonumber(current_year) - 1)
    end

    -- end of transformations
    -- now, let's go to translate string

    -- separator ' '

    --[[
        tm_year int years since 1900
        tm_mon int month of year [0,11]
        tm_mday int day of month [1, 31]
        tm_hour int hour [0,23]
        tm_min int minute [0,59]
        tm_sec int second [0,60]

        tm_wday int day of week [0=Sunday,6]
        tm_yday int day of year [0,365[
        tm_isdst int 0 if daylight savings time is not in effect
    ]]

    local date = time.mktime({
        tm_year = tonumber(year),
        tm_mon = tonumber(month) - 1,
        tm_mday = tonumber(groups['day'] or current_day),
        tm_hour = tonumber(groups['hour']),
        tm_min = tonumber(groups['minute']),
        tm_sec = tonumber(groups['second'] or 0)
    })

    if date ~= nil then
        return u.ios8601(date, ' ')
    else
        u.printf("There was an error in normalize_date(), match_regex: %s function-> InputString: %s\n", date_match_name
            , input)
    end
end

-- print(u.dump(normalize_date("Mar 29 10:36:43")))

p.normalize_date = normalize_date
return p
