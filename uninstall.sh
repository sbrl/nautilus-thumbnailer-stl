#!/usr/bin/env bash

# Make sure the current directory is the location of this script to simplify matters
cd "$(dirname "$(readlink -f "$0")")" || exit 2;

do_uninstall() {
	sudo rm "${1}";
	echo "DELETE ${1}";
}

echo ">>> Installing files";

do_uninstall /usr/local/bin/stl2png;
do_uninstall /usr/share/thumbnailers/stl2png.thumbnailer;
do_uninstall /usr/share/mime/packages/stl2png.xml;

echo ">>> Updating shared MIME-Info database cache";

sudo update-mime-database /usr/share/mime/packages

echo ">>> Uninstall complete";
