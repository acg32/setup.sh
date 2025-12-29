#!/bin/bash
function announce() {
    # Surround text with 15 equal signs
    SPACES=$(printf %15s |tr " " "=")
    echo -e "$SPACES $@ $SPACES"
}

function announce_fn() {
    # Announce execution of function with colorful text.
    # Catch STDERR and displays it in event of EXIT_CODE != 0
    echo -e "$BG_CYAN $(announce "[START]" "$@") $CLEAR"
    set -x
    "$@" 2> .my-error.log
    EXIT_STATUS=$?
    set +x
    ERROR=$(<".my-error.log")
    rm .my-error.log
    if [ "$EXIT_STATUS" -eq 0 ]; then
        echo -e "$BG_GREEN $(announce "[DONE]" "$@") $CLEAR"
    else
        echo -e "$BG_RED $(announce "[ERROR]" "$@") $CLEAR"
        echo "$ERROR"
        exit 1 
    fi
}