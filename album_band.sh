#!/bin/bash

album-band() {

	# check to make sure albums.db and bands.db exist
	if ! [ -e "albums.db" ] || ! [ -e "bands.db" ]; then
		echo -e "It appears that either your album or database files are missing."
		echo -e "Please be sure to add at least one album and band to the database"
		echo -e "and try again."

	# proceed to the listing		
	else	
		# sort the albums.db and bands.db files by band name to temp files
		sort -t ':' -k2,2 -k4,4  albums.db > albums.tmp
		sort -t ':' -k 1  bands.db > bands.tmp

		# join the albums.db and bands.db into a temp file
		join -t: -1 2 -2 1 albums.tmp bands.tmp > joined.tmp
		
		counter=1

		while read -r line; do
			echo $line > line.tmp
			band=$(cut -d: -f1 line.tmp)
			album=$(cut -d: -f2 line.tmp)
			echo "Album $counter: '$album' by $band"
			echo "released by $(cut -d: -f3 line.tmp) in $(cut -d: -f4 line.tmp)"
			cut -d: -f5- line.tmp > band.tmp 
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
		done < joined.tmp

		rm *.tmp
	fi
}

album-band
