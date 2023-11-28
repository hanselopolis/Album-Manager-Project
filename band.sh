#!/bin/bash

new_band() {
	declare -a band
	quit="n"
	echo -n "New band name: "
	read band_name
	band+=("$band_name")
	while [ $quit == "n" ]; do 
		echo -n "Add band member (n to quit adding): "
		read band_member
		if [ "$band_member" == "n" ] || [ "$band_member" == "N" ]; then
			let quit="y"
		else 
			band+=("$band_member")
		fi
	done
	echo "${band[@]}"

	for each in "${band[@]}"; do
		echo -n "$each:" >> temp_band
	done
	
	truncate -s -1 temp_band
	cat temp_band >> band_list
	echo "" >> band_list
	rm temp_band
	
}

new_band
