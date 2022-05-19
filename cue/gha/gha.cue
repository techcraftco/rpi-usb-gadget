package gha

import I "github.com/techcraftco/rpi-usb-gadget/images"

test: #BuildImageWorkflow & {images: I.images}

#BuildImageWorkflow: {
	images: [string]: I.#ImageSpec
	result: {
		name: "Build Images"
		on: {
			push: {
				branches: ["main"]
				tags: ["v*"]
				paths: ["cue/**", "sources/**", "*.json", ".github/workflows/*.yaml"]
			}
			pull_request: {}
		}

		// run all jobs on ubuntu
		jobs: [_]: {"runs-on": "ubuntu-latest"}

		jobs: {
			"create-release": {
				outputs: {
					"upload-url": "${{ steps.create-release.outputs.upload_url }}"
					id:           "${{steps.create-release.outputs.id}}"
				}
				steps: [{
					name: "Check out repo code"
					uses: "actions/checkout@v2.3.4"
				}, {
					id:  "get_version"
					run: "echo ::set-output name=VERSION::${GITHUB_REF#refs/tags/}"
				}, {
					name: "Create release"
					id:   "create-release"
					env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
					run: """
						gh release create ${{github.ref}} --draft --title "Raspberry Pi USB-C Gadget"
						"""
				},
				]

			}

			for name, image in images {
				"build-\(name)": {
					needs: "create-release"
					steps: [
						{
							uses: "actions/setup-go@v2.1.3"
							with: "go-version": "1.18"
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
						{
							name: "Build the image"
							run:  """
						cp plugin/packer-builder-arm .
						sudo packer build \(image.compactName).json | tee build.log || true
						grep "::BUILD::SUCCESS" build.log
						test -f \(image.path)
						zip \(image.zipPath) \(image.path)
						"""
						}, {
							name: "Upload release asset"
							env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
							run: """
							gh release upload --clobber ${{github.ref}} \(image.zipPath)
							"""
						},

					]
				}

			}
		}

	}
}
