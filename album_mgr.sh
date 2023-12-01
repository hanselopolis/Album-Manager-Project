#!/bin/bash
#---------------------------------------------------------------------------
# Script name:	Vinyl Album Database Manager - "album_mgr.sh"
# Created by:	Hans Amelang	
# Last updated:	01 December 2023
# Purpose: 	This script allows for the creation of a database for 
#		vinyl records with ONE FILE ONLY - "albums.db" and a
#		database for bands/artists with ONE FILE ONLY - "bands.db".	
#---------------------------------------------------------------------------


# function 1: creating an album record in albums.db
new_album() {

	# prompts and data entry
	echo -e "\n\e\033[1;36m>>>>> Enter a new album in album database.\033[0m"
	echo -en "\n\e\033[0;33mEnter the name of this album: \033[0m"  
	read album_name

	echo  -en "\e\033[0;33mEnter the artist for this album: \033[0m" 
	read album_artist

	echo -en "\e\033[0;33mEnter the label name for this album: \033[0m" 
	read album_label

	echo -en "\e\033[0;33mEnter the year the album was released: \033[0m"
	read album_year
	
	# build album record from variables, store to albums database
	echo $album_name:$album_artist:$album_label:$album_year >> albums.db
	echo -e "\n\e\033[0;32mYou have created an entry for \"$album_name\" by $album_artist, released by $album_label in $album_year.\n\033[0m"
}

# function 2: creating a new band record in bands.db
new_band() {

        # exit condition for while loop
        quit="n"

        # intro, prompt for band name, save to temp file
	echo -e "\n\e\033[1;36m>>>>> Enter a new band in the band database.\033[0m"
        echo -en "\e\033[0;33mEnter name for this band: \033[0m"
        read band_name
        echo -n $band_name: >> bands.tmp

        # while loop for adding band members and their instruments/roles
        while [ $quit == "n" ]; do
                echo -en "\n\e\033[0;33mAdd band member (\"q\" to quit adding):\033[0m "
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

# function 3: view all albums, sorted by artist first, then by year
sorted_by_artist () {
	if ! [ -e "albums.db" ]; then
		echo -e "\n\e\033[0:31mThere doesn't appear to be anything here yet. Enter an album into the database first.\033[0m"	
	else
		echo -e "\n\e\033[1;36m>>>>> List all albums in the database: \n\033[0m"
		
		# sort the records in the database by the artist name first, then year, redirect to a temp file
		sort -t ':' -k2,2 -k4,4 albums.db > albumsort.tmp

		# format the column headers with padding
		awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
			printf format, "Artist", "Album", "Label", "Year" }'
		echo "-----------------------------------------------------------------------------"
		
		# print records in the temp file with padding - artist, album, label, year - pipe to more
		awk -F: '{ printf "%-25s %-25s %-20s %d\n", $2, $1, $3, $4 }' albumsort.tmp | less
		
		# display the number of albums in the database
		echo -e "\nThere are $(wc -l < albumsorttempfile) albums in the albums database."

		# delete temp file when done
		rm albumsort.tmp
	fi
}

# function 4: view all albums in database with album and band information
album-band() {

        # check to make sure albums.db and bands.db exist
        if ! [ -e "albums.db" ] || ! [ -e "bands.db" ]; then
                echo -e "It appears that either your album or database files are missing."
                echo -e "Please be sure to add at least one album and band to the database"
                echo -e "and try again."

        # proceed to the listing
        else
		echo -e "\n\e\033[1;36m>>>>> View all albums in the database with available artist information.\033[0m"
		echo -e "\e\033[1;36m>>>>> Note that albums without detailed band information (and vice versa)\033[0m"
		echo -e "\e\033[1;36m>>>>> will not be displayed.\n\033[0m"

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
                                        echo "  $each"
                                done
                        IFS=""
                        done < band.tmp
                        echo ""
                        let counter+=1
                done < joined.tmp

                rm albums.tmp bands.tmp joined.tmp line.tmp band.tmp
        fi
}

