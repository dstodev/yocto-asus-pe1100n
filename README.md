# Overview

We are working to create a Yocto image to run on an [ASUS PE1100N](https://www.asus.com/networking-iot-servers/aiot-industrial-solutions/embedded-computers-edge-ai-systems/pe1100n/),
based on the Nvidia Jetson Orin NX 16GB SoM.

This board is supported by [an ASUS-provided JetPack package](https://www.asus.com/networking-iot-servers/aiot-industrial-solutions/embedded-computers-edge-ai-systems/pe1100n/helpdesk_download?model2Name=PE1100N),
containing various device tree files.

We are able to produce an image that boots and runs on the device, but we are
not certain ours is the correct approach--for example, [this PR in meta-tegra](https://github.com/OE4T/meta-tegra/pull/1745)
(commit `5c5de2f1b46ebe584ad46195b2083ed1157b905d`) broke our approach until we
added [nvidia-kernel-oot-dtb.bbappend](sources/meta-pe1100n/recipes-kernel/nvidia-kernel-oot/nvidia-kernel-oot-dtb_%.bbappend)
(see below).

## Questions

1. What is the recommended approach to use ASUS-provided .dtb, .dts, .dtsi, etc.
   files with a meta-tegra build?
2. Can the recommended approach allow for the ASUS package to be downloaded
   during the build, as we do now, and append to SRC_URI dynamically?
3. Which files are necessary to include, and where do we include them?

## Implementation

To support the ASUS board with Yocto, we use layers:

- [meta-openembedded](https://github.com/openembedded/meta-openembedded)
- [meta-tegra-community](https://github.com/OE4T/meta-tegra-community)
- [meta-tegra](https://github.com/OE4T/meta-tegra)
- [poky](https://github.com/yoctoproject/poky)

## Device Tree Files

The ASUS package provides various device tree files:

<!-- tree --prune -P "*.dt*" mfi_PE1100N-orin | head -->

```shell
mfi_PE1100N-orin
├── bootloader
│   ├── kernel_tegra234-p3768-0000+p3767-0000-pe1100n.dtb
│   ├── kernel_tegra234-p3768-0000+p3767-0001-pe1100n.dtb
│   ├── tegra234-bpmp-3767-0000-a02-3509-a02.dtb
│   ├── tegra234-bpmp-3767-0001-3509-a02.dtb
│   ├── tegra234-bpmp-3767-0001-3509-a02_with_odm_sigheader.dtb.encrypt
│   ├── tegra234-br-bct_b-p3767-0000-l4t.dts
│   ├── tegra234-br-bct-diag-boot.dts
│   ├── tegra234-br-bct-p3767-0000-l4t.dts
...
```

We download the ASUS package in [asus-bsp.bb](sources/meta-pe1100n/recipes-bsp/asus-binaries/asus-bsp.bb),
and use them by appending to the following recipes:

| file                                                                                                                     | source                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| [core-image-full-cmdline.bbappend](sources/meta-pe1100n/recipes-extended/images/core-image-full-cmdline.bbappend)        | [poky](https://github.com/yoctoproject/poky/blob/master/meta/recipes-extended/images/core-image-full-cmdline.bb)              |
| [tegra-bootfiles.bbappend](sources/meta-pe1100n/recipes-bsp/tegra-binaries/tegra-bootfiles_%.bbappend)                   | [meta-tegra](https://github.com/OE4T/meta-tegra/blob/master/recipes-bsp/tegra-binaries/tegra-binaries_36.4.0.bb)              |
| [nvidia-kernel-oot-dtb.bbappend](sources/meta-pe1100n/recipes-kernel/nvidia-kernel-oot/nvidia-kernel-oot-dtb_%.bbappend) | [meta-tegra](https://github.com/OE4T/meta-tegra/blob/master/recipes-kernel/nvidia-kernel-oot/nvidia-kernel-oot-dtb_36.4.0.bb) |

We also use a machine file, [pe1100n.conf](sources/meta-pe1100n/conf/machine/pe1100n.conf),
extending [p3768-0000-p3767-0000.conf](sources/meta-tegra/conf/machine/p3768-0000-p3767-0000.conf)
from `meta-tegra`.

This seems successful, as without copying the device tree files over, the device
does not boot. Adding them in this way allows the device to boot and run.

I found some discussions such as [this one](https://github.com/OE4T/meta-tegra/discussions/1455),
recommending to "install [the .dtb files] directly" by listing them in SRC_URI,
but the pattern and related changes to support it are not clear.

## Test Build

You may test the build by running `run-build.sh`, which sets the TEMPLATECONF
variable to the [orin template](sources/meta-pe1100n/conf/templates/orin/local.conf.sample):

```shell
./sources/meta-pe1100n/conf/templates/orin
├── bblayers.conf.sample
├── conf-notes.txt
├── conf-summary.txt
└── local.conf.sample
```
