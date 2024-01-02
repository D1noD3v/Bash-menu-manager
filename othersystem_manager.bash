#!/bin/bash

# Script Name: system_manager.bash
# Description: A system manager for new linux users.
# Authors: Dino Brankovic, Simon Malmström
# Copyright (c) 2023 Dino Brankovic and Simon Malmström
# License: This script is licensed under the dont steal it please license (DSIP License).

# ASCII art for startup screen
art="
┏┓┓┏┏┓┏┳┓┏┓┳┳┓  ┳┳┓┏┓┳┓┏┓┏┓┏┓┳┓  ┏  ┓ ┏┓ ┏┓┏┓┓
┗┓┗┫┗┓ ┃ ┣ ┃┃┃  ┃┃┃┣┫┃┃┣┫┃┓┣ ┣┫  ┃┓┏┃ ┃┫ ┣┓┗┫┃
┗┛┗┛┗┛ ┻ ┗┛┛ ┗  ┛ ┗┛┗┛┗┛┗┗┛┗┛┛┗  ┗┗┛┻•┗┛•┗┛┗┛┛
"

# IFS is newline, iterates each line from 'art' with small delay on print for dramatic effect
clear
IFS=$'\n'
for line in $art; do
    echo "$line"
    sleep 0.2
done
read -rp "Press any key to continue..."

# Define ANSI color codes
grn='\e[0;32m'
blu='\e[0;34m'
wht='\e[0;37m'
red='\e[0;31m'
yel='\e[1;33m'

# Main menu UI
print_help(){
	echo -e "${blu}**************************************${wht}"
	echo "       SYSTEM MANAGER (v1.0.69)          "
	echo -e "${blu}--------------------------------------${wht}"
	echo ""
	echo -e "${grn}NETWORK${wht}"
	echo -e "${red}ni${wht} - Network Information"
	echo ""
	echo -e "${grn}USER UTILITY${wht}"
	echo -e "${red}ua${wht} - Create a new user"
	echo -e "${red}ul${wht} - List all logged in users"
	echo -e "${red}uv${wht} - View users properties"
	echo -e "${red}um${wht} - Modify users properties"
	echo -e "${red}ud${wht} - Delete a user"
	echo ""
	echo -e "${grn}GROUP UTILITY${wht}"
	echo -e "${red}ga${wht} - Create a new group"
	echo -e "${red}gl${wht} - List all groups, not system groups"
	echo -e "${red}gv${wht} - List all users in a group"
	echo -e "${red}gm${wht} - Add/Remove user to/from a group"
	echo -e "${red}gd${wht} - Delete group, not system group"
	echo ""
	echo -e "${grn}FOLDER UTILITY${wht}"
	echo -e "${red}fa${wht} - Create a folder"
	echo -e "${red}fl${wht} - View content of a folder"
	echo -e "${red}fv${wht} - View folder properties"
	echo -e "${red}fm${wht} - Modify folder properties"
	echo -e "${red}fd${wht} - Delete a folder"
	echo ""
	echo -e "${yel}ex${wht} - Exit the program"
}

# Logo to add for every function
sysman_logo(){
	echo -e "${blu}**************************************${wht}"
	echo "       SYSTEM MANAGER (v1.0.69)          "
	echo -e "${blu}--------------------------------------${wht}"
}

# Shows network info
show_net_info(){
	clear
	sysman_logo
	echo -e "	 ${yel}NETWORK INFORMATION${wht}"
	echo ""
	echo -e "${red}Computer name:${wht}" "$(hostname)"
	echo ""
	# Loops through all interfaces and prints out name, ip, mac, gateway and status with a color
	for interfaces in $(ip -br addr show | grep -v 'lo' | awk '{print $1}'); do
		echo -e "${grn}Interface:${wht}" "$interfaces"
		ip addr show "$interfaces" | awk '{print "\033[32m" "IP Address:", "\033[37m" $2}' | awk 'NR==3' | cut -d "/" -f 1
		ip r | grep default | grep "$interfaces" | awk '{print "\033[32m" "Gateway:", "\033[37m" $3}'
		ip addr show "$interfaces" | grep link/ | awk '{print "\033[32m" "MAC:", "\033[37m" $2}'
		echo -e "${grn}Status:${wht}" "$(ip link show | awk 'NR==3' | awk '{print $9}')"
		echo ""
	done
}

