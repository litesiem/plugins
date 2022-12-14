package main

import (
	"fmt"
	"os"
	"text/template"

	_ "embed"

	"github.com/urfave/cli/v2"
	"gopkg.in/ini.v1"
)

const (
	defaultSection     = "DEFAULT"
	configSection      = "config"
	translationSection = "translation"
)

//go:embed template.gtpl
var templateString string

func main() {
	app := cmd()
	if err := app.Run(os.Args); err != nil {
		panic(err)
	}
}

func cmd() *cli.App {
	return &cli.App{
		Name:  "lplugger",
		Usage: "convert ossim config to lua",
		Action: func(ctx *cli.Context) error {
			path := ctx.Args().Get(0)
			if path == "" {
				return fmt.Errorf("path is mandatory")
			}

			_, err := os.Stat(path)
			if err != nil {
				return err
			}

			ParseConfig(path)
			return nil
		},
	}
}

type NestedMap map[string]map[string]string

// TODO - parameterize config path
func DefaultConfig() NestedMap {
	m := make(NestedMap)

	f, err := ini.Load("samples/config.cfg")
	if err != nil {
		panic(err)
	}

	for _, s := range f.Sections() {
		m[s.Name()] = make(map[string]string)
		for _, k := range s.Keys() {
			m[s.Name()][k.Name()] = k.String()
		}
	}

	return m
}

func ParseConfig(path string) {
	f, err := ini.Load(path)
	if err != nil {
		panic(err)
	}

	c := NewOssimConfig()

	// Parse DEFAULT
	dflt := new(Default)
	err = f.Section(defaultSection).MapTo(dflt)
	if err != nil {
		panic(err)
	}
	c.Default = *dflt

	// Parse config
	cfg := new(Config)
	err = f.Section(configSection).MapTo(cfg)
	if err != nil {
		panic(err)
	}
	c.Config = *cfg

	// Parse translation
	keys := f.Section(translationSection).KeyStrings()
	for _, key := range keys {
		v, err := f.Section(translationSection).Key(key).Int()
		if err != nil {
			panic(err)
		}
		c.Translation[key] = v
	}

	// Parse rules
	fKeys := f.SectionStrings()
	for _, key := range fKeys {
		if key != defaultSection && key != configSection && key != translationSection {
			r := new(Rule)
			err := f.Section(key).MapTo(r)
			if err != nil {
				panic(err)
			}

			c.Rules = append(c.Rules, *r)
		}
	}

	t := template.Must(template.New("config").Parse(templateString))
	err = t.Execute(os.Stdout, c)
	if err != nil {
		panic(err)
	}
}
