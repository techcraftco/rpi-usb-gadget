package packer

import I "github.com/techcraftco/rpi-usb-gadget/images"

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
						mountpoint:   spec.bootMount
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
				type:   "shell"
				inline: spec.preSteps
			},

			for _, path in spec.sources {
				type:        "file"
				source:      "sources/\(path)"
				destination: path
			},

			{
				type:   "shell"
				inline: spec.postSteps
			},

			{
				// this is a nasty hack
				// the builds always 'fail' because of the optional `fuser`
				// command exiting with 1.
				// we check for this content in the logs to see if
				// actually built the image
				type:   "shell"
				inline: "echo ::BUILD::SUCCESS"
			},
		]
	}
}
