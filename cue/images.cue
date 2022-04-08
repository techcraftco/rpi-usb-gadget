package rpi

architectures: ["armhf", "arm64"]

for arch in architectures {
	let dv = "2022-04-07"
	let v = "2022-04-04"
	images: "raspios-lite-\(arch)": {
		name:    "Raspberry Pi OS Lite (\(arch))"
		version: v
		"arch":    "\(arch)"
		url:     "https://downloads.raspberrypi.org/raspios_lite_\(arch)/images/raspios_lite_\(arch)-\(dv)/\(version)-raspios-bullseye-\(arch)-lite.img.xz"
	}

	images: "raspios-desktop-\(arch)": {
		name:    "Raspberry Pi OS Desktop"
		version: v
		"arch":    "\(arch)"
		url:     "https://downloads.raspberrypi.org/raspios_\(arch)/images/raspios_\(arch)-\(dv)/\(version)-raspios-bullseye-\(arch).img.xz"
	}
}
