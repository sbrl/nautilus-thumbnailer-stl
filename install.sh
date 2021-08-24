#!/usr/bin/env bash

# Make sure the current directory is the location of this script to simplify matters
cd "$(dirname "$(readlink -f "$0")")" || exit 2;

###############################################################################

do_install() {
	echo "COPY ${1} → ${2}";
	sudo cp "${1}" "${2}";
	exit_code="${?}";
	if [[ "${exit_code}" -ne 0 ]]; then
		echo "FAIL exit code ${exit_code}" >&2;
		exit 1;
	fi
}

# Ref https://stackoverflow.com/a/29436423/1460422
yes_or_no() {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

###############################################################################

echo ">>> Installing files";

do_install stl2png.sh /usr/local/bin/stl2png;
do_install stl2png.thumbnailer /usr/share/thumbnailers/;
do_install stl2png.xml /usr/share/mime/packages/;


echo ">>> Updating shared MIME-Info database cache";

sudo update-mime-database /usr/share/mime

if [[ -d "${HOME}/.cache/thumbnails" ]]; then
	echo ">>> Emptying thumbnail cache";

	rm -r "${HOME}/.cache/thumbnails";
else
	echo ">>> Thumbnail cache doesn't exist at ${HOME}/.cache/thumbnails, so not emptying thumbnail cache";
fi


nautilus_instance_count="$(ps aux | grep -iP '[n]autilus' | wc -l)";

if [[ "${nautilus_instance_count}" -ne 0 ]]; then
	echo ">>> Nautilus must first be closed and restarted to finish installation. Found these currently running nautilus processes:";
	ps aux | grep -iP '[n]autilus';
	
	if yes_or_no "Kill the above nautilus instances now?"; then
		killall nautilus;
		echo ">>> Nautilus instances killed.";
	fi
fi


echo ">>> Install complete";
