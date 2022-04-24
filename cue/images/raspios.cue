package images

_os: "raspios"
_variants: ["desktop", "lite"]
_architectures: ["arm64", "armhf"]

_distVersion: "2022-04-07"
_version:     "2022-04-04"

let baseUrl = "https://downloads.raspberrypi.org"

let raspios = [ for v in _variants for a in _architectures {
	let variantPrefix = [
		if v == "desktop" {""},
		{"\(v)_"},
	][0]

	let imgDir = "raspios_\(variantPrefix)\(arch)"

	let nameSuffix = [
		if v == "desktop" {""},
		{"-\(v)"},

	][0]
	os:      _os
	arch:    a
	variant: v
	url:     "\(baseUrl)/\(imgDir)/images/\(imgDir)-\(_distVersion)/\(_version)-raspios-bullseye-\(arch)\(nameSuffix).img.xz"
	shaUrl:  "\(url).sha256"
	path:    "\(_os)-\(variant)-\(arch)-\(_version)-\(arch).img"
}]

for i in raspios {
	images: "\(i.os)-\(i.variant)-\(i.arch)": i
}
