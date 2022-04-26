package gha

import I "github.com/techcraftco/rpi-usb-gadget/images"

import "list"

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
					id: "${{steps.create-release.outputs.id}}"
				}
				steps: [ {
					name: "Create release"
					id:   "create-release"
					//if:   "startsWith(github.ref, 'refs/tags/v')"
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
				]

			}

			for name, image in images {
				"build-\(name)": {
					needs: "create-release"
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
						{
							name: "Build the image"
							run:  """
						cp plugin/packer-builder-arm .
						sudo packer build \(image.compactName).json | tee build.log || true
						grep "::BUILD::SUCCESS" build.log
						test -f \(image.path)
						zip \(image.zipPath) \(image.path)
						"""
						},
						{
							name: "Upload release asset"
							//if:   "startsWith(github.ref, 'refs/tags/v')"
							uses: "actions/upload-release-asset@v1"
							env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
							with: {
								upload_url:         "${{ needs.create-release.outputs.upload-url }}"
								asset_path:         "\(image.zipPath)"
								asset_name:         "\(image.zipPath)"
								asset_content_type: "application/zip"
							}
						},


					]
				}

				"publish-release": {
					let buildJobs = [for name,_ in I.images {"build-\(name)"}]
					needs: list.FlattenN(["create-release", buildJobs], 1)
					steps: [
						{
							name: "Publish release"
							if:   "startsWith(github.ref, 'refs/tags/v')"
							uses: "StuYarrow/publish-release@v1"
							env: GITHUB_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
							with: id:          "${{ needs.create-release.outputs.id }}"
						},
					]
				}
			}
		}

	}
}
