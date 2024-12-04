DEPENDS += "asus-bsp"

do_install:append() {
    install -m 0644 -t "${D}/${datadir}/tegraflash" "${RECIPE_SYSROOT}/opt/asus/"*.bin
    install -m 0644 -t "${D}/${datadir}/tegraflash" "${RECIPE_SYSROOT}/opt/asus/"*.dtb
    install -m 0644 -t "${D}/${datadir}/tegraflash" "${RECIPE_SYSROOT}/opt/asus/"*.dts*
    install -m 0644 -t "${D}/${datadir}/tegraflash" "${RECIPE_SYSROOT}/opt/asus/"*.xml
}