# Adds a new linux user
add_user(){
	sysman_logo
	echo -e "	  ${yel}USER CREATOR${wht}"
	echo ""
	echo "Creating a user..."
	echo ""
	read -rp "Enter username: " username
	if adduser --quiet "$username"; then
		echo '--------------------------------------'
		echo "User: '$username' has been created!"
	else
		echo "ERROR: Please try again."
	fi
}

# View properties of a certain user
user_props(){
	sysman_logo
	echo -e "	   ${yel}USER PROPERTIES${wht}"
	echo ""
	echo "Users:"
	# Prints all users with UID over 1000 that aren't called nobody from /etc/passwd to filter for only user accounts
	awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
	echo ""
	read -rp "Username: " usrnm
	echo "UserID:" "$(grep -w "^$usrnm" /etc/passwd | awk -F ":" '{print $3}')"
	echo "GroupID:" "$(grep -w "^$usrnm" /etc/passwd | awk -F ":" '{print $4}')"
	echo "Comment:" "$(grep -w "^$usrnm" /etc/passwd | awk -F ":" '{print $5}')"
	echo "Home Directory:" "$(grep -w "^$usrnm" /etc/passwd | awk -F ":" '{print $6}')"
	echo "Shell Directory:" "$(grep -w "^$usrnm" /etc/passwd| awk -F ":" '{print $7}')"
	echo "Groups:" "$(groups "$usrnm" | awk -F ":" '{print $2}')"
	echo ""
}

# Modify specific users props
user_modify(){
	sysman_logo
	echo -e "	${yel}USER PROPERTY MODIFIER${wht}"
	echo ""
	echo "User:"
	awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
	echo ""
	read -rp "Username: " mod_usr
	# If it can't find the exact username, exit the function
	if grep -q "^$mod_usr:" /etc/passwd; then
		true
	else
		echo ""
		echo "Unable to find '$mod_usr'..."
		echo ""
		return
	fi
	echo "UserID:" "$(grep -w "^$mod_usr" /etc/passwd | awk -F ":" '{print $3}')"
	echo "GroupID:" "$(grep -w "^$mod_usr" /etc/passwd| awk -F ":" '{print $4}')"
	echo "Comment:" "$(grep -w "^$mod_usr" /etc/passwd| awk -F ":" '{print $5}')"
	echo "Home Directory:" "$(grep -w "^$mod_usr" /etc/passwd| awk -F ":" '{print $6}')"
	echo "Shell Directory:" "$(grep -w "^$mod_usr" /etc/passwd| awk -F ":" '{print $7}')"
	echo "Groups:" "$(groups "$mod_usr" | awk -F ":" '{print $2}')"
	echo ""
	echo "What property would you like to modify?"
	echo ""
	echo -e "${yel}USERNAME${wht} | ${yel}GROUP${wht} | ${yel}USERID${wht} | ${yel}GROUPID${wht} | ${yel}COMMENT${wht} | ${yel}HOME${wht} | ${yel}SHELL${wht}"
	echo ""
	read -rp "> " command
	case $command in
	"username" | "USERNAME")
		echo ""
		read -rp "New username: " new_usr
		# If command ran without problem
		if usermod -l "$new_usr" "$mod_usr"; then
			echo ""
			echo "Username was successfully changed!"
		else
			echo "ERROR: Choose another username."
		fi
		echo ""
		;;
	"group" | "GROUP")
		echo ""
		echo "CHOOSE A NEW DEFAULT GROUP"
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo ""
		read -rp "New default group: " def_grp_usr
		if usermod -g "$def_grp_usr" "$mod_usr"; then
			echo ""
			echo "Group has been changed."
		else
			echo "'$mod_usr' primary group was unable to be changed."
		fi
		echo ""
		;;
	"userid" | "USERID")
		echo ""
		echo "CHOOSE A NEW USERID"
		awk -F: '$3 >= 1000 && $1 != "nobody" {print $1":",$3}' /etc/passwd
		echo ""
		read -rp "> " new_id
		echo ""
		if usermod -u "$new_id" "$mod_usr"; then
			echo "UID of '$mod_usr' has been changed to '$new_id'."
			echo ""
		else
			echo "Something went wrong! Please try another user id."
			echo ""
		fi
		;;
	"groupid" | "GROUPID")
		echo ""
		echo "CHOOSE A NEW EXISTING GROUPID"
		# Prints all groups with GID over 1000 that aren't called nogroup from /etc/group to filter for only user groups
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1":",$3}' /etc/group
		echo ""
		read -rp "> " new_gid
		echo ""
		if usermod -g "$new_gid" "$mod_usr"; then
			echo "'$mod_usr' groupid has been changed to '$new_gid'."
			echo ""
		else
			echo "Something went wrong! Please try another group id."
			echo ""
		fi
		;;
	"comment" | "COMMENT")
		echo ""
		echo "ADD A NEW COMMENT TO '$mod_usr'"
		echo ""
		read -rp "> " new_comment
		echo ""
		if usermod -c "$new_comment" "$mod_usr"; then
			echo "'$new_comment' has been added as a comment to '$mod_usr'."
			echo ""
		else
			echo "Something went wrong! Please try another comment."
			echo ""
		fi
		;;
	"home" | "HOME")
		echo ""
		echo "CHOOSE A NEW HOME DIRECTORY"
		echo ""
		read -rp "> /home/" new_home
		echo ""
		if usermod -d "/home/$new_home" "$mod_usr"; then
			echo "Changed home directory of '$mod_usr' to '/home/$new_home'."
			echo ""
		else
			echo "Something went wrong! Please try another location."
			echo ""
		fi
		;;
	"shell" | "SHELL")
		echo ""
		echo "ENTER THE NEW SHELL"
		echo ""
		read -rp "> /bin/" new_shell
		echo ""
		if usermod -s "/bin/$new_shell" "$mod_usr"; then
			echo "Changed '$mod_usr' shell from '$SHELL' to '/bin/$new_shell'."
			echo ""
		else
			echo "Something went wrong! Please try another shell."
			echo ""
		fi
		;;
	*)
		echo "ERROR... [Invalid Selection: $selection]";
		echo ""
		read -rp "Press enter to continue..."
		;;
	esac

}

