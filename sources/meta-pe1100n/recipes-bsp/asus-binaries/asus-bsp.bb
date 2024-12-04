SUMMARY = "ASUS BSP binaries"
DESCRIPTION = "ASUS PE1100N BSP binaries"

LICENSE = "CLOSED"

PACKAGES = "${PN}"

SRC_URI = "https://dlcdnets.asus.com/pub/ASUS/mb/Embedded_IPC/PE1100N/PE1100N_JONXS_Orin-NX-16GB_JetPack-ssd-6.0.0_L4T-36.3.0_v2.0.5-official-20240815.tar.gz?model=PE1100N;downloadfilename=asus-bsp.tar.gz"
SRC_URI[sha256sum] = "4ff015558eaa700994d6dc0bf0ae996b4b9efc13cb44a6fdcb723cabd8806ff0"

SYSROOT_DIRS += "/opt/asus"

do_install() {
    install -d "${D}/opt/asus"
    install -m 0644 -t "${D}/opt/asus" "${WORKDIR}/mfi_PE1100N-orin/bootloader"/*.dts*
    install -m 0644 -t "${D}/opt/asus" "${WORKDIR}/mfi_PE1100N-orin/bootloader"/*.dtb
    install -m 0644 -t "${D}/opt/asus" "${WORKDIR}/mfi_PE1100N-orin/bootloader"/*.bin
    install -m 0644 -t "${D}/opt/asus" "${WORKDIR}/mfi_PE1100N-orin/bootloader"/*.xml
}

FILES:${PN} = "/opt/asus/*"
