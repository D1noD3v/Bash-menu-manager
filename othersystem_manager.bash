#!/bin/bash

# Script Name: system_manager.bash
# Description: A system manager for new linux users.
# Authors: Dino Brankovic, Simon Malmström
# Copyright (c) 2023 Dino Brankovic and Simon Malmström
# License: This script is licensed under the dont steal it please license (DSIP License).

art="
┏┓┓┏┏┓┏┳┓┏┓┳┳┓  ┳┳┓┏┓┳┓┏┓┏┓┏┓┳┓  ┏  ┓ ┏┓ ┏┓┏┓┓
┗┓┗┫┗┓ ┃ ┣ ┃┃┃  ┃┃┃┣┫┃┃┣┫┃┓┣ ┣┫  ┃┓┏┃ ┃┫ ┣┓┗┫┃
┗┛┗┛┗┛ ┻ ┗┛┛ ┗  ┛ ┗┛┗┛┗┛┗┗┛┗┛┛┗  ┗┗┛┻•┗┛•┗┛┗┛┛
"

IFS=$'\n'
for line in $art; do
    echo "$line"
    sleep 0.2
done
read -p "Press any key to continue..."

#define ANSI color codes
grn='\e[0;32m'
blu='\e[0;34m'
wht='\e[0;37m'
red='\e[0;31m'
yel='\e[1;33m'

# main menu UI
print_help(){
echo -e "${blu}*****************************************${wht}"
echo "       
┏┓┓┏┏┓┏┳┓┏┓┳┳┓  ┳┳┓┏┓┳┓┏┓┏┓┏┓┳┓  ┏  ┓ ┏┓ ┏┓┏┓┓
┗┓┗┫┗┓ ┃ ┣ ┃┃┃  ┃┃┃┣┫┃┃┣┫┃┓┣ ┣┫  ┃┓┏┃ ┃┫ ┣┓┗┫┃
┗┛┗┛┗┛ ┻ ┗┛┛ ┗  ┛ ┗┛┗┛┗┛┗┗┛┗┛┛┗  ┗┗┛┻•┗┛•┗┛┗┛┛"
echo -e "${blu}-----------------------------------------${wht}"
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
echo -e "${red}ex${wht} - Exit the program"
}

#logo to add for every function
sysman_logo(){
echo -e "${blu}*****************************************${wht}"
echo "       SYSTEM MANAGER (v1.0.69)          "
echo -e "${blu}-----------------------------------------${wht}"
}

#shows network info
show_net_info(){
clear
sysman_logo
echo "Network Information"
echo ""
echo -e "${red}Computer name:${wht}" $(uname -n)
echo ""
for interfaces in $(ip -br addr show | grep -v 'lo' | awk '{print $1}'); do
        echo -e "${grn}Interface:${wht}" $interfaces
        ip addr show $interfaces | awk '{print "\033[32m" "IP Address:", "\033[37m" $2}' | awk 'NR==3' | cut -d "/" -f 1
        ip r | grep default | grep $interfaces | awk '{print "\033[32m" "Gateway:", "\033[37m" $3}'
        ip addr show $interfaces | grep link/ | awk '{print "\033[32m" "MAC:", "\033[37m" $2}'
        echo -e "${grn}Status:${wht}" $(ip link show | awk 'NR==3' | awk '{print $9}')
        echo ""
done
}

# add a new linux user
add_user(){
sysman_logo
echo "Creating a user..."
echo ""
read -p "Username: " username
sudo adduser --quiet "$username"
echo '-------------------------'
}