# Deletes a user
delete_usr(){
	sysman_logo
	echo -e "	   ${yel}USER REMOVER${wht}"
	echo ""
	echo "Users:"
	awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
	echo ""
	read -rp "Select user: " del_usr
	deluser --remove-home "$del_usr"
	echo ""
}

# Modify a folders properties
folder_modify(){
	clear
	sysman_logo
	echo -e "	   ${yel}FOLDER MODIFIER${wht}"
	echo ""
	read -rp "Enter folder absolute PATH: " folder_name3
	echo ""
	# Exit the function if the folder specifed does not exist
	if [ ! -d "$folder_name3" ]; then
		echo "'$folder_name3' could not be found."
		return
	fi
	echo "What property would you like change?"
	echo -e "${yel}OWNER${wht} | ${yel}GROUP${wht} | ${yel}PERMISSIONS${wht} | ${yel}STICKY BIT${wht} | ${yel}SETGID${wht}"
	echo ""
	read -rp "> " command
	case $command in
	"owner"|"OWNER")
		echo ""
		echo "Available Users:"
		awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
		echo ""
		read -rp "Select new owner: " user
		echo ""
		chown -v "$user" "$folder_name3"
		;;
	"group"|"GROUP")
		echo ""
		echo "Available Groups:"
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo ""
		read -rp "Select new owner group: " grp
		echo ""
		chgrp -v "$grp" "$folder_name3"
		;;
	"permissions"|"PERMISSIONS")
		echo ""
		echo "What permissions would you like to change?"
		echo -e "${yel}(R)EAD${wht} | ${yel}(W)RITE${wht} | ${yel}E(X)ECUTE${wht} | ${yel}(A)LL${wht}"
		echo ""
		# Listens for only 1 character
		read -rp "> " -n 1 perm_select
		# Converts user's string to lowercase for simpler if-statements
		perm_select="${perm_select,,}"
		echo ""
		# If user has selected to change all permissions
		if [[ $perm_select == "a" ]]; then
			echo ""
			echo "Who's permissions do you want to change?"
			echo -e "${yel}OWNER${wht} | ${yel}GROUP${wht} | ${yel}OTHER${wht} | ${yel}ALL${wht}"
			echo ""
			read -rp "> " perm_ogo
			perm_ogo="${perm_ogo,,}"
			echo ""
			if [[ $perm_ogo == "owner" ]]; then
				if chmod u+rwx "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			elif [[ $perm_ogo == "group" ]]; then
				if chmod g+rwx "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			elif [[ $perm_ogo == "other" ]]; then
				if chmod o+rwx "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			elif [[ $perm_ogo == "all" ]]; then
				if chmod a+rwx "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			else
				echo "ERROR: Invalid selection! Please try again."
			fi
		# If user has specified to change read, write or execute permissions
		elif [[ $perm_select == "r" || $perm_select == "w" || $perm_select == "x" ]]; then
			echo ""
			echo "Who's permissions do you want to change?"
			echo -e "${yel}(U)SER OWNER${wht} | ${yel}(G)ROUP${wht} | ${yel}(O)THER${wht} | ${yel}(A)LL${wht}"
			echo ""
			read -rp "> " -n 1 perm_ogo
			echo ""
			perm_ogo="${perm_ogo,,}"
			echo ""
			echo "Do you want to (add) or (remove) this permission?"
			echo ""
			read -rp "> " perm_add_or_rem
			perm_add_or_rem="${perm_add_or_rem,,}"
			echo ""
			if [[ $perm_add_or_rem == "add" ]]; then
				# Uses user's variables as option for chmod
				if chmod "$perm_ogo"+"$perm_select" "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			elif [[ $perm_add_or_rem == "remove" ]]; then
				if chmod "$perm_ogo"-"$perm_select" "$folder_name3"; then
					echo "Permissions has been changed!"
				else
					echo "Something went wrong!"
				fi
			else
				echo "ERROR: Invalid Selection! Please try again."
			fi
		else
			echo "ERROR: Invalid selection! Please try again."
		fi
		;;
	"sticky bit"|"STICKY BIT")
		echo ""
		echo "Do you want to (add) or (remove) sticky bit for '$folder_name3'?"
		echo ""
		read -rp "> " add_rem_stick
		if [[ $add_rem_stick == "add" ]]; then
			echo ""
			# Confirmation
			echo "Are you sure? (y/n)"
			echo ""
			read -rp "> " stick_sel_a
			echo ""
			if [[ "$stick_sel_a" == "y" ]]; then
				if chmod +t "$folder_name3"; then
					echo "Sticky bit was added to '$folder_name3'."
				else
					echo "Something went wrong!"
				fi
			elif [[ "$stick_sel_a" == "n" ]]; then
				echo "No changes were made! Exiting..."
			else
				echo "ERROR: Invalid Selection! Please try again."
			fi
		elif [[ $add_rem_stick == "remove" ]]; then
			echo ""
			# Confirmations
			echo "Are you sure? (y/n)"
			read -rp "> " stick_sel_r
					if [[ "$stick_sel_r" == "y" ]]; then
							if chmod -t "$folder_name3"; then
								echo "Sticky bit was removed from '$folder_name3'."
							else
								echo "Something went wrong!"
							fi
					elif [[ "$stick_sel_r" == "n" ]]; then
							echo "No changes were made! Exiting..."
					else
							echo "ERROR: Invalid Selection! Please try again."
					fi
		fi
		;;
	"setgid"|"SETGID")
		echo ""
		echo "Do you want to (add) or (remove) SGID for '$folder_name3'?"
		echo ""
		read -rp "> " add_rem_sgid
		echo ""
		if [[ $add_rem_sgid == "add" ]]; then
			echo "Are you sure? (y/n)"
			echo ""
			read -rp "> " sgid_sel_a
			echo ""
			if [[ "$sgid_sel_a" == "y" ]]; then
				if chmod g+s "$folder_name3"; then
					echo "SGID was added to '$folder_name3'."
				else
					echo "Something went wrong!"
				fi
			elif [[ "$sgid_sel_a" == "n" ]]; then
				echo "No changes were made! Exiting..."
			else
				echo "ERROR: Invalid Selection! Please try again."
			fi
		elif [[ $add_rem_sgid == "remove" ]]; then
			echo "Are you sure? (y/n)"
			echo ""
			read -rp "> " sgid_sel_r
			echo ""
			if [[ "$sgid_sel_r" == "y" ]]; then
				if chmod g-s "$folder_name3"; then
					echo "SGID was removed from '$folder_name3'."
				else
					echo "Something went wrong!"
				fi
			elif [[ "$sgid_sel_r" == "n" ]]; then
				echo "No changes were made! Exiting..."
			else
				echo "ERROR: Invalid Selection! Please try again."
			fi
		fi 
	;;
	esac
}

