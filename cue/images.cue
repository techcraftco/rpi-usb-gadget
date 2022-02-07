package rpi

architectures: ["armhf", "arm64"]

for arch in architectures {
	images: "raspios-lite-\(arch)": {
		name:    "Raspberry Pi OS Lite (\(arch))"
		version: "2022-01-28"
		"arch":    "\(arch)"
		url:     "https://downloads.raspberrypi.org/raspios_lite_\(arch)/images/raspios_lite_\(arch)-\(version)/\(version)-raspios-bullseye-\(arch)-lite.zip"
	}

	images: "raspios-desktop-\(arch)": {
		name:    "Raspberry Pi OS Desktop"
		version: "2022-01-28"
		"arch":    "\(arch)"
		url:     "https://downloads.raspberrypi.org/raspios_\(arch)/images/raspios_\(arch)-\(version)/\(version)-raspios-bullseye-\(arch).zip"
	}
}
