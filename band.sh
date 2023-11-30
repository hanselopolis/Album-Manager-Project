#!/bin/bash

new_band() {

	# array for holding band name and memmber names
	#declare -a members
	#declare -a instruments

	# exit condition for while loop
	quit="n"

	# intro, prompt
	echo -en "\e\033[0;33mEnter a new band name: \033[0m"
	read band_name
	echo -n $band_name: >> temp_band
	
	while [ $quit == "n" ]; do 
		echo -en "\e\033[0;33mAdd band member (\"q\" to quit adding):\033[0m "
		read band_member
		if [ "$band_member" == "q" ]; then
			let quit="y"
		else 
			echo -n "$band_member, " >> temp_band
			echo -en "\e\033[0;33mEnter their instrument/role in the band:\033[0m "
			read instrument
			echo -n $instrument: >> temp_band
		fi
	done
	#echo "${band[@]}"

	#for each in "${band[@]}"; do
	#	echo -n "$each:" >> temp_band
	#done
	
	truncate -s -1 temp_band
	cat temp_band >> band_list
	echo "" >> band_list
	rm temp_band
	
}

new_band
