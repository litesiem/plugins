local config ={
    DEFAULT={
        {{- range $k, $v := .DefaultParsed }}
        {{ $k }}='{{ $v }}',
        {{- end}}
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
