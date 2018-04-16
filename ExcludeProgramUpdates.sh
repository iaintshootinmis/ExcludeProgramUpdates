#!/bin/bash

Check_Root(){
echo -e "\e[1m*~~~~~ Checking for uid of 0 (root). ~~~~*\e[0m"
if [ "$(id -u)" != "0" ]; then
   echo -e "\n"
   echo "This script must be ran as root." 1>&2
   echo -e "Try \e[3msudo ./ExcludeProgramUpdates.sh\e[0m"
   exit 1
fi
}

Create_Tmp(){
if [ ! -d $HOME/tmp ]; then
	echo "No tmp directory found in $HOME"
	echo "Creating $HOME/tmp/"
	mkdir $HOME/tmp
else
	echo "$HOME/tmp/ exists"
fi
}

Create_Files(){
cd $HOME/tmp/
touch ./depend.txt ./updates.txt ./diff.txt $HOME/Desktop/ProblemUpdates.txt
}

Get_Prog(){
echo -e "What program is having issues?:\e[3m (e.g.; sonarr)\e[0m "
read prog
type $prog > /dev/null 2>&1
if [ $? = 0 ]; then
	echo "$prog found. Begining dependency checks"
else
	echo -e "$prog not found. Try running \e[3m which $prog \e[0m manually to determine if $prog is executable." 
fi
}

Check_Depends(){
echo "Checking $prog dependencies"
apt-cache depends $prog | grep Depends |cut -s -d ":" -f 2|sort > depend.txt
}

Check_Updates(){
echo "Checking for system updates"
sudo apt update > /dev/null 2>&1
if [ $? = 0 ]; then
	echo "Updates found, compiling list of updates."
	apt list --upgradable |cut -s -d "/" -f 1 |sort > updates.txt
	sed -i "s/ //g" updates.txt
	return 0
elif [ $? = 100 ]; then
	echo "Updates found, compiling list of updates."
	apt list --upgradable |cut -s -d "/" -f 1 |sort > updates.txt
	return 0 
else
	echo -e "Updates failed. Try running \e3[m sudo apt update \e0[m manually."
fi
}

Check_Diff(){
echo "Checking for safe updates."
grep -vwf depend.txt updates.txt>diff.txt
}

Install_Updates(){
for i in `cat "diff.txt"` ; do
	apt -y upgrade $i >/dev/null 2>&1
	echo "$i upgraded." 
done
}

Check_Root
Create_Tmp
Create_Files
Get_Prog
Check_Depends
Check_Updates
Check_Diff
Install_Updates