# view properties of a certain user
user_props(){
sysman_logo
echo "USER PROPERTIES"
echo ""
awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
echo ""
read -p "Username (existing user): " usrnm
echo ""
# Check if user exists in /etc/passwd
if grep -q "^$usrnm:" /etc/passwd; then
	echo "Username:" $usrnm
	echo "UserID:" $(grep $usrnm /etc/passwd | awk -F ":" '{print $3}')
	echo "GroupID:" $(grep $usrnm /etc/passwd | awk -F ":" '{print $4}')
	echo "Comment:" $(grep $usrnm /etc/passwd | awk -F ":" '{print $5}')
	echo "Home Directory:" $(grep $usrnm /etc/passwd | awk -F ":" '{print $6}')
	echo "Shell Directory:" $(grep $usrnm /etc/passwd| awk -F ":" '{print $7}')
	echo ""
	echo "Groups:" $(groups $usrnm | awk -F ":" '{print $2}')
	echo ""
else
	echo "ERROR: Username '$usrnm' does not exist!"
fi
}

# modify specific users props
user_modify(){
sysman_logo
echo "MODIFY USERS PROPS"
echo ""
awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
echo ""
read -p "Username(of user to modify): " mod_usr
echo ""
if grep -q "^$mod_usr:" /etc/passwd; then
	echo "Username:" $mod_usr
	echo ""
	echo "UserID:" $(grep $mod_usr /etc/passwd | awk -F ":" '{print $3}')
	echo "GroupID:" $(grep $mod_usr /etc/passwd| awk -F ":" '{print $4}')
	echo "Comment:" $(grep $mod_usr /etc/passwd| awk -F ":" '{print $5}')
	echo "Home Directory:" $(grep $mod_usr /etc/passwd| awk -F ":" '{print $6}')
	echo "Shell Directory:" $(grep $mod_usr /etc/passwd| awk -F ":" '{print $7}')
	echo ""
	echo "Groups:" $(groups $mod_usr | awk -F ":" '{print $2}')
	echo ""
else
	echo "ERROR: Username '$usrnm' does not exist!"
fi
echo "What property would you like to modify?"
echo "username, group, userid, groupid, comment, home, shell"
echo ""
read -p "> " command
case $command in
"username")
        echo ""
        read -p "New username: " new_usr
	usermod -l $new_usr $mod_usr
	echo "$mod_usr has been changed to $new_usr"´
	echo ""
        ;;
"group")
	echo ""
    echo "CHOOSE A NEW DEFAULT GROUP"
	awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
	echo ""
	read -p "New default group: " def_grp_usr
	if grep -q "^$def_grp_usr:" /etc/group; then
	usermod -g $def_grp_usr $mod_usr
	echo "Group has been changed."
	else
		echo "ERROR: Group '$def_grp_usr' does not exist!"
	fi
        ;;
"userid")
    echo ""
	echo "CHOOSE A NEW USERID"
	read -p "new_id> " new_id
	usermod -u $new_id $mod_usr
	echo ""
	echo "$mod_usr 's id has been changed to $new_id."
        ;;
"groupid")
	echo ""
	echo "CHOOSE A NEW GROUPID(HAS TO BE AN ID OF AN EXISTING GROUP!)"
	read -p "gid> " new_gid
	usermod -g $new_gid $mod_usr
	echo ""
	echo "'$mod_usr' groupid has been changed to $new_gid"
	;;

"comment")
    echo ""
	echo "ADD A NEW COMMENT TO USER PROFILE"
	read -p "comment> " new_comment
	usermod -c $new_comment $mod_usr
	echo ""
	echo "'$new_comment' has been added as a comment to $mod_usr"
        ;;
# Change home directory of selected user
"home")
	echo ""
	echo "Change home directory of current user"
	echo ""
	echo "Directory of new home directory(Absolute PATH)"
	read -p "new_home> " new_home
	usermod -d $new_home $mod_usr
	echo ""
	echo "Changed home directory of '$mod_usr' to '$new_home'."
	;;
# Change the shell of the selected user
"shell")
	echo ""
	echo "Changing '$mod_usr's shell..."
	echo ""
	echo "Write the name of the shell (Starting with /bin)"
	read -p "shell> " new_shell
	usermod -s $new_shell $mod_usr
	echo "Changed '$mod_usr' shell from $SHELL to $new_shell"
	;;

*)
        echo "ERROR... [Invalid Selection: $selection]";
        read -p "Press enter to continue..."
        ;;