# function 5: view all albums by a given artist, sorted by artist first then by release year
view_by_artist () {

	# intro, prompt and entry for artist name	
	echo -e "\n\e\033[1;36m>>>>> Look up all albums in the database by artist name.\033[0m"	
	echo -en "\n\e\033[0;33mEnter the artist name: \033[0m"
	read artist

	# display table of all albums by the entered artist in the albums database
	# note that if the artist is not found in the databse, no entries will be shown
	echo -e "\n\e\033[1;36mHere's everything in the database by $artist: \033[0m\n"

	# sort the file by artist first, then release year, pipe to grep for entered artist and store to a temp file
	sort -t ':' -k2,2 -k4,4 albums.db | grep -i "$artist" > albumsort.tmp
	awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
        	printf format, "Artist", "Album", "Label", "Year" }'
	echo "-----------------------------------------------------------------------------"
	awk -F: '{ printf "%-25s %-25s %-20s %d\n", $2, $1, $3, $4 }' albumsort.tmp

	# remove the temp file when done
	rm albumsort.tmp
}

# function 6: view all albums by a given label, sorted by label, then artist, then release year
view_by_label () {

	# intro, prompt for label name
        echo -e "\n\e\033[1;36m>>>>> Look up all albums in the database by label name.\033[0m"
        echo -en "\n\e\033[0;33mEnter the label name: \033[0m"
        read label

	# display table of all albums by the entered label in the albums database
	# note that if the label is not found in the database, no entries will be shown
        echo -e "\n\e\033[1;36mHere's everything in the database from $label: \033[0m\n"

	# sort the file by artist, then release year, pupe to grep for entered label and store to temp file
        sort -t ':' -k2,2 -k4,4 albums.db | grep -i "$label" > albumsort.tmp
        awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
                printf format, "Label", "Album", "Band/Artist", "Year" }'
        echo "-----------------------------------------------------------------------------"
        awk -F: '{ printf "%-25s %-25s %-20s %d\n", $3, $1, $2, $4 }' albumsort.tmp

	# remove the temp file when done
        rm albumsort.tmp
}

# function 7: view a list of bands/artists with albums in the database
view_artists() {
	echo -e "\n\e\033[1;36m>>>>> View band/artist list from the database.\033[0m"
	echo -e "\nHere is a list of all bands/artists with albums in the database:"
	
	# pull the artists from field 2 in the db file, sort them by name, get the unique entries, send to a temp file
	cut -d ":" -f 2 albums.db | sort | uniq > artist.tmp

	# from the temp file, print the band names to screen with a 'tab' before for formatting, then delete the file
	while read -r band; do	
		echo "	$band"
	done < artist.tmp

	# remove temp file when done
	rm artist.tmp
}

# function 8: view a list of labels with albums in the database
view_labels() {
	echo -e "\n\e\033[1;36m>>>>> View label list from the database.\033[0m"
        echo -e "\nHere is a list of all labels/publishers with albums in the database:"

	# pull the label names from field 3 in the db file, sort them by name, get the unique entries, send to a temp file
	cut -d ":" -f 3 albums.db | sort | uniq > label.tmp
        
	# from the temp file, print the label names to screen with a 'tab' before for formatting, then delete the file
	while read -r band; do
                echo "  $band"
        done < label.tmp

	# remove temp file when done
        rm label.tmp
}

view_bands() {
	echo -e "\n\e\033[1;36m>>>>> View all bands with info in the bands database. \n\033[0m"
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
                        echo "'$band' is:"
                        while read -r line; do
                                IFS=":"
                                for each in $line; do
                                        echo "  $each"
                                done
                        IFS=""
                        done < band.tmp
                        echo ""
                        let counter+=1
                done < bands.tmp
		
		# remove temp files
                rm bands.tmp line.tmp band.tmp
        fi
}

