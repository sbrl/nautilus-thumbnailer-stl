#!/usr/bin/env bash
set +e;

infile="${1}";
outfile="${2}";
imagesize="${3}";

if [[ -z "${imagesize}" ]]; then imagesize="100"; fi
if [[ ! -r "${infile}" ]]; then
	echo "Error: Input STL file at '${infile}' doesn't appear to exist" >&2;
	exit 2;
fi

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
	xvfb (X Virtual FrameBuffer): sudo apt instll xvfb
	Optionally, if oxipng <https://github.com/shssoichiro/oxipng> output images are optimised
	If oxipng is not installed but optipng is, then optipng will be used for PNG optimisation instead (slower, since optipng is not multithreaded)
	If neither oxipng nor optipng are installed, then output images are not optimised (optimisation is recommended, as 70%+ file size reduction is typically obtained - thereby reducing thumbnail cache size)

Examples:

	path/to/std2png.sh calicat.stl calicat.png 512
	path/to/std2png.sh calicat.stl calicat.png 100
";
	exit 0;
fi

temp_dir="$(mktemp --tmpdir -d "stl2png-XXXXXXX")";

if [[ -z "${DEBUG_STL2PNG}" ]]; then 
	on_exit() {
		rm -rf "${temp_dir}";
	}
	trap on_exit EXIT;
else
	logger --tag "stl2png" --stderr "stl2png: Debug mode enabled; not deleting temporary directory at '${temp_dir}'";
fi

command_exists() {
	which $1 >/dev/null 2>&1;
	return "$?";
}

if ! command_exists openscad; then
	logger --tag "stl2png" --stderr 'stl2png: OpenSCAD does not appear to be installed or is not in your PATH. Please install it and then run "rm -rf ~/.cache/thumbnails/*" (without quotes)';
	exit 2;
fi
if ! command_exists xvfb-run; then
	logger --tag "stl2png" --stderr 'stl2png: xvfb does not appear to be installed or is in your PATH. Please install it (e.g. sudo apt install xvfb) and then run "rm -rf ~/.cache/thumbnails/*" (without quotes)';
	exit 3;
fi

cp "${infile}" "${temp_dir}/source.stl";

echo "import(\"source.stl\", convexity=10);" >"${temp_dir}/thumbnail.scad";

# We need to use xvfb here, because otherwise OpenSCAD crashes when used with the nautilus thumbnailer as it claims it can't open the display.
xvfb-run --auto-servernum openscad --imgsize "${imagesize},${imagesize}" -o "${outfile}" "${temp_dir}/thumbnail.scad" >"${temp_dir}/output.log" 2>&1;
exit_code="${?}";

if [[ "${exit_code}" -ne 0 ]]; then
	logger --tag "stl2png" --stderr "stl2png: OpenSCAD crashed wutgh message:\n$(cat "${temp_dir}/output.log")";
	cp "${temp_dir}" "/tmp/stl2png-openscad-last-run.log";
	exit 1;
fi

if command_exists oxipng; then
	oxipng -s "${outfile}";
elif command_exists optipng; then
	optipng -strip all "${outfile}";
fi
