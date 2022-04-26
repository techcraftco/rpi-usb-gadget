package images

images: [string]: #ImageSpec & {
	os:          string
	arch:        string
	variant:     string
	path:        string
	url:         string
	shaUrl:      string | *"\(url).sha256"
	zipPath:     string | *"\(path).zip"
	compactName: string | *"\(os)-\(variant)-\(arch)"
}

#ImageSpec: {
	os:          string
	arch:        "arm64" | "armhf"
	variant:     string
	url:         string
	shaUrl:      string
	path:        string
	compactName: string
	zipPath:     string
	sources: [...string]
	postSteps: [...string]
	preSteps: [...string]
	bootMount: string | *"/boot"
}
