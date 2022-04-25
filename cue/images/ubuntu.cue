package images

let version = "22.04"
let variants = ["server", "desktop"]
let architectures = ["arm64", "armhf"]

let baseUrl = "https://cdimage.ubuntu.com"

let sources = ["/etc/dnsmasq.d/usb0", "/etc/netplan/20-rpi-gadget.yaml"]

let postSteps = [
	"echo '\ndtoverlay=dwc2,dr_mode=peripheral' >> /boot/firmware/config.txt",
	"sed -i 's/rootwait/modules-load=dwc2,g_ether rootwait/' /boot/firmware/cmdline.txt",
	"sed -i 's/#DNSMASQ_EXCEPT/DNSMASQ_EXCEPT/' /etc/default/dnsmasq "
]

let ubuntu = [for v in variants for a in architectures {
	os:      "ubuntu"
	arch:    a
	variant: v
	url:     "\(baseUrl)/releases/\(version)/release/\(os)-\(version)-preinstalled-\(variant)-\(arch)+raspi.img.xz"
	shaUrl:  "\(baseUrl)/releases/\(version)/release/SHA256SUMS"
	path:    "\(os)-\(variant)-\(arch)-\(version)-\(arch).img"
	"sources": sources
	"postSteps": postSteps
	bootMount: "/boot/firmware"
}]

for i in ubuntu {
	images: "\(i.os)-\(i.variant)-\(i.arch)": i
}
