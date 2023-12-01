#!/bin/bash

view_all_bands() {

	# check to make sure albums.db and bands.db exist
	if ! [ -e "bands.db" ]; then
		echo -e "It appears that either your band database file is missing."
		echo -e "Add at least one band to the database and try again"

	# proceed to the listing		
	else	
		# sort the bands.db file by band name to temp files
		sort -t ':' -k 1  bands.db > bands.tmp

		while read -r line; do
			echo $line > line.tmp
			band=$(cut -d: -f1 line.tmp)
			cut -d: -f2- line.tmp > band.tmp 
			echo "$band is:"
			while read -r line; do
				IFS=":"
				for each in $line; do
					echo "	$each"
				done
			IFS=""
			done < band.tmp
			echo ""
			let counter+=1
		done < bands.tmp

		rm bands.tmp line.tmp band.tmp
	fi
}

view_all_bands
