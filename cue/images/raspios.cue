package images

_os: "raspios"
_variants: ["desktop", "lite"]
_architectures: ["arm64", "armhf"]

_distVersion: "2022-04-07"
_version:     "2022-04-04"

let sources = [
	"/etc/dnsmasq.d/usb0",
	"/etc/network/interfaces.d/usb0",
]

let preSteps = [
	"sudo apt update",
	"sudo apt install -y dnsmasq",
]

let postSteps = [
	"echo dtoverlay=dwc2,dr_mode=peripheral >> /boot/config.txt",
	"sed -i 's/$/ modules-load=dwc2,g_ether/' /boot/cmdline.txt",
	"touch /boot/ssh",
	"echo denyinterfaces usb0 >> /etc/dhcpcd.conf",
]

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
	os:          _os
	arch:        a
	variant:     v
	url:         "\(baseUrl)/\(imgDir)/images/\(imgDir)-\(_distVersion)/\(_version)-raspios-bullseye-\(arch)\(nameSuffix).img.xz"
	shaUrl:      "\(url).sha256"
	path:        "\(_os)-\(variant)-\(arch)-\(_version)-\(arch).img"
	"sources":   sources
	"postSteps": postSteps
	"preSteps":  preSteps
}]

for i in raspios {
	images: "\(i.os)-\(i.variant)-\(i.arch)": i
}
