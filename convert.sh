#!/bin/bash

tsharkTimeFormat="e"

function readParameters() {
	while getopts ":f:o:t:y:" option
	do
		case $option in
			f) formatCsv="$OPTARG"
			;;
			o) outputFile="$OPTARG"
			;;
			t) tsharkTimeFormat="$OPTARG"
			;;
			y) tsharkDisplayFilter="-Y $OPTARG"
			;;
			\?) echo "Invalid option -$OPTARG" >&2
            printHelp
			exit 1
			;;
		esac

		case $OPTARG in
			-*) echo "Option $opt needs a valid argument" >&2
			printHelp
			exit 1
			;;
		esac
	done
	shift $((OPTIND-1))
    pcapngFiles=( $@ )

	if [ -z "$formatCsv" ]
	then
		echo "Need to provide a valid format specification file!" >&2
		printHelp
		exit 1
	fi
	if [ -z "$pcapngFiles" ]
	then
		echo "Need to provide a PCAPNG file to transform!" >&2
		printHelp
		exit 1
	fi
	if [ -z "$outputFile" ]
	then
		echo "Need to provide a output file!" >&2
		printHelp
		exit 1
	fi
}

function readCsvFormat() {
	echo "Reading CSV format specification from '$formatCsv'"
	# Read all the fields that should be extracted
	IFS="," read -r -a tsharkFields < $formatCsv

	tsharkFieldParams=""

	echo "Going to extract the following fields:"
	for field in "${tsharkFields[@]}"
	do
	  echo "  - $field"
	  tsharkFieldParams="$tsharkFieldParams -e $field"
	done
}

function transformPcapng() {
	echo "Transforming data to '$outputFile'. This might take a while..."

	csvHeader=$(head -n 1 $formatCsv)
	echo "$csvHeader" > $outputFile

	for file in "${pcapngFiles[@]}"
	do
		echo "Transforming $file..."
		tshark \
			-T fields \
			-t $tsharkTimeFormat \
			$tsharkDisplayFilter \
			-E separator=, \
			-E quote=d \
			$tsharkFieldParams \
			-r $file >> $outputFile
	done

	echo "Done!"
}

function printHelp() {
	echo "$0 -f <format-file.csv> -o <output.csv> [-t <tshark time format>] [-y <display filter>] <input.pcap> [<input2.pcap> ...]" >&2
	echo "" >&2
	echo "Usage:" >&2
	echo "  -f <format-file.csv>" >&2
	echo "     A CSV file with all the tshark fields in the order they should be extracted." >&2
	echo "     Ends up as the header of the CSV. See 'tshark -G fields' for options" >&2
	echo "     To get a timestamp in the format you want, use the '_ws.col.Time' column name" >&2
	echo "     and use the -t parameter to format it with the same values as for tshark." >&2
	echo "  -i <input.pcapng>" >&2
	echo "     The PCAPNG file with the packets you want to extract" >&2
	echo "  -o <output.csv>" >&2
	echo "     The output CSV file" >&2
	echo "  -t <tshark time format>" >&2
	echo "     The time format for the '_ws.col.Time' column. Defaults: 'e' (secs since epoch)" >&2
	echo "  -y <display filter>" >&2
	echo "     The filter to apply in Wireshark display filter syntax" >&2

}

readParameters $@
readCsvFormat
transformPcapng


