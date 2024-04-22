#!/bin/bash

print_percentage () {
    percentage=$1
    perc_size=$(echo $percentage | wc -c)

    to_fill=$(( (percentage * (cols - 2) / 100) - perc_size));
    if [[ $to_fill -lt 0 ]]; then
        to_fill=0
    fi

    printf "[";

    for j in $(seq $to_fill); do
        printf "#";
    done;

    for j in $(seq $((cols - 2 - to_fill - $perc_size))); do
        printf " ";
    done;

    printf "%s%%" "$percentage"

    printf "]";
}

clear_line () {
    printf "\r";

    #for j in $(seq $cols); do printf " "; done; #janky
    printf ' %0.s' {0..$cols};

    printf "\r";
} 

update_percentage () {
    percentage=$1
    print_percentage $percentage

    if [[ ! $i -eq 100 ]]; then
        sleep $sleep_time
        clear_line
    else 
        printf "\n"
    fi
}

lines=$(tput lines)
cols=$(tput cols)


percentage=$1
sleep_time=$2

if [[ "$sleep_time" == "" ]]; then
    sleep_time=0.001
fi

update_percentage $percentage
