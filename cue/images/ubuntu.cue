package images

let version = "22.04"

let variants = {
	"server": ["arm64", "armhf"]

	// there's no armhf desktop SHAs
	// the desktop images are too big for GitHub releases
	// "desktop": ["arm64"]
}

let baseUrl = "https://cdimage.ubuntu.com"

let sources = [
	"/etc/dnsmasq.d/usb0",
	"/etc/netplan/20-rpi-gadget.yaml"]

let preSteps = [
	"rm /etc/resolv.conf",
	"echo 'nameserver 1.1.1.1' > /etc/resolv.conf",
	"sudo apt update",
	"sudo apt install -y dnsmasq avahi-daemon",
]

let postSteps = [
	"echo '\ndtoverlay=dwc2,dr_mode=peripheral' >> /boot/firmware/config.txt",
	"sed -i 's/rootwait/modules-load=dwc2,g_ether rootwait/' /boot/firmware/cmdline.txt",
	"sed -i 's/#DNSMASQ_EXCEPT/DNSMASQ_EXCEPT/' /etc/default/dnsmasq ",
	"echo port=0 >> /etc/dnsmasq.conf",
	"echo interface=usb0 >> /etc/dnsmasq.conf",
]

let ubuntu = [ for v, as in variants for a in as {
	os:          "ubuntu"
	arch:        a
	variant:     v
	url:         "\(baseUrl)/releases/\(version)/release/\(os)-\(version)-preinstalled-\(variant)-\(arch)+raspi.img.xz"
	shaUrl:      "\(baseUrl)/releases/\(version)/release/SHA256SUMS"
	path:        "\(os)-\(variant)-\(arch)-\(version)-\(arch).img"
	"sources":   sources
	"postSteps": postSteps
	"preSteps":  preSteps
	bootMount:   "/boot/firmware"
}]

for i in ubuntu {
	images: "\(i.os)-\(i.variant)-\(i.arch)": i
}
