package rpi

import (
	"encoding/json"
	"encoding/yaml"
	"tool/file"
)

command: gen: {

	"workflow": file.Create & {
		filename: "../.github/workflows/build.yaml"
		contents: yaml.Marshal(workflow)
	}

	for name, def in builds {
		"\(name)": file.Create & {
			filename: "../\(name).json"
			contents: json.Indent(json.Marshal(def), "", "\t")
		}
	}
}
