#!/bin/bash
#---------------------------------------------------------------------
# Script name:	Vinyl Album Database Manager - "album_mgr.sh"
# Created by:	Hans Amelang	
# Last updated:	21 November 2023
# Purpose: 	This script allows for the creation of a database for 
#		vinyl records with ONE FILE ONLY - "albums.db"
#		Note that first there are a series of functions that
#		express data entry and modifications of records in the
#		database, followed by a main function that controls
#		database actions via a case menu.
#----------------------------------------------------------------------


# function 1: creating an album record
new_album() {

	# prompts and data entry
	echo -e "\n\e\033[1;36m>>>>> Enter a new album in the database.\033[0m"
	echo -en "\n\e\033[0;33mEnter the name of this album: \033[0m"  
	read album_name

	echo  -en "\e\033[0;33mEnter the artist for this album: \033[0m" 
	read album_artist

	echo -en "\e\033[0;33mEnter the label name for this album: \033[0m" 
	read album_label

	echo -en "\e\033[0;33mEnter the year the album was released: \033[0m"
	read album_year

	echo $album_name:$album_artist:$album_label:$album_year >> albums.db
	echo -e "\n\e\033[0;32mYou have created an entry for \"$album_name\" by $album_artist, released by $album_label in $album_year.\n\033[0m"
}

# function 2: view all albums, sorted by artist first, then by year
sorted_by_artist () {
	if ! [ -e "albums.db" ]; then
		echo -e "\n\e\033[0:31mThere doesn't appear to be anything here yet. Enter an album into the database first.\033[0m"	
	else
		echo -e "\n\e\033[1;36m>>>>> List all albums in the database: \n\033[0m"
		
		# sort the records in the database by the artist name first, then year, redirect to a temp file
		sort -t ':' -k2,2 -k4,4 albums.db > albumsorttempfile

		# format the column headers with padding
		awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
			printf format, "Artist", "Album", "Label", "Year" }'
		echo "-----------------------------------------------------------------------------"
		
		# print records in the temp file with padding - artist, album, label, year - pipe to more
		awk -F: '{ printf "%-25s %-25s %-20s %d\n", $2, $1, $3, $4 }' albumsorttempfile | more
		
		# display the number of albums in the database
		echo -e "\nThere are $(wc -l < albumsorttempfile) albums in the database."

		# delete temp file when done
		rm albumsorttempfile
	fi
}

# function 3: view all albums by a given artist, sorted by artist first then by release year
view_by_artist () {	
	echo -e "\n\e\033[1;36m>>>>> Look up all albums in the database by artist name.\033[0m"	
	echo -en "\n\e\033[0;33mEnter the artist name: \033[0m"
	read artist
	echo -e "\n\e\033[1;36mHere's everything in the database by $artist: \033[0m\n"
	sort -t ':' -k2,2 -k4,4 albums.db | grep -i "$artist" > albumsorttempfile
	#sort -t ':' -k2,2 -k4,4 albums.db > albumsorttempfile
	#grep -i "$artist" albumsorttempfile > albumsorttempfile 
	awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
        	printf format, "Artist", "Album", "Label", "Year" }'
	echo "-----------------------------------------------------------------------------"
	awk -F: '{ printf "%-25s %-25s %-20s %d\n", $2, $1, $3, $4 }' albumsorttempfile
	rm albumsorttempfile
}

