#!/bin/bash
# Text colors and formats variables.
# Run this script to display all variations in a table

# Reset
CLEAR='\033[0m'       # Text Reset

# Regular Colors
R_BLACK='\033[0;30m'        # Black
R_RED='\033[0;31m'          # Red
R_GREEN='\033[0;32m'        # Green
R_YELLOW='\033[0;33m'       # Yellow
R_BLUE='\033[0;34m'         # Blue
R_PURPLE='\033[0;35m'       # Purple
R_CYAN='\033[0;36m'         # Cyan
R_WHITE='\033[0;37m'        # White

# Bold
B_BLACK='\033[1;30m'       # Black
B_RED='\033[1;31m'         # Red
B_GREEN='\033[1;32m'       # Green
B_YELLOW='\033[1;33m'      # Yellow
B_BLUE='\033[1;34m'        # Blue
B_PURPLE='\033[1;35m'      # Purple
B_CYAN='\033[1;36m'        # Cyan
B_WHITE='\033[1;37m'       # White

# Underline
U_BLACK='\033[4;30m'       # Black
U_RED='\033[4;31m'         # Red
U_GREEN='\033[4;32m'       # Green
U_YELLOW='\033[4;33m'      # Yellow
U_BLUE='\033[4;34m'        # Blue
U_PURPLE='\033[4;35m'      # Purple
U_CYAN='\033[4;36m'        # Cyan
U_WHITE='\033[4;37m'       # White

# Background
BG_BLACK='\033[40m'       # Black
BG_RED='\033[41m'         # Red
BG_GREEN='\033[42m'       # Green
BG_YELLOW='\033[43m'      # Yellow
BG_BLUE='\033[44m'        # Blue
BG_PURPLE='\033[45m'      # Purple
BG_CYAN='\033[46m'        # Cyan
BG_WHITE='\033[47m'       # White

# High Intensity
HI_BLACK='\033[0;90m'       # Black
HI_RED='\033[0;91m'         # Red
HI_GREEN='\033[0;92m'       # Green
HI_YELLOW='\033[0;93m'      # Yellow
HI_BLUE='\033[0;94m'        # Blue
HI_PURPLE='\033[0;95m'      # Purple
HI_CYAN='\033[0;96m'        # Cyan
HI_WHITE='\033[0;97m'       # White

# Bold High Intensity
BHI_BLACK='\033[1;90m'      # Black
BHI_RED='\033[1;91m'        # Red
BHI_GREEN='\033[1;92m'      # Green
BHI_YELLOW='\033[1;93m'     # Yellow
BHI_BLUE='\033[1;94m'       # Blue
BHI_PURPLE='\033[1;95m'     # Purple
BHI_CYAN='\033[1;96m'       # Cyan
BHI_WHITE='\033[1;97m'      # White

# High Intensity backgrounds
HIBG_BLACK='\033[0;100m'   # Black
HIBG_RED='\033[0;101m'     # Red
HIBG_GREEN='\033[0;102m'   # Green
HIBG_YELLOW='\033[0;103m'  # Yellow
HIBG_BLUE='\033[0;104m'    # Blue
HIBG_PURPLE='\033[0;105m'  # Purple
HIBG_CYAN='\033[0;106m'    # Cyan
HIBG_WHITE='\033[0;107m'   # White

COLOR_NAMES=("BLACK" "RED" "GREEN" "YELLOW" "BLUE" "PURPLE" "CYAN" "WHITE")
FORMATS=("R_" "B_" "U_" "BG_" "HI_" "BHI_" "HIBG_")

function show_colors() {
    # Display all colors and formats in a table
    HEADER=""
    for format in "${FORMATS[@]}"; do
        HEADER+="\t$format"
    done
    echo -e "Color | Format$HEADER$CLEAR"
    for color in "${COLOR_NAMES[@]}"; do
        printf "%-10s" "$color"
        for format in "${FORMATS[@]}"; do
            c="$format$color"
            printf "\t${!c}text$CLEAR"
            # printf "Text in %-12s: ${!c}my text$CLEAR \n" "$c"
        done
        echo
    done
}

if [ "$0" = "$BASH_SOURCE" ]; then
    show_colors
fi