esac

}

# delete a user
delete_usr(){
sysman_logo
echo "Which user do you wanna delete?"
echo ""
awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
echo ""
read -p "Username: " del_usr

if grep -q "^$del_usr:" /etc/passwd; then
	deluser --remove-home $del_usr
	echo ""
	echo "User '$del_usr' has been deleted!"
else
	echo "ERROR: Username '$del_usr' does not exist!"
fi
}

# modify a folders properties
folder_modify(){
clear
sysman_logo
read -p "Enter folder name: " folder_name3
if [ ! -d "$folder_name3" ]; then
	echo "$folder_name3 could not be found."
	return
fi
echo "CURRENT WORKING FOLDER:" $folder_name3
echo ""
echo "What property would you like change?"
echo "owner, group, permissions, sticky bit or setgid"
echo ""
read -p "Command > " command
case $command in
# Change owner of a directory/folder/file
"owner")
	echo ""
	read -rp "Enter username of new owner: " user
	chown -v $user $folder_name3
	;;
"group")
	echo ""
	read -rp "Enter new owner group: " grp
	chgrp -v $grp $folder_name3
	;;
# Change Read, write or execute permissions for Owner, group or other on directory/folder/file
"permissions")
	echo ""
	echo "What permissions would you like to change?"
	echo "(r)ead/(w)rite/e(x)ecute/(a)ll?"
	read -p "> " -n 1 perm_select
	if [[ $perm_select == "a" ]]; then
		echo ""
		echo "Who's permissions do you want to change?"
		echo ""
		echo "owner, group, other or all"
		read -p "> " perm_ogo
		if [[ $perm_ogo == "owner" ]]; then
			chmod u+rwx $folder_name3
			echo "Permissions has been changed!"
		elif [[ $perm_ogo == "group" ]]; then
                        chmod g+rwx $folder_name3
                        echo "Permissions has been changed!"
		elif [[ $perm_ogo == "other" ]]; then
                        chmod o+rwx $folder_name3
                        echo "Permissions has been changed!"
		elif [[ $perm_ogo == "all" ]]; then
                        chmod a+rwx $folder_name3
                        echo "Permissions has been changed!"
		else
			echo "ERROR: Invalid selection! Please try again."
		fi
	elif [[ $perm_select == "r" || $perm_select == "w" || $perm_select == "x" ]]; then
		echo ""
		echo "Who's permissions do you want to change?"
		echo "(o)wner, (g)roup, (o)ther or (a)ll"
		read -p "> " -n 1 perm_ogo
		echo ""
		echo "Do you want to (add) or (remove) this permission?"
		read -p "> " perm_add_or_rem
		if [[ $perm_add_or_rem == "add" ]]; then
			chmod $perm_ogo+$perm_select $folder_name3
			echo "Permissions has been changed!"
		elif [[ $perm_add_or_rem == "remove" ]]; then
			chmod $perm_ogo-$perm_select $folder_name3
			echo "Permissions has been changed!"
		else
			echo "ERROR: Invalid Selection! Please try again."
		fi
	else
		echo "ERROR: Invalid selection! Please try again."
	fi
	;;
# Sets sticky bit to specifed file/directory
"sticky bit")
	echo "Do you want to (add) or (remove) sticky bit to $folder_name3?"
	read -p "> " add_rem_stick
	if [[ $add_rem_stick == "add" ]]; then
		echo "Are you sure? (y/n)"
		read -p "> " stick_sel_a
		if [[ "$stick_sel_a" == "y" ]]; then
			chmod +t $folder_name3
			echo "Sticky bit was added to $folder_name3"
		elif [[ "$stick_sel_a" == "n" ]]; then
			echo "No changes were made! Exiting..."
		else
			echo "ERROR: Invalid Selection! Please try again."
		fi
	elif [[ $add_rem_stick == "remove" ]]; then
		echo "Are you sure? (y/n)"
		read -p "> " stick_sel_r
                if [[ "$stick_sel_r" == "y" ]]; then
                        chmod -t $folder_name3
                        echo "Sticky bit was removed from $folder_name3"
                elif [[ "$stick_sel_r" == "n" ]]; then
                        echo "No changes were made! Exiting..."
                else
                        echo "ERROR: Invalid Selection! Please try again."
                fi
	fi
	;;
