#!/usr/bin/env bash

# Make sure the current directory is the location of this script to simplify matters
cd "$(dirname "$(readlink -f "$0")")" || exit 2;

do_install() {
	echo "COPY ${1} → ${2}";
	sudo cp "${1}" "${2}";
	exit_code="${?}";
	if [[ "${exit_code}" -ne 0 ]]; then
		echo "FAIL exit code ${exit_code}" >&2;
		exit 1;
	fi
}

echo ">>> Installing files";

do_install stl2png.sh /usr/local/bin/stl2png;
do_install stl2png.thumbnailer /usr/share/thumbnailers/;
do_install stl2png.xml /usr/share/mime/packages/;

echo ">>> Updating shared MIME-Info database cache";

sudo update-mime-database /usr/share/mime/packages

echo ">>> Install complete";
