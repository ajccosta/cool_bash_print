min () {
    #min function
    a=$1
    b=$2
    echo $(( a > b ? b : a ))
}

#https://stackoverflow.com/questions/5349718/how-can-i-repeat-a-character-in-bash
repl() {
    #print <$1> character <$2> times 
    # when $2 == 0 weird things happen
    printf "$1"'%.s' $(eval "echo {1.."$(($2))"}");
}

print_snake () {
    progress=$1

    col_size=$2
    lin_size=$3
    #Relate the percentage (progress) to the amount of characters to print
    total_to_draw=$(( (progress * (col_size * 2 + lin_size * 2) ) / 100 ))
    drawn=0

    padding_left=$4

    #Horizontal left to right--------------
    #   how many to draw: entire column or not?
    to_draw=$(min $col_size $total_to_draw)
    #   print padding
    repl " " $padding_left
    #   print characters
    repl "#" $to_draw
    #   how many characters were drawn?
    drawn=$to_draw
    #--------------Horizontal left to right

    #Vertical top down--------------
    for j in $(seq $(min lin_size $((total_to_draw - drawn)) )); do
        #go to next line
        printf "\n";
        #print spaces until we reach the next character pos (including padding)
        repl " " $((col_size  + padding_left - 1))
        printf "#";
        drawn=$((drawn + 1))
    done
    #--------------Vertical top down

    #Horizontal right to left--------------
    printf "\n\r"
    #print padding
    repl " " $padding_left
    #how many characters to draw?
    to_draw=$(min col_size $((total_to_draw - drawn)))
    if [[ ! $to_draw -eq $col_size ]]; then
        #print spaces until we reach the next character pos
        repl " " $((col_size - to_draw))
    fi
    if [[ $to_draw > 0 ]]; then
        #print characters
        repl "#" $to_draw
    fi  
    drawn=$((drawn + to_draw))
    #--------------Horizontal right to left


    #Vertical down top--------------
    to_draw=$(min lin_size $((total_to_draw - drawn)))
    #go back to beggining
    return_term_init_pos

    #number of spaces to print
    blanks=$((lin_size - to_draw))
    if [[ $blanks -gt 0 ]]; then
        repl "\n" $blanks
    fi

    #print 1 character per line
    for j in $(seq $to_draw); do
        repl " " $padding_left
        printf "#\n";
    done

    #print last character (without newline)
    if [[ $to_draw -gt 0 ]]; then
        repl " " $padding_left
        printf "#";
    fi
    #--------------Vertical down top

    #x=0
    #for j in $(seq $(min lin_size $((total_to_draw - drawn)) )); do
    #    return_term_init_pos
    #    if [[ $((lin_size - x)) > 0 ]]; then
    #        repl "\n" $((lin_size - x))
    #    fi
    #    x=$((x+1))

    #    repl " " $padding_left
    #    printf "#";
    #done
}

clear_line () {
    printf "\r";

    #for j in $(seq $cols); do printf " "; done; #janky
    printf ' %0.s' {0..$cols};

    printf "\r";
} 

record_term_pos () {
    tput sc
}

clear_term_since_last_pos () {
    tput rc
    tput ed
}

return_term_init_pos() {
    tput rc
}

update_snake () {
    record_term_pos

    snake=$1
    print_snake $snake $2 $3 $4

    if [[ ! $i -eq 100 ]]; then
        sleep $sleep_time
        return_term_init_pos
    else 
        printf "\n"
    fi
}

term_lines=$(tput lines)
term_cols=$(tput cols)

lines=$(( term_lines / 2 ))
cols=$(( term_cols / 2 ))

padding_left=$(( (term_cols - cols) / 2 ))

snake=$1
sleep_time=$2

if [[ "$sleep_time" == "" ]]; then
    sleep_time=0.001
fi

update_snake $snake $cols $lines $padding_left
