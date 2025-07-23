#!/bin/bash



convert_file() {
    #set -euo pipefail
    arg="$1"
    filename=$(basename "$arg")
    filename="${filename%.*}"
    output_dir="output"
    mkdir -p "$output_dir"
    ffmpeg -i "$arg" -c:a alac -y "$output_dir/${filename}.caf"
    ffmpeg -i "$arg" -y "$output_dir/${filename}.wav"
}

show_help() {
cat<<EOF
How to use: $(basename "$0") <arguments>

This script converts .m4a files to .caf and .wav formats using the convert_file function.

Options:
  -h, --help                Show this help message.

Arguments:
  <file>                   A single .m4a file to convert.
  <directory>              A directory containing .m4a files to convert.

Examples:
  ./converter_audio.sh file_name.m4a                         # Convert a single file
  ./converter_audio.sh /path/to/folder                       # Convert all .m4a files in a directory

Output:
  Converted files are saved in the 'output/' directory created in the same location as this script.

EOF
}


if [[ "$1" == "--help" || "$1" == "-h" || "$1" == "" || $# -eq 0 ]]; then
    show_help
    exit 0
fi


if [[ -f "$1" && "$1"  == *.m4a ]]; then
    convert_file "$1"
    echo
    echo -e "\033[0;32m[INFO]\033[0m This file was converted. You can find your converted audio file in the output directory."

elif [ -d "$1" ]; then
    files=$(find "$1" -type f -name "*.m4a") 
    if [ -z "$files" ]; then
        echo -e "\033[0;33m[WARN]\033[0m The folder is either empty or contains no .m4a files to convert." 
    else
        for file in $files; do 
                base=$(basename "$file")
                filename="${base%.*}" 
                if [[ -f "output/${filename}.caf" && -f "output/${filename}.wav" ]]; then
                    echo
                    echo "The file ${base} already has converted files (.caf and .wav). Do you want to overwrite? [y/n]"
                    read -r input
                    if [[ "$input" == "y" || "$input" == "Y" ]]; then
                        convert_file "$file"
                        echo
                        echo -e "\033[0;32m[INFO]\033[0m This file was converted. You can find your converted audio file in the output directory."
                    else 
                        echo -e "\033[0;32m[INFO]\033[0m Skipped."
                    fi
                else
                    convert_file "$file"
                    echo
                    echo -e "\033[0;32m[INFO]\033[0m These files were converted. You can find your converted audio files in the output directory."
                fi
        done
    fi
else
    if [[ "$1" =~ - ]]; then 
        echo -e "\033[0;31m[ERROR]\033[0m Invalid command. Use --help for usage information."
    else
        if [[ -f "$1" ]]; then
            echo -e "\033[0;33m[WARN]\033[0m Only .m4a files are supported."
        else
            echo -e "\033[0;33m[WARN]\033[0m Invalid input: the path doesn't exist or contains no .m4a files."
        fi
    fi
fi
