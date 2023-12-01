#!/bin/bash

new_band() {

	# exit condition for while loop
	quit="n"

	# intro, prompt for band name, save to temp file
	echo -en "\e\033[0;33mEnter a new band name: \033[0m"
	read band_name
	echo -n $band_name: >> bands.tmp

	# while loop for adding band members and their instruments/roles
	while [ $quit == "n" ]; do 
		echo -en "\e\033[0;33mAdd band member (\"q\" to quit adding):\033[0m "
		read band_member

		# exit condition when done adding band members
		if [ "$band_member" == "q" ]; then
			let quit="y"
		
		# read band member name, instrument/role and add both to temp file with delimiters	
		else 
			echo -n "$band_member, " >> bands.tmp
			echo -en "\e\033[0;33mEnter their instrument/role in the band:\033[0m "
			read instrument
			echo -n $instrument: >> bands.tmp
		fi
	done

	# remove trailing colon from band member entry
	truncate -s -1 bands.tmp

	# copy band/member tmp data to bands.db 
	cat bands.tmp >> bands.db

	# add newline at end of data record
	echo "" >> bands.db

	# remove temp file
	rm bands.tmp
	
}

new_band
