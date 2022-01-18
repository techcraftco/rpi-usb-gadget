Pre-built, Raspberry Pi OS-derived images to simplify using the Pi as a USB gadget.

The basic USB gadget images are a faithful reproduction of the work done by [Ben Hardill][bh],
with some additional automation wrapped around to get to a publish release on GitHub.

## Available Images

* Raspberry Pi OS
  * Lite 
  * Desktop 


## Building Images

To build you need [Packer][packer] and the [`packer-builder-arm`][pba] plugin.
To build `packer-build-arm` you need [Go][go].

With Packer and `packer-builder-arm` installed:

```
sudo packer build raspios-lite-usb-gadget-arm.json
```

You can substitute any other build specification in the call to `packer build`.

[packer]: https://www.packer.io/
[pba]: https://github.com/mkaczanowski/packer-builder-arm
[bh]: https://www.hardill.me.uk/wordpress/2020/02/21/building-custom-raspberry-pi-sd-card-images/
[go]: https://golang.org
