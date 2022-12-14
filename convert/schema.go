package main

import (
	"regexp"
	"strings"

	"github.com/mitchellh/mapstructure"
)

type OssimConfig struct {
	Default     Default        `ini:"DEFAULT,omitempty" mapstructure:"DEFAULT,omitempty"`
	Config      Config         `ini:"config,omitempty" mapstructure:"config,omitempty"`
	Translation map[string]int `ini:"translation,omitempty" mapstructure:"translation,omitempty"` // must include _DEFAULT_
	Rules       []Rule         `ini:"rules,omitempty" mapstructure:"rules,omitempty"`
}

// TODO: Add dst_ip, dst_port
type Default struct {
	PluginID string `ini:"plugin_id,omitempty" mapstructure:"plugin_id,omitempty"`
	DstIp    string `ini:"dst_ip,omitempty" mapstructure:"dst_ip,omitempty"`
	DstPort  string `ini:"dst_port,omitempty" mapstructure:"dst_port,omitempty"`
}

// TODO: Add exclude_sids
type Config struct {
	Type       string `ini:"type,omitempty" mapstructure:"type,omitempty"`         // detector
	Enable     string `ini:"enable,omitempty" mapstructure:"enable,omitempty"`     // yes
	Source     string `ini:"source,omitempty" mapstructure:"source,omitempty"`     // log
	Location   string `ini:"location,omitempty" mapstructure:"location,omitempty"` // path
	CreateFile string `ini:"create_file,omitempty" mapstructure:"create_file,omitempty"`
	Process    string `ini:"process,omitempty" mapstructure:"process,omitempty"`
	Start      string `ini:"start,omitempty" mapstructure:"start,omitempty"` // yes/no
	Stop       string `ini:"stop,omitempty" mapstructure:"stop,omitempty"`   // yes/no
	Startup    string `ini:"startup,omitempty" mapstructure:"startup,omitempty"`
	Shutdown   string `ini:"shutdown,omitempty" mapstructure:"shutdown,omitempty"`
}

type Rule struct {
	EventType string `ini:"event_type,omitempty" mapstructure:"event_type,omitempty"`
	Precheck  string `ini:"precheck,omitempty" mapstructure:"precheck,omitempty"`
	Regexp    string `ini:"regexp,omitempty" mapstructure:"regexp,omitempty"`
	Date      string `ini:"date,omitempty" mapstructure:"date,omitempty"`
	PluginSid string `ini:"plugin_sid,omitempty" mapstructure:"plugin_sid,omitempty"`
	Device    string `ini:"device,omitempty" mapstructure:"device,omitempty"`
	SrcIP     string `ini:"src_ip,omitempty" mapstructure:"src_ip,omitempty"`
	DstIP     string `ini:"dst_ip,omitempty" mapstructure:"dst_ip,omitempty"`
	Username  string `ini:"username,omitempty" mapstructure:"username,omitempty"`
	Filename  string `ini:"filename,omitempty" mapstructure:"filename,omitempty"`
	Userdata1 string `ini:"userdata1,omitempty" mapstructure:"userdata1,omitempty"`
	Userdata2 string `ini:"userdata2,omitempty" mapstructure:"userdata2,omitempty"`
	Userdata3 string `ini:"userdata3,omitempty" mapstructure:"userdata3,omitempty"`
	Userdata4 string `ini:"userdata4,omitempty" mapstructure:"userdata4,omitempty"`
	Userdata5 string `ini:"userdata5,omitempty" mapstructure:"userdata5,omitempty"`
}

func NewOssimConfig() *OssimConfig {
	var c OssimConfig
	c.Translation = make(map[string]int)
	c.Rules = make([]Rule, 0)
	return &c
}

func (c *OssimConfig) DefaultMap() (map[string]string, error) {
	v := make(map[string]string)
	err := mapstructure.Decode(c.Default, &v)
	if err != nil {
		return v, err
	}

	return v, nil
}

var configPattern = regexp.MustCompile(`\\_CFG\((?P<section>[^,]+),(?P<key>[^,]+)\)`)

func (c *OssimConfig) DefaultParsed() (map[string]string, error) {
	cfg := DefaultConfig()
	v := make(map[string]string)
	err := mapstructure.Decode(c.Default, &v)

	for kk, vv := range v {
		if strings.HasPrefix(vv, `\_CFG`) {
			match := configPattern.FindStringSubmatch(vv)
			result := make(map[string]string)
			for i, name := range configPattern.SubexpNames() {
				if i != 0 && name != "" {
					result[name] = match[i]
				}
			}

			v[kk] = cfg[result["section"]][result["key"]]
		}
	}

	if err != nil {
		return v, err
	}

	return v, nil
}

func (c *OssimConfig) ConfigMap() (map[string]string, error) {
	v := make(map[string]string)
	err := mapstructure.Decode(c.Config, &v)
	if err != nil {
		return v, err
	}

	return v, nil
}

func (c *OssimConfig) RuleMaps() ([]map[string]string, error) {
	rs := make([]map[string]string, 0)

	for _, r := range c.Rules {
		v := make(map[string]string)
		err := mapstructure.Decode(r, &v)
		if err != nil {
			return rs, err
		}
		rs = append(rs, v)
	}

	return rs, nil
}
