package rpi

import ( I "github.com/techcraftco/rpi-usb-gadget/images"
	P "github.com/techcraftco/rpi-usb-gadget/packer"
	G "github.com/techcraftco/rpi-usb-gadget/gha"
)

import "encoding/json"

import "encoding/yaml"

import "tool/file"

command: gen: {

	let workflow = G.#BuildImageWorkflow & {images: I.images}

	// a github workflow task
	"workflow": file.Create & {
		filename: "../.github/workflows/build.yaml"
		contents: yaml.Marshal(workflow.result)
	}

	// one task per image to construct the packer definition
	for k, v in I.images {
		let build = P.#PackerBuild & {spec: v}

		"\(k)": file.Create & {
			filename: "../\(k).json"
			contents: json.Indent(json.Marshal(build.result), "", "\t")
		}
	}
}
