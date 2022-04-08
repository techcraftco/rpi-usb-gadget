package rpi

#Image: {
	name:        string
	compactName: string
	version:     string
	url:         string
	arch:        "armhf" | "arm64"
	sha256Url:   string | *"\(url).sha256"
	path:        string | *"\(compactName)-\(version)-\(arch).img"
	zipPath:     string | *"\(path).zip"
}

images: [Name=_]: #Image & {
	compactName: string | *Name
}

workflow: {
	name: "Build Images"
	on: {
		push: {
			branches: ["main"]
			tags: ["v*"]
			paths: ["cue/**", "sources/**", "*.json", ".github/workflows/*.yaml"]
		}
		pull_request: {}
	}

	jobs: "build": {
		"runs-on": "ubuntu-latest"
		steps: [
			{
				uses: "actions/setup-go@v2.1.3"
				with: "go-version": "1.16"
			},
			{
				name: "Check out repo code"
				uses: "actions/checkout@v2.3.4"
			},
			{
				name: "Use latest Packer"
				uses: "hashicorp-contrib/setup-packer@v1"
			},
			{
				name: "Fetch additional packages"
				run: """
					sudo apt-get update
					sudo apt-get install tree fdisk gdisk qemu-user-static libarchive-tools psmisc tar autoconf make
					"""
			},
			{
				name: "Get packer-build-arm plugin"
				run: """
					git clone https://github.com/mkaczanowski/packer-builder-arm plugin
					cd plugin
					go mod download
					go build
					"""
			},

			for name, image in images {
				{
					name: "Build the image"
					run:  """
						cp plugin/packer-builder-arm .
						sudo packer build \(image.compactName).json || true
						test -f \(image.path)
						zip \(image.zipPath) \(image.path)
						"""
				}
			},
			{
				name: "Get the version"
				id:   "get_version"
				run:  "echo ::set-output name=VERSION::${GITHUB_REF#refs/tags/}"
			},

			{
				name: "Create release"
				id:   "create_release"
				if:   "startsWith(github.ref, 'refs/tags/v')"
				uses: "actions/create-release@v1"
				env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
				with: {
					tag_name:     "${{ github.ref }}"
					release_name: "Raspberry Pi OS USB Gadget ${{ steps.get_version.outputs.VERSION }}"
					body:         "Raspberry Pi OS Lite & Desktop with USB OTG configuration."
					draft:        true
					prerelease:   false
				}
			},

			for _, image in images {
				{
					name: "Upload release asset"
					if:   "startsWith(github.ref, 'refs/tags/v')"
					uses: "actions/upload-release-asset@v1"
					env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
					with: {
						upload_url:         "${{ steps.create_release.outputs.upload_url }}"
						asset_path:         "\(image.zipPath)"
						asset_name:         "\(image.zipPath)"
						asset_content_type: "application/zip"
					}
				}
			},
			{
				name: "Publish release"
				if:   "startsWith(github.ref, 'refs/tags/v')"
				uses: "StuYarrow/publish-release@v1"
				env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
				with: id:          "${{ steps.create_release.outputs.id }}"
			},

		]

	}

}

_sources: [
	"/etc/dnsmasq.d/usb0",
	"/etc/network/interfaces.d/usb0",
	"/lib/systemd/system/usbgadget.service",
	"/usr/local/sbin/usbgadget.sh",
]

for name, image in images {
	builds: "\(name)": {
		builders: [
			{
				type: "arm"
				file_urls: [
					image.url,
				]
				file_checksum_url:     image.sha256Url
				file_checksum_type:    "sha256"
				file_target_extension: "xz"
				file_unarchive_cmd: ["xz", "--decompress", "$ARCHIVE_PATH"]
				image_build_method:    "reuse"
				image_path:            image.path
				image_size:            "2G"
				image_type:            "dos"
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
