#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$script_dir"

build_dir="$script_dir/build"
output_file="$script_dir/Subhamon_Supantha_CV_Resume.pdf"
temporary_output="$script_dir/.Subhamon_Supantha_CV_Resume.pdf.tmp"
trap 'rm -f "$temporary_output"' 0
trap 'exit 1' HUP INT TERM

if [ ! -f cv/main.tex ]; then
    printf 'Error: CV source not found: %s\n' "$script_dir/cv/main.tex" >&2
    exit 1
fi

mkdir -p "$build_dir"

docker run --rm --user "$(id -u):$(id -g)" \
    -v "$PWD:/work" -w /work \
    texlive/texlive:latest \
    latexmk -synctex=1 -interaction=nonstopmode -file-line-error \
    -pdf -outdir=build -auxdir=build cv/main.tex

if [ ! -s build/main.pdf ]; then
    printf 'Error: expected PDF was not produced: %s\n' "$build_dir/main.pdf" >&2
    exit 1
fi

cp build/main.pdf "$temporary_output"
mv -f "$temporary_output" "$output_file"
printf 'Built CV: %s\n' "$output_file"