"setgid")
	echo "Do you want to (add) or (remove) SGID to $folder_name3?"
        read -p "> " add_rem_sgid
        if [[ $add_rem_sgid == "add" ]]; then
                echo "Are you sure? (y/n)"
                read -p "> " sgid_sel_a
                if [[ "$sgid_sel_a" == "y" ]]; then
                        chmod g+s $folder_name3
                        echo "SGID was added to $folder_name3"
                elif [[ "$sgid_sel_a" == "n" ]]; then
                        echo "No changes were made! Exiting..."
                else
                        echo "ERROR: Invalid Selection! Please try again."
                fi
        elif [[ $add_rem_sgid == "remove" ]]; then
                echo "Are you sure? (y/n)"
                read -p "> " sgid_sel_r
                if [[ "$sgid_sel_r" == "y" ]]; then
                        chmod g-s $folder_name3
                        echo "SGID was removed from $folder_name3"
                elif [[ "$sgid_sel_r" == "n" ]]; then
                        echo "No changes were made! Exiting..."
                else
                        echo "ERROR: Invalid Selection! Please try again."
                fi
        fi
        ;;
esac
}

folder_view(){
	sysman_logo
	read -p "Enter the directory: " dir_name
	echo ""
	ls -a --color=auto $dir_name
	echo ""
	echo "Which folder would you like to view?"
	read -p "> " folder_name3
	echo ""
	echo "PATH: $dir_name/$folder_name3"
	echo "Owner: $(stat -c '%U' "$dir_name/$folder_name3")"
	echo "Group: $(stat -c '%G' "$dir_name/$folder_name3")"
	echo "Permissions: $(stat -c '%a/%A' "$dir_name/$folder_name3")"
	echo "Sticky Bit: $(stat -c '%A' "$dir_name/$folder_name3" | cut -c9)"
	echo "Setgid: $(stat -c '%A' "$dir_name/$folder_name3" | cut -c6)"
	echo "Last Modified: $(stat -c '%y' "$dir_name/$folder_name3" | cut -c-19)"
}

# user
create_grp(){
sysman_logo
echo "Creating user group..."
echo ""
read -p "Enter group name: " grp_name
groupadd $grp_name
echo ""
echo "Group '$grp_name' has been created."
echo ""
}

group_modify(){
clear
sysman_logo
echo "Available Users:"
awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
echo -e "\nSelect a user: "
read -p "> " usr_grp_mod
clear
sysman_logo
echo -e "User selected: $usr_grp_mod"
echo ""
echo "Available Groups:"
awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
echo -e "\nSelect a group: "
read -p "> " grp_mod
clear
sysman_logo
echo -e "User selected: $usr_grp_mod"
echo -e "Group selected: $grp_mod"
echo -e "\nDo you want to (add) or (remove) $usr_grp_mod from $grp_mod?"
read -p "> " add_or_remove
echo ""
if [[ "$add_or_remove" == "add" ]]; then
	sudo usermod -aG $grp_mod $usr_grp_mod
	echo "User $usr_grp_mod has been added to $grp_mod"
	echo ""
	read -p "Press enter to continue..."
elif [[ "$add_or_remove" == "remove" ]]; then
	sudo gpasswd -d $usr_grp_mod $grp_mod
	echo "User $usr_grp_mod has been removed from $grp_mod"
	echo ""
	read -p "Press enter to continue..."
else
	echo "Invalid selection... Try again!"
	read -p "Press enter to continue..."
fi
}