# function 10: delete an album from the database
delete_album () {
	echo -e "\n\e\033[1;36m>>>>> Delete an album from the database. \033[0m"

	# prompt for album name to delete
	echo -en "\e\033[0;33m\nEnter the album name to delete: \033[0m"
	read album
	
	# prompt for album artist as a safety for searching
	echo -en "\e\033[0;33mEnter the artist for '$album': \033[0m"
	read artist
	
	# conditional to check if the album/artist combo exists in the database, allow delete if it does
	if grep -i "$album:$artist" albums.db; then

		# warning for deletion and prompt for confirmation
		echo -e "\n\033[0;31mWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\033[0m"
		echo -en "\e\033[0;33mThis action will permanently delete the entry for '$album'! Delete $album (y/n)?\033[0m "
		read choice

		# if delete confirmed, delete record and print confirmation
		if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
			sed -i "/$album:$artist/d" albums.db
			echo -e "\n\e\033[0;32mAlbum '$album' has been deleted.\033[0m"
		# if process aborted	
		else
			echo "\n\e\033[0;32mDelete aborted.\033[0m"
		fi
	# if album/artist combo does not exist or typo in user entry	
	else
		echo -e "\n\e\031[0;31mAlbum/artist not found or incorrect search term. Delete function aborted.\033[0m"
	fi
}

