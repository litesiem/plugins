local config ={
    DEFAULT={
        plugin_id=1931
    },
    config={
        create_file='true',
        enable='yes',
        location='/var/log/auth.log',
        source='log',
        start='no',
        stop='no',
        type='detector',
    },
    translation={
        ['_DEFAULT_']=20000000,
        ['add']=2,
        ['failed adding user']=3,
        ['group added']=11,
        ['new group']=10,
        ['new user']=1,
    },
    _rules={
        {
            date='{normalize_date($date)}',
            device='{$device}',
            dst_ip='{$device}',
            event_type='event',
            filename='{$filepath}',
            plugin_sid='{translate($sid)}',
            precheck='useradd',
            regexp=[[(?P<date>\w{3}\s\d+\s\d+:\d+:\d+)\s+(?P<device>\S+)\s+useradd\S+\s+(?P<sid>new user|add|failed adding user)[\s:]+(?:name=|')(?P<username>[^,']+)[,'\s]+(?:UID=(?P<user_id>\d+),\s+GID=(?P<group_id>\d+),\s+home=(?P<filepath>\S+),\s+shell=(?P<shell>\S+)|to.*?group\s+'(?P<group_name>[^']+)'|(?P<reason>.*))]],
            src_ip='{$device}',
            userdata1='{$group_name}',
            userdata2='{$group_id}',
            userdata3='{$user_id}',
            userdata4='{$shell}',
            userdata5='{$reason}',
            username='{$username}',
        },
        {
            date='{normalize_date($date)}',
            device='{$device}',
            dst_ip='{$device}',
            event_type='event',
            filename='{$filepath}',
            plugin_sid='{translate($sid)}',
            precheck='groupadd',
            regexp=[[(?P<date>\w{3}\s\d+\s\d+:\d+:\d+)\s+(?P<device>\S+)\s+groupadd\S+\s+(?P<sid>new group|group added)[\s:]+(?:to\s(?P<filepath>[^:]+):\s+|name=(?P<group_name>[^\s,]+)[\s,]*|GID=(?P<group_id>\d+))+]],
            src_ip='{$device}',
            userdata1='{$group_name}',
            userdata2='{$group_id}',
        },
        {
            date='{normalize_date($date)}',
            device='{$device}',
            event_type='event',
            plugin_sid='20000000',
            regexp=[[(?P<date>\w{3}\s\d+\s\d+:\d+:\d+)\s+(?P<device>\S+)\s+(?:useradd|groupadd).*]],
            src_ip='{$device}',
        },
        
    }
}

return config
