#!/bin/bash
set -e

script_dir="$(cd "$(dirname "$0")" && pwd -P)"
build_dir="$script_dir/build"

help() {
	cat <<-EOF
		Usage: $(basename "$0") [ -h ] [ -c ]
		  -h, --help   Prints this message.
		  -c, --clean  Cleans the build directory before running the build.
	EOF
}

canon=$(getopt --name "$(basename "$0")" \
	--options hc \
	--longoptions help,clean \
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
	-c | --clean)
		clean=true
		;;
	--)
		shift # --
		break
		;;
	esac
	shift # option
done

clean=${clean-false}

unset TEMPLATECONF
TEMPLATECONF="$script_dir/sources/meta-pe1100n/conf/templates/orin"
export TEMPLATECONF

if $clean; then
	path="$build_dir/"
	[ "$path" != "/" ] && rm -rf "$path"*
fi

source "$script_dir/sources/poky/oe-init-build-env" "$build_dir"

bitbake core-image-full-cmdline