# function 11: modify an album's attributes in the database
modify_album() { 
	echo -e "\n\e\033[1;36m>>>>> Modify album info. \033[0m"
	
	# prompt for album info
	echo -en "\nDo you need to see a list of albums available to edit (y/n)? "
	read choice
	
	# show a list of albums in the database
	if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
		sorted_by_artist	
	fi	

	echo -en "\nWhat is the name of the album you would like to modify? "
	read album

	echo -en "What is the name of the artist for the album? "
	read artist
	
	exit=0

	# if album or artist isn't found, notify and exit
	if ! grep -i "$album:$artist" albums.db ; then
		$exit=1
		echo -e "\e\033[0:31m$album by $artist does not exist in the database. Please refer to album list and try again. \033[0m"
	fi

	# if album and artist are found
	if [ "$exit" == 0 ]; then

		# confirm find
		echo -e "\n\e\033[0:33mFound it.\033[0m"

		# store the album data record to a temp file
		grep -i "$album:$artist" albums.db > album.tmp
		
		# additional variables for current album attributes
		old_label=$(cut -d ":" -f 3 album.tmp)
		old_year=$(cut -d ":" -f 4 album.tmp) 
		
		# menu, prompt for change
		echo -e "\n\e\033[1;36m>>>>> Modifying \"$album\" by $artist\033[0m"
		echo "  1) Modify album name."
        	echo "  2) Modify album artist name."
        	echo "  3) Modify album label/publisher."
        	echo "  4) Modify album release year."
		echo -e "\n	(Any other selection to exit the album editor)"
        	echo -en "\n\e\033[0;33mPlease type a selection number: \033[0m"
        	read edit_selection

        	# case menu control
        	case $edit_selection in
			
			# change album name - note that each 'case' gets data entery, confirm warning, exit cases, etc
                	"1") echo -en "Enter a new name for $album: "
				read new_album
				echo -e "\n\e\033[0;31mWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\033[0m"
                		echo -en "\e\033[0;33mThis action will permanently modify the entry for '$album'!\033[0m "
				echo -e "\n\e\033[1;36mConfirm change:\033[0m"
                        	echo ">>>>> Current album name: $album"
                        	echo ">>>>> New album name: $new_album"
                        	echo -en "\n\e\033[0;33mAccept changes? (y/n): \033[0m"
                        	read confirm
                        	if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                                	echo "$new_album:$artist:$old_label:$old_year" >> albums.db
                                	sed -i "/$album:$artist:$old_label:$old_year/d" albums.db
                                	echo -e "\n\e\033[0:33mAlbum updated\033[0m"
				elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
					echo -e "\e\033[0;32mAlbum modify cancelled.\033[0m"
				else
                                        echo -e "\e\033[0;31mIncorrect entry. Album modify aborted. Returning to main menu.\033[0m"
                        	fi;;

			# change album artist	
                	"2") echo -en "Enter a new artist name for $album: "
				read new_artist
                                echo -e "\n\e\033[0;31mWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\033[0m"
                                echo -en "\e\033[0;33mThis action will permanently modify the entry for '$album'!\033[0m "
                                echo -e "\n\e\033[1;36mConfirm change:\033[0m"
                                echo ">>>>> Current artist for \"$album\": $artist"
                                echo ">>>>> New artist for \"$album\": $new_artist"
                                echo -en "\n\e\033[0;33mAccept changes? (y/n):\033[0m "
                                read confirm
                                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                                        echo "$album:$new_artist:$old_label:$old_year" >> albums.db
                                        sed -i "/$album:$artist:$old_label:$old_year/d" albums.db
                                	echo -e "\n\e\033[0;32mAlbum updated\033[0m"
				elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                                        echo -e "\e\033[0;32mAlbum modify cancelled.\033[0m"
				else
					echo -e "\e\033[0;31mIncorrect entry. Album modify aborted. Returning to main menu.\033[0m"
                                fi;;
			
			#change album label/publisher	
                	"3") echo -en "\n\e\033[0;33mEnter a new label/publisher for $album:\033[0m "
				read new_label
                                echo -e "\n\e\033[0;31mWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\033[0m"
                                echo -en "\e\033[0;33mThis action will permanently modify the entry for '$album'!\033[0m "
                                echo -e "\n\e\033[1;36mConfirm change:\033[0m"
                                echo ">>>>> Current label/publisher for \"$album\": $old_label"
                                echo ">>>>> New label/publisher for \"$album\": $new_label"
                                echo -en "\n\e\033[0;33mTAccept changes? (y/n):\033[0m "
                                read confirm
                                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                                        echo "$album:$artist:$new_label:$old_year" >> albums.db
                                        sed -i "/$album:$artist:$old_label:$old_year/d" albums.db
                                        echo -e "\n\e\032[0;32mAlbum updated\033[0m"
                                elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                                        echo -e "\e\033[0;32mAlbum modify cancelled.\033[0m"
				else
					echo -e "\e\033[0;31mIncorrect entry. Album modify aborted. Returning to main menu.\033[0m"
                                fi;;
			
			# change album release year	
			"4") echo -en "\n\e\033[0;33mEnter a new release year for $album:\033[0m "
				read new_year
				echo -e "\n\e\033[0;31mWARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING WARNING\033[0m"
                                echo -en "\e\033[0;33mThis action will permanently modify the entry for '$album'!\033[0m "
                                echo -e "\n\e\033[1;36mConfirm change:\033[0m"
                                echo ">>>>> Current release year for \"$album\": $old_year"
                                echo ">>>>> New release year for \"$album\": $new_year"
                                echo -en "\n\e\033[0;33mAccept changes? (y/n): \033[0m"
                                read confirm
                                if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                                        echo "$album:$artist:$old_label:$new_year" >> albums.db
                                        sed -i "/$album:$artist:$old_label:$old_year/d" albums.db
                                        echo -e "\n\e\033[0:32mAlbum updated\033[0m"
                                elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                                        echo -e "\e\033[0;32mAlbum modify cancelled.\033[0m"
                                else
                                        echo -e "\e\033[0;31mIncorrect entry. Album modify aborted. Returning to main menu.\033[0m"
                                fi;;
                	*) echo -en "Modify album aborted, back to main menu.";;
        	esac	
		
		# remove the temp file before exiting the function
		rm album.tmp
	fi
}