# function 4: view all albums by a given label, sorted by label, then artist, then release year
view_by_label () {
        echo -e "\n\e\033[1;36m>>>>> Look up all albums in the database by label name.\033[0m"
        echo -en "\n\e\033[0;33mEnter the label name: \033[0m"
        read label
        echo -e "\n\e\033[1;36mHere's everything in the database from $label: \033[0m\n"
        sort -t ':' -k2,2 -k4,4 albums.db | grep -i "$label" > albumsorttempfile
        awk 'BEGIN { format = "%-25s %-25s %-20s %-4s\n"
                printf format, "Label", "Album", "Band/Artist", "Year" }'
        echo "-----------------------------------------------------------------------------"
        awk -F: '{ printf "%-25s %-25s %-20s %d\n", $3, $1, $2, $4 }' albumsorttempfile
        rm albumsorttempfile
}
# function 5: view a list of bands/artists with albums in the database
view_artists() {
	echo -e "\n\e\033[1;36m>>>>> View band/artist list from the database.\033[0m"
	echo -e "\nHere is a list of all bands/artists with albums in the database:"
	
	# pull the artists from field 2 in the db file, sort them by name, get the unique entries, send to a temp file
	cut -d ":" -f 2 albums.db | sort | uniq > artisttempfile

	# from the temp file, print the band names to screen with a 'tab' before for formatting, then delete the file
	while read -r band; do	
		echo "	$band"
	done < artisttempfile
	rm artisttempfile
}

# function 6: view a list of labels with albums in the database
view_labels() {
	echo -e "\n\e\033[1;36m>>>>> View label list from the database.\033[0m"
        echo -e "\nHere is a list of all labels/publishers with albums in the database:"

	# pull the label names from field 3 in the db file, sort them by name, get the unique entries, send to a temp file
	cut -d ":" -f 3 albums.db | sort | uniq > labeltempfile
        
	# from the temp file, print the label names to screen with a 'tab' before for formatting, then delete the file
	while read -r band; do
                echo "  $band"
        done < labeltempfile
        rm labeltempfile
}

# function 7: delete an album from the database
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

# funciton 8: modify an album's attributes in the database
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
                                	sed -i "/$album:$artist/d" albums.db
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
                                        sed -i "/$album:$artist/d" albums.db
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
                                        sed -i "/$album:$artist/d" albums.db
                                        echo -e "\n\e\032[0;32mAlbum updated\033[0m"
                                elif [[ "$confirm" == "n" || "$confirm" == "N" ]]; then
                                        echo -e "\e\033[0;32mAlbum modify cancelled.\033[0m"
				else
					echo -e "\e\033[0;31mIncorrect entry. Album modify aborted. Returning to main menu.\033[0m"
                                fi;;
			
			# change album release year	
			"4") echo -en "Enter a new release year for $album "
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
                                        sed -i "/$album:$artist/d" albums.db
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

# function 9 - delete the whole database, whole bunch of warnings first
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
echo -e "\e\033[1;36mand modify a database of albums by their name, artist, label, and release year\033[0m."

hold_case=0

# start function menu propmpting, hold user in loop until exit selected
while [ "$hold_case" == 0 ]; do
	
	echo -e "\n\n\n\e\033[1;36m>>>>> MAIN MENU\033[0m"
	echo -e "\n\e\033[0;32mWhat would you like to do? Please select a function by number.\033[0m"

	# function menu
	echo "	1) Add a new album to the database."
	echo "	2) View all albums in the database, sorted by band/artist."
	echo "	3) View albums from a particular band/artist."
	echo "	4) View albums from a particular label/publisher."
	echo "	5) View a list of bands/artists with albums in the database."
	echo "	6) View a list of labels/publishers with albums in the database."
	echo "	7) Delete an album from the database."
	echo "	8) Modify an album's information."
	echo -e "	\e\033[0;31m999) Delete the entire database. (CAUTION! THIS IS PERMANENT!)\033[0m"
	echo -e "\n	(Any other selection to exit the datatabse manager)"
	echo -en "\n\e\033[0;33mPlease type a selection number: \033[0m"
	read selection
	
	# case menu control
	case $selection in
		"1") new_album;;
		"2") sorted_by_artist;;
		"3") view_by_artist;;
		"4") view_by_label;;
		"5") view_artists;;
		"6") view_labels;;
		"7") delete_album;;
		"8") modify_album;;
		"999") delete_all;;
		*) echo -e "\n\e\033[0;32mThanks for using the Album Database Manager. \033[0m"
			if [ -e "albums.db" ]; then
               			echo "Album database records stored in \"albums.db\" file"
			else
				echo "No album database records stored."
			fi	
		exit;;
	esac
done
