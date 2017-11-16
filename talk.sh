#!/bin/sh
#
# By Vincent Chen z5076361@ad.unsw.edu.au
# Made for fun (and for bash practice)
# Free for distribution and extension/change
# Requires netkit-ntalk
# Intended for use on UNSW's cse machines only
#
# PREAMBLE:
# `netkit-ntalk` is pretty cool, it's almost like
# a real time chat client in the cse terminals
# however, it is cumbersome to use and requires
# typing a lot of stuff to get started.
#
# This script aims to remove some of that overhead
# and get people using `netkit-ntalk`, even for just 
# a few minutes
#

# Regex string for zID for future use
re='z[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'

# Creates friends flat file if one doesn't exist
if [ ! -f friends.txt ]
then
    touch friends.txt
fi

FRIENDS="$(dirname $0)/friends.txt"

# Parse command line args
if [ $# = 0 ] || [ $# -gt 3 ]
then
    echo "$0 -h"

# Print help message
elif [[ "$1" =~ -h(elp)? ]]
then
    echo "./$0 [OPTION] [zID || NAME/ALIAS]"
    echo ""
    echo "e.g. ./$0 -call z1234567"
    echo ""
    echo "OPTIONS:"
    echo "-a(ppend)     Append a new name/alias to zID into $FRIENDS"
    echo "-c(all)       Call a zID or alias of zID stored in $FRIENDS"
    echo "-h(elp)       Display this dialogue"
    echo "-o(nline)     -d(isplay) online friends from $FRIENDS"
    echo ""
    echo "NOTE:"
    echo "zID MUST be of form 'z1234567'"
    echo "Aliases must not contain ':'"
    echo "Talking to yourself is sad. It also breaks talk so don't do it!"

# Append alias to zID
elif [[ "$1" =~ -a(ppend)? ]]
then

    # Parses arguments
    if [ $# -lt 3 ] || ! [[ $2 =~ $re ]]
    then
        echo "Usage: $0 -a <zID> <ALIAS>"
        exit
    fi

    # Check if defined alias already exists for another zID
    if [ $(egrep ":$3$" $FRIENDS) ]
    then
        echo "Error: Alias already exists for $(egrep ":$3$" $FRIENDS)"
        exit
    fi

    echo "Appending $2 $3 to $FRIENDS"

    # Checks if zID already exists in $FRIENDS
    if [ "$(egrep -o "$2" $FRIENDS)" == $2 ] && ! [ "$(egrep "$2.*" $FRIENDS | cut -d":" -f2-)" == $3 ]
    then
        echo "Alias for $2 already exists as $(egrep "$2.*" $FRIENDS | cut -d":" -f2-)!"
        echo "Would you like to overwrite? (y/n): "
        read YESNO

        if [ $YESNO = "y" ]
        then

            echo "Alias for $2 is now $3"
            sed -e "s/^\($2:\)\(.*\)$/\1$3/g" $FRIENDS > tmp$$.tmp
            cat tmp$$.tmp > $FRIENDS
            rm tmp$$.tmp
        fi

        exit

    # Checks if entry is duplicate to one in $FRIENDS
    elif [ "$(egrep "$2.*" $FRIENDS | cut -d":" -f2-)" == "$3" ]
    then
        echo "Same entry already made!"
        exit

    else
        echo "Creating alias $3 for $2"
        echo "$2:$3" >> $FRIENDS
    fi

# Displays online friends
elif [[ "$1" =~ -d(isplay)? ]] || [[ "$1" =~ -o(nline)? ]]
then
    echo ""
    echo CHECKING ONLINE FRIENDS
    echo ""
    while read line
    do
        # Print friends with fancy colours
        if who | cut -d' ' -f1 | egrep -q "$(echo $line | cut -d':' -f1)" 
        then
            printf "`tput setab 2``tput setaf 0`%-35s  ONLINE`tput setab 0``tput setaf 7`\n" "$line"
        else
            printf "`tput setab 1``tput setaf 0`%-35s OFFLINE`tput setab 0``tput setaf 7`\n" "$line"
        fi 
    done <friends.txt

# Call a zID or friend
# At this point, things get tricky
# the recipient is sent a prompt to respond
# with something like 
elif [[ $1 =~ -c(all)? ]]
then
    # Call zID
    if [[ $2 =~ $re ]]
    then
        zID=$2
        echo ""
        echo "CTRL+C TO QUIT TALK"
        echo ""
        echo "Calling $zID in"
        for i in {5..1}
        do
            echo "=========$i========="
            sleep 1
        done
        netkit-ntalk $zID

    # Calls a valid alias
    else
        if [ ! $(egrep "$2" $FRIENDS) ]
        then
            echo "Error: Alias does not exist in $FRIENDS"
            exit
        fi

        zID=$(egrep "$2" $FRIENDS | cut -d':' -f1)
        echo ""
        echo "CTRL+C TO QUIT TALK"
        echo ""
        echo "Calling friend $2 @$zID in"

        for i in {5..1}
        do
            echo "=========$i========="
            sleep 1
        done
        netkit-ntalk $zID
    fi

# Should all else fail, prompt user to run help command
else
    echo "$0 -h(elp)"
fi
 
echo ""
