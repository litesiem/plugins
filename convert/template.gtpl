local config ={
    DEFAULT={
        plugin_id={{ .Default.PluginID }}
    },
    config={
        {{- range $k, $v := .ConfigMap }}
        {{ $k }}='{{ $v }}',
        {{- end}}
    },
    translation={
        {{- range $k, $v := .Translation }}
        ['{{ $k }}']={{ $v }},
        {{- end}}
    },
    _rules={
        {{ range .RuleMaps -}}
        {
            {{- range $k, $v := . -}}
                {{ if eq $k "regexp" }}
            {{ $k }}=[[{{ $v }}]],
                {{- else}}
            {{ $k }}='{{ $v }}',
                {{- end -}}
            {{end}}
        },
        {{end}}
    }
}

return config