# View a folder and its contents
folder_view(){
	sysman_logo
	echo -e "	   ${yel}FOLDER VIEWER${wht}"
	echo ""
	read -rp "Enter the folder's absolute PATH: " dir_name
	echo ""
	echo "PATH: $dir_name"
	# Uses stat -c to get custom formatting and % to specify the information format sequence
	echo "Owner: $(stat -c '%U' "$dir_name")"
	echo "Group: $(stat -c '%G' "$dir_name")"
	echo "Permissions: $(stat -c '%a/%A' "$dir_name")"
	echo "Sticky Bit: $(stat -c '%A' "$dir_name" | cut -c9)"
	echo "Setgid: $(stat -c '%A' "$dir_name" | cut -c6)"
	echo "Last Modified: $(stat -c '%y' "$dir_name" | cut -c-19)"
}

# Create a user group
create_grp(){
	sysman_logo
	echo -e "	   ${yel}GROUP CREATOR${wht}"
	echo ""
	echo "Creating user group..."
	echo ""
	read -rp "Enter group name: " grp_name
	echo ""
	addgroup "$grp_name"
	echo ""
}

# Modify a user group
group_modify(){
	clear
	sysman_logo
	echo -e "	   ${yel}GROUP MODIFIER${wht}"
	echo ""
	echo "Available Users:"
	awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
	echo -e "\nSelect a user: "
	read -rp "> " usr_grp_mod
	clear
	sysman_logo
	echo -e "User selected: '$usr_grp_mod'"
	echo ""
	echo "Available Groups:"
	awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
	echo ""
	echo -e "Select a group: "
	read -rp "> " grp_mod
	clear
	sysman_logo
	echo -e "User selected: '$usr_grp_mod'"
	echo -e "Group selected: '$grp_mod'"
	echo ""
	echo -e "Do you want to (add) or (remove) '$usr_grp_mod' from '$grp_mod'?"
	read -rp "> " add_or_remove
	echo ""
	if [[ "$add_or_remove" == "add" ]]; then
		if usermod -aG "$grp_mod" "$usr_grp_mod"; then
			echo "User '$usr_grp_mod' has been added to '$grp_mod'!"
			echo ""
			read -rp "Press enter to continue..."
		else
			true
			echo ""
			read -rp "Press enter to continue..."
		fi
	elif [[ "$add_or_remove" == "remove" ]]; then
		if gpasswd -d "$usr_grp_mod" "$grp_mod"; then
			echo "User '$usr_grp_mod' has been removed from '$grp_mod'!"
			echo ""
			read -rp "Press enter to continue..."
		else
			true
			echo ""
			read -rp "Press enter to continue..."
		fi
	else
		echo "Invalid selection... Try again!"
		read -rp "Press enter to continue..."
	fi
}

