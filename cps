#!/bin/bash

command=$1

printf "%5s %-8s %8s %s\n" "PID" "TTY" "TIME" "CMD"

find /proc -maxdepth 1 -type d -regex '^/proc/[0-9]+$' -print0 | while read -d $'\0' process
do
    if [[ ! -e $process/stat ]]; then continue; fi
    read pid comm tty_nr <<< $(cut -d' ' -f1,2,7 ${process}/stat)

    comm=${comm:1:((${#comm}-2))}
    if [[ ! "$comm" = "$command" ]]; then continue; fi

    tty_nr=$(ttyParse $tty_nr)
    read tty_maj tty_min <<< "$tty_nr"
    case "$tty_maj" in
        0)
            tty="?"
            ;;
        136)
            tty="pts/"$tty_min
            ;;
        4)
            tty="tty"$tty_min
            ;;
    esac

    printf "%5s %-8s %8s %s\n" "$pid" "$tty" "time" "$comm"
done

