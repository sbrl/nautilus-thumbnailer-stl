#!/usr/bin/env bash

infile="${1}";
outfile="${2}";
imagesize="${3}";

if [[ -z "${imagesize}" ]]; then imagesize="100"; fi

if [[ -z "${outfile}" ]]; then
	echo "std2png.sh - Convert STL files to PNG images
	By Starbeamrainbowlabs

Thanks to https://3dprinting.stackexchange.com/a/6047/30537 for the idea.

Usage:
	path/to/stl2png.sh path/to/infile.stl path/to/outfile.png image_size
	
	...where:
		path/to/infile.stl	is the path to the input stl file to convert
		path/to/outfile.png	is the path to the output PNG image to write
		image_size			is the size of the image to render as a single positive integer (images are always square)

Requirements:
	OpenSCAD <https://openscad.org/> must be installed
	Optionally, if Oxipng <https://github.com/shssoichiro/oxipng> output images are optimised.

Examples:

	path/to/std2png.sh calicat.stl calicat.png 512
	path/to/std2png.sh calicat.stl calicat.png 100
";
	exit 0;
fi

temp_dir="$(mktemp --tmpdir -d "stl2png-XXXXXXX")";

on_exit() {
	rm -rf "${temp_dir}";
}
trap on_exit EXIT;



command_exists() {
	which $1 >/dev/null 2>&1;
	return "$?";
}

if ! command_exists openscad; then
	logger --tag "stl2png" --stderr 'stl2png: OpenSCAD does not appear to be installed or is in your PATH. Please install it and then run "rm -rf ~/.cache/thumbnails/*" (without quotes)';
	exit 1;
fi

ln -s "${infile}" "${temp_dir}/target.stl"

echo "import(\"${temp_dir}/target.stl\", convexity=10);" >"${temp_dir}/thumbnail.scad";

openscad --imgsize "${imagesize},${imagesize}" -o "${outfile}";

if command_exists oxipng; then
	oxipng -s "${outfile}";
fi
