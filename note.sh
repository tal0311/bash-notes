#!/bin/bash

# Function to prompt the user for a note
prompt_for_note() {
    echo "Please enter your note:"
    read note
    if [ -z "$note" ]; then
        echo "No note was entered. Exiting."
        exit 1
    fi
}

# Function to ask for labels and read them
prompt_for_labels() {
    echo "Would you like to add any labels to your note? (yes/no)"
    read add_labels
    labels=""
    if [[ "$add_labels" == "yes" ]]; then
        echo "Enter labels, separated by commas:"
        read labels
        labels="$labels"
    fi
}

# Function to append the note and labels to the file
write_note() {
    local id=$(awk 'END{print NR+1}' notes.txt)
    local current_date=$(date "+%Y-%m-%d %H:%M:%S")
    local user=$(whoami)
    local status="In Progress"
    echo "ID: [$id] Date: ${current_date} | User: ${user} | Note: $note | Labels: $labels | Status: $status" >> notes.txt
    echo "Note added successfully."
}

# Function to display all notes
view_all_notes() {
    local color=${1:-34}
    echo "All notes:"
    while IFS= read -r line; do
        echo -e "\e[1;${color}m$line\e[0m"
    done < notes.txt
    count_all_notes
}

count_all_notes() {
    echo "Total number of notes:"
    wc -l notes.txt | awk '{print $1}'
}

# Function to remove note by ID
remove_note_by_id() {
    local id=$1
    if [ -z "$id" ]; then
        echo "Please provide a valid note ID."
        exit 1
    fi
    sed -i "/ID: \[$id\]/d" notes.txt
    echo "Note with ID $id removed successfully."
}

# Function to update note status by ID
update_note_status() {
    local id=$1
    local new_status=$2
    if [ -z "$id" ] || [ -z "$new_status" ]; then
        echo "Please provide a valid note ID and new status."
        exit 1
    fi
    sed -i "s/\(ID: \[$id\].*Status: \).*/\1$new_status/" notes.txt
    echo "Note with ID $id updated successfully."
}

# Function to count tasks per label
count_tasks_per_label() {
    echo "Count of tasks per label:"
    awk -F 'Labels: ' '{print $2}' notes.txt | awk -F ' | Status:' '{print $1}' | tr -d '[]' | tr ',' '\n' | sort | uniq -c
}

# Function to list notes by status
list_notes_by_status() {
    

    echo "List of notes by status:"
    echo -e "\e[1;33mIn Progress:\e[0m"
    grep "Status: In Progress" notes.txt 
    echo -e "\e[1;32mDone:\e[0m"
    grep "Status: Done" notes.txt 

    echo "_________________________________________"

    echo "Summary:"
    awk -F 'Status: ' '{print $2}' notes.txt | sort | uniq -c
    
}

# Main script logic based on command-line argument
case "$1" in
    -h)
        echo "Usage: note.sh [option]"
        echo "Options:"
        echo "  -h  Display help"
        echo "  -cl Count tasks per label"
        echo "  -l  View all notes [color 34|32|33|36|31|35]"
        echo "  -cn Count all notes"
        echo "  -m  Update note status [note_id new_status]"
        echo "  -ls List notes by status"
        echo "  -rm Remove note by ID [note_id]"
        ;;
    -cl)
        count_tasks_per_label
        ;;
    -l)
        view_all_notes "$2"
        ;;
    -cn)
        count_all_notes
        ;;
    -m)
        update_note_status "$2" "$3"
        ;;
    -ls)
        list_notes_by_status
        ;;
    -rm)
        remove_note_by_id "$2"
        ;;
    *)
        prompt_for_note
        prompt_for_labels
        write_note
        count_tasks_per_label
        ;;
esac