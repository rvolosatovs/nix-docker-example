package main

import (
	"encoding/json"
	"log"
	"os"
	"text/template"
)

type Package struct {
	Name string `json:"name"`
	// TODO: Source, build recipe etc
}

type Service struct {
	Name   string                 `json:"name"`
	Config map[string]interface{} `json:"config"` // this would be a structured config specific to service
}

func main() {
	var spec struct {
		Packages []Package `json:"packages"`
		Services []Service `json:"services"`
	}
	if err := json.NewDecoder(os.Stdin).Decode(&spec); err != nil {
		log.Fatalf("Failed to decode spec: %s", err)
	}
	template.Must(template.New("flake").Parse(`{
	environment.systemPackages = [
	{{- range .Packages }}
		{{ .Name }}
	{{- end }}
	];
	services = {
	{{- range .Services }}{{ $name := .Name }}
		{{ $name }}.enable = true;
		{{- range $k, $v := .Config }}
		{{ $name }}.{{ $k }} = {{ $v }};
		{{- end }}
	{{- end }}
	};
}`)).Execute(os.Stdout, spec)
}
