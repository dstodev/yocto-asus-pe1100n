DEPENDS += "asus-bsp"

my_install() {
    mkdir -p "${EXTERNAL_KERNEL_DEVICETREE}"
    install -m 0644 "${RECIPE_SYSROOT}/opt/asus/"*.dtb "${EXTERNAL_KERNEL_DEVICETREE}"
}

python do_rootfs:append () {
    bb.build.exec_func('my_install', d)
}