# function 999 - delete the whole database, whole bunch of warnings first
delete_all() {
	clear
	echo -e "\n\e\033[0;31m>>>>> DELETE DATABASE. \033[0m"
	echo -e "\n\e\033[0;31m>>>>> WARNING! WARNING! WARNING! WARNING! WARNING! \033[0m"
	echo -e "\n\e\033[0;31m>>>>> THIS ACTION WILL DELETE THE ENTIRE DATABASE. \033[0m"
	echo -e "\e\033[0;31m>>>>> THE DATABASE CANNOT BE AUTOMATICALLY RESTORED. \033[0m"
	echo -e "\e\033[0;31m>>>>> THERE IS NO BACKUP COPY OF THE DATABASE. \033[0m"
	echo -e "\n\n\e\033[0;31m>>>>> Are you sure you want to delete the entire databse? \033[0m"
	echo -en "\e\033[0;31m>>>>> (y/Y) to confirm. Anything else to cancel >>>>>>>>>>>>  \033[0m"
	read delete
	
	# delete menu
	case $delete in
		"y") rm albums.db; echo -e "\n\e\033[0;32m>Album database deleted. Add a new album to start a new database.\033[0m\n";;
		"Y") rm albums.db; echo -e "\n\e\033[0;32m>Album database deleted. Add a new album to start a new database.\033[0m\n";;
		*) echo -e "\n\e\033[0;32mDatabase deletion cancelled. Returning to menu.\033[0m\n";;
	esac
}
# start main function

# clear screen at start up
clear

# intro message and menu prompt
echo -e "\n\e\033[1;36mWelcome to the Album database manager. This will allow you to create, view,\033[0m"
echo -e "\e\033[1;36mand modify a database of albums by their name, artist, label, and release year\033\n[0m"

hold_case=0

# start function menu propmpting, hold user in loop until exit selected
while [ "$hold_case" == 0 ]; do
	
	echo -e "\n\e\033[1;36m>>>>> MAIN MENU\033[0m"

	echo -e "\n\e\033[0;32mWhat would you like to do? Please select a function by number.\033[0m"

	# function menu
	echo "	1) Add a new album to the album database."
	echo "	2) Add a new band to the band database."
	echo "	3) View all albums in the database, sorted by band/artist."
	echo "	4) View all albums in the database with artist information."
	echo "	5) View albums from a particular band/artist."
	echo "	6) View albums from a particular label/publisher."
	echo "	7) View a list of bands/artists with albums in the album database."
	echo "	8) View a list of labels/publishers with albums in the album database."
	echo "	9) View a list of all bands and their members in the band database."
	echo "	10) Delete an album from the database."
	echo "	11) Modify an album's information."
	echo -e "	\e\033[0;31m999) Delete the entire database. (CAUTION! THIS IS PERMANENT!)\033[0m"
	echo -e "\n	(Any other selection to exit the datatabse manager)"
	echo -en "\n\e\033[0;33mPlease type a selection number: \033[0m"
	read selection
	
	# case menu control
	case $selection in
		"1") new_album;;
		"2") new_band;;
		"3") sorted_by_artist;;
		"4") album-band | more;;
		"5") view_by_artist;;
		"6") view_by_label;;
		"7") view_artists;;
		"8") view_labels;;
		"9") view_bands;;
		"10") delete_album;;
		"11") modify_album;;
		"999") delete_all;;
		*) echo -e "\n\e\033[0;32mThanks for using the Album Database Manager. \033[0m"
			if [ -e "albums.db" ]; then
               			echo -e "\e\033[1;36mAlbum database records stored in \"albums.db\" file.\033[0m"
			else
				echo -e "\e\033[0;31mNo album database records stored.\033[0m"
			fi

			if [ -e "bands.db" ]; then
                                echo -e "\e\033[1;36mBand database records stored in \"bands.db\" file.\033[0m"
                        else
                                echo -e "\e\033[0;31mNo band database records stored.\033[0m"
                        fi	
		echo -e "\n"
		exit;;
	esac
done
