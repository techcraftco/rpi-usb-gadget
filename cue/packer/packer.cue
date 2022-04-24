package packer

import I "github.com/techcraftco/rpi-usb-gadget/images"

// TODO: this should go in the image spec
_sources: [
	"/etc/dnsmasq.d/usb0",
	"/etc/network/interfaces.d/usb0",
	"/lib/systemd/system/usbgadget.service",
	"/usr/local/sbin/usbgadget.sh",
]

#PackerBuild: {
	spec: I.#ImageSpec
	result: {
		builders: [
			{
				type: "arm"
				file_urls: [
					spec.url,
				]
				file_checksum_url:     spec.shaUrl
				file_checksum_type:    "sha256"
				file_target_extension: "xz"
				file_unarchive_cmd: ["xz", "--decompress", "$ARCHIVE_PATH"]
				image_build_method: "reuse"
				image_path:         spec.path
				image_size:         "2G"
				image_type:         "dos"
				image_partitions: [
					{
						name:         "boot"
						type:         "c"
						start_sector: "8192"
						filesystem:   "vfat"
						size:         "256M"
						mountpoint:   "/boot"
					},
					{
						name:         "root"
						type:         "83"
						start_sector: "532480"
						filesystem:   "ext4"
						size:         "0"
						mountpoint:   "/"
					},
				]
				image_chroot_env: [
					"PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin",
				]
				qemu_binary_source_path:      "/usr/bin/qemu-arm-static"
				qemu_binary_destination_path: "/usr/bin/qemu-arm-static"
			},
		]
		provisioners: [
			{
				type: "shell"
				inline: [
					"sudo apt update",
					"sudo apt install -y dnsmasq",
				]
			},

			for _, path in _sources {
				type:        "file"
				source:      "sources/\(path)"
				destination: path
			},

			{
				type: "shell"
				inline: [
					"sudo chmod +x /usr/local/sbin/usbgadget.sh",
					"sudo systemctl enable usbgadget.service",
					"echo dtoverlay=dwc2 >> /boot/config.txt",
					"echo libcomposite >> /etc/modules",
					"sed -i 's/$/ modules-load=dwc2/' /boot/cmdline.txt",
					"touch /boot/ssh",
					"echo denyinterfaces usb0 >> /etc/dhcpcd.conf",
				]
			},
		]
	}
}
