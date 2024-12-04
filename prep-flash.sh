#!/bin/bash
set -euo pipefail

script_dir="$(cd "$(dirname "$0")" && pwd -P)"

help() {
	cat <<-EOF
		Usage: $(basename "$0") [ -h ] [ -d <dir> ] [ -f ]
		  -h, --help       Print this message
		  -d, --build-dir  Use image from build <dir>
		  -f, --flash-dir  Prepare <dir> with flash environment
	EOF
}

canon=$(getopt --name "$(basename "$0")" \
	--options hd:f: \
	--longoptions help,build-dir:flash-dir: \
	-- "$@") || status=$?

if [ "${status-0}" -ne 0 ]; then
	help
	exit 1
fi

eval set -- "$canon"

while :; do
	case "$1" in
	-h | --help)
		help
		exit 0
		;;
	-d | --build-dir)
		build_dir="$2"
		shift # option
		;;
	-f | --flash-dir)
		flash_dir="$2"
		shift # option
		;;
	--)
		shift # --
		break
		;;
	esac
	shift # option
done

build_dir="${build_dir-$script_dir/build}"
flash_dir="${flash_dir-$(pwd -P)/flash}"

echo "Target build directory: $build_dir"
echo "Target flash directory: $flash_dir"

if [ ! -d "$build_dir" ]; then
	echo "Error: Build directory not found!: $build_dir" >&2
	exit 1
fi

if [ -d "$flash_dir" ]; then
	echo "Error: Flash directory already exists!: $flash_dir" >&2
	exit 1
fi

image_file_pattern='*/deploy/*/*/*.rootfs-*.tegraflash.tar.gz'

deployment="$(find -P "$build_dir" -type f -path "$image_file_pattern" -print -quit)"

echo "Extracting flash environment to '$flash_dir'..."

mkdir -p "$flash_dir"
cp "$deployment" "$flash_dir/tegraflash.tar.gz"
tar -C "$flash_dir" -xzf "$flash_dir/tegraflash.tar.gz" --checkpoint=.10000

echo
echo "Flash environment prepared in '$flash_dir'."
echo "Run to flash (when device is in recovery mode):"
echo "  cd $flash_dir && sudo ./initrd-flash"
