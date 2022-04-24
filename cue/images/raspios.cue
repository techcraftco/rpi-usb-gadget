package images

_os: "raspios"
_variants: ["desktop", "lite"]
_architectures: ["arm64", "armhf"]

_distVersion: "2022-04-07"
_version:     "2022-04-04"

let sources = [
	"/etc/dnsmasq.d/usb0",
	"/etc/network/interfaces.d/usb0",
	"/lib/systemd/system/usbgadget.service",
	"/usr/local/sbin/usbgadget.sh",
]

let postSteps = [
	"sudo chmod +x /usr/local/sbin/usbgadget.sh",
	"sudo systemctl enable usbgadget.service",
	"echo dtoverlay=dwc2 >> /boot/config.txt",
	"echo libcomposite >> /etc/modules",
	"sed -i 's/$/ modules-load=dwc2/' /boot/cmdline.txt",
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
	os:      _os
	arch:    a
	variant: v
	url:     "\(baseUrl)/\(imgDir)/images/\(imgDir)-\(_distVersion)/\(_version)-raspios-bullseye-\(arch)\(nameSuffix).img.xz"
	shaUrl:  "\(url).sha256"
	path:    "\(_os)-\(variant)-\(arch)-\(_version)-\(arch).img"
	"sources": sources
	"postSteps": postSteps
}]

for i in raspios {
	images: "\(i.os)-\(i.variant)-\(i.arch)": i
}