clear
while true; do
        clear
        print_help
	echo ""
        read -rp "Selection > " selection;
        case $selection in
        "ni")
		clear
                show_net_info
                read -p "Press enter to continue..."
                ;;
        "ex")
		clear
                echo "Quitting...";
                exit 0
                ;;
	"ua")
		clear
		add_user
		echo "User has been created"
		echo ""
		read -p "Press enter to continue..."
		;;
	"ul")
		clear
		sysman_logo
		echo "LOGIN USERS"
		echo ""
		awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd
		echo ""
		read -p "Press enter to continue..."
		;;
	"uv")
		clear
		user_props
		read -p "Press enter to continue..."
		;;
	"ud")
		clear
		delete_usr
		read -p "Press enter to continue..."
		;;
	"um")
		clear
		user_modify
		read -p "Press enter to continue..."
		;;
	"ga")
		clear
		create_grp
		read -p "Press enter to continue..."
		;;
	"gl")
		clear
		sysman_logo
		echo "Listing all groups"
		echo ""
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo ""
		read -p "Press enter to continue..."
		;;
	"gv")
		clear
		sysman_logo
		awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
		echo -e "\nSelect a group: "
		read -p "> " grp_select
		GID=$(grep "^$grp_select:" /etc/group | cut -d ":" -f 3)
		echo -e "Group ID:" "$GID"
		echo -e "Primary Group User:" $(grep ":$GID:" /etc/passwd | cut -d ":" -f 1)
		echo -e "Other Group Members:" $(grep ":$GID:" /etc/group | cut -d ":" -f 4-)
		echo ""
		read -p "Press enter to continue..."
		;;
	"gm")
		group_modify
		;;
	"gd")
		clear
		sysman_logo
		echo "Available groups:"
                awk -F: '$3 >= 1000 && $1 != "nogroup" {print $1}' /etc/group
                echo -e "\nSelect a group: "
		read -p "> " grp_del
		echo ""
		groupdel $grp_del
		if grep -q "^$grp_del:" /etc/group; then
			echo "Group: $grp_del was unable to be deleted!"
		else
			echo -e "Group: $grp_del has been removed!"
		fi
		echo ""
		read -p "Press enter to continue..."
		;;
	"fa")
		clear
		sysman_logo
		echo "Creating a folder..."
		read -p "Folder name: " folder_name
		read -p "Folder location: " folder_location
		echo ""
		echo "Available users:"
		awk -F: '$3 >= 1000 || $3 == 0 && $1 != "nobody" {print $1}' /etc/passwd
		echo ""
		read -p "Select folder owner: " folder_owner

		#behöver fixa så att det blir mer robust

		echo ""
		sudo -u "$folder_owner" mkdir -v $folder_location/$folder_name
		echo ""
		read -p "Press enter to continue..."
		;;
	"fl")
		clear
		sysman_logo
		read -p "Enter folder name: " folder_name2
		echo "FOLDER CONTENT"
		echo ""
		ls -a --color=auto $folder_name2
		echo ""
		read -p "Press enter to continue..."
		;;
	"fv")
		clear
		folder_view
		echo ""
		read -p "Press enter to continue..."
		;;
	"fm")
		folder_modify
		echo ""
		read -p "Press enter to continue..."
		;;
	"fd")
		clear
		sysman_logo
		read -p "Enter folder name: " folder_name4
		echo "Are you sure you want to delete $folder_name4? (y/n)"
		read -p "> " fd_check
		if [[ $fd_check == "y" ]]; then
			rmdir $folder_name4
			if [ ! -d "$folder_name4" ]; then
				echo "$folder_name4 was successfully deleted!"
			else
				echo "$folder_name4 was not deleted, would you like to try and force the deletion? (y/n)"
				read -p "> " force_chk
				if [[ $force_chk == "y" ]]; then
					rm -rf $folder_name4
					if [ ! -d "$folder_name4" ]; then
						echo "$folder_name4 was successfully deleted!"
					else
						echo "$folder_name4 was not deleted, check your permissions or try another folder."
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
		read -p "Press enter to continue..."
		;;
	*)
                echo "ERROR... [Invalid Selection: $selection]"
                echo ""
		read -p "Press enter to continue..."
                ;;
esac
done