# Main loop
while true; do

	# Start of loop, clears terminal, prints the header and asks for selection 
    clear
    print_help
	echo ""
    read -rp "Selection > " selection;
    case $selection in

	# Network Info
    "ni")
		clear
        show_net_info
        read -rp "Press enter to continue..."
        ;;

	# Exit program
    "ex")
		clear
        echo "Quitting...";
        exit 0
        ;;

	# Create user
	"ua")
		clear
		add_user
		echo ""
		read -rp "Press enter to continue..."
		;;

	# Lists all users, not including system users
	"ul")
		clear
		sysman_logo
		echo -e "	  ${yel}USERS WITH LOGIN${wht}"
		echo ""
		echo "Users:"
		awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
		echo ""
		read -rp "Press enter to continue..."
		;;

	# View user properties
	"uv")
		clear
		user_props
		read -rp "Press enter to continue..."
		;;
		
	# Delete user
	"ud")
		clear
		delete_usr
		read -rp "Press enter to continue..."
		;;
		
	# Modify user properties
	"um")
		clear
		user_modify
		read -rp "Press enter to continue..."
		;;
		
	# Create group
	"ga")
		clear
		create_grp
		read -rp "Press enter to continue..."
		;;
		
	# Lists all user groups
	"gl")
		clear
		sysman_logo
		echo -e "	   ${yel}GROUP LIST${wht}"
		echo ""
		echo "All Groups:"
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo ""
		read -rp "Press enter to continue..."
		;;

	# View specifed group
	"gv")
		clear
		sysman_logo
		echo -e "	  ${yel}GROUP USER VIEWER${wht}"
		echo ""
		echo "Available Groups:"
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo ""
		echo "Select a group: "
		read -rp "> " grp_select
		echo ""
		# Saves the GID for later use
		GID=$(grep "^$grp_select:" /etc/group | cut -d ":" -f 3)
		echo -e "Group ID:" "$GID"
		echo -e "Primary Group User:" "$(grep ":$GID:" /etc/passwd | cut -d ":" -f 1)"
		echo -e "Other Group Members:" "$(grep ":$GID:" /etc/group | cut -d ":" -f 4-)"
		echo ""
		read -rp "Press enter to continue..."
		;;
	
	# Add/Remove user from group
	"gm")
		group_modify
		;;
	
	# Delete group
	"gd")
		clear
		sysman_logo
		echo -e "	   ${yel}GROUP REMOVER${wht}"
		echo ""
		echo "Available groups:"
        awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
        echo -e "\nSelect a group: "
		read -rp "> " grp_del
		echo ""
		groupdel "$grp_del"
		if grep -q "^$grp_del:" /etc/group; then
			echo "Group: '$grp_del' was unable to be deleted!"
		else
			echo -e "Group: '$grp_del' has been removed!"
		fi
		echo ""
		read -rp "Press enter to continue..."
		;;
	
	# Create folder
	"fa")
		clear
		sysman_logo
		echo -e "	   ${yel}FOLDER CREATOR${wht}"
		echo ""
		echo "Creating a folder..."
		echo ""
		read -rp "Desired Location: " folder_location
		read -rp "Folder Name: " folder_name
		echo ""
		echo "Available users:"
		awk -F: '$3 >= 1000 && $1 != "nobody" || $3 == 0 {print $1}' /etc/passwd
		echo ""
		read -rp "Select folder owner: " folder_owner
		echo ""
		if sudo -u "$folder_owner" mkdir "$folder_location"/"$folder_name"; then
			echo "'$folder_name' was successfully created!"
		else
			true
		fi
		echo ""
		read -rp "Press enter to continue..."
		;;

	# View content of folder
	"fl")
		clear
		sysman_logo
		echo -e "	   ${yel}FOLDER VIEWER${wht}"
		echo ""
		read -rp "Enter folder absolute PATH: " folder_name2
		echo ""
		echo "FOLDER CONTENT"
		echo ""
		ls -a --color=auto "$folder_name2"
		echo ""
		read -rp "Press enter to continue..."
		;;

	# View folder properties
	"fv")
		clear
		folder_view
		echo ""
		read -rp "Press enter to continue..."
		;;

	# Modify folder properties
	"fm")
		folder_modify
		echo ""
		read -rp "Press enter to continue..."
		;;
		
	# Delete folder
	"fd")
		clear
		sysman_logo
		echo -e "	   ${yel}FOLDER REMOVER${wht}"
		echo ""
		read -rp "Enter folder absolute PATH: " folder_name4
		if [ ! -d "$folder_name4" ]; then
			echo ""
			echo "Folder does not exist..."
			echo ""
			read -rp "Press enter to continue..."
			continue
		else
			true
		fi
		echo ""
		echo "Are you sure you want to delete '$folder_name4'? (y/n)"
		echo ""
		read -rp "> " fd_check
		echo ""
		if [[ $fd_check == "y" ]]; then
			rmdir "$folder_name4"
			if [ ! -d "$folder_name4" ]; then
				echo "'$folder_name4' was successfully deleted!"
			else
				echo "'$folder_name4' was not deleted, would you like to try and force the deletion? (y/n)"
				read -rp "> " force_chk
				if [[ $force_chk == "y" ]]; then
					rm -rf "$folder_name4"
					if [ ! -d "$folder_name4" ]; then
						echo "'$folder_name4' was successfully deleted!"
					else
						echo "'$folder_name4' was not deleted, check your permissions or try another folder."
					fi
				elif [[ $force_chk == "n" ]]; then
					echo "No changes were made! Exiting..."
				else
					echo "ERROR: Invalid selection! Please try again."
				fi
			fi
		elif [[ $fd_check == "n" ]]; then
			echo "No changes were made! Exiting..."
		else
			echo "ERROR: Invalid selection! Please try again."
		fi
		echo ""
		read -rp "Press enter to continue..."
		;;

	# If the selection is invalid
	*)
        echo "ERROR... [Invalid Selection: '$selection']"
        echo ""
		read -rp "Press enter to continue..."
        ;;		
esac
done