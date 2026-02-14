#!/bin/bash

# Script para control de brillo con barra visual en SwayNC

get_brightness() {
    brightnessctl g
}

get_max_brightness() {
    brightnessctl m
}

get_brightness_percentage() {
    local current=$(get_brightness)
    local max=$(get_max_brightness)
    echo $((current * 100 / max))
}

create_bar() {
    local percentage=$1
    local bar_length=20
    local filled=$((percentage * bar_length / 100))
    local empty=$((bar_length - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do
        bar+="█"
    done
    for ((i=0; i<empty; i++)); do
        bar+="░"
    done

    echo "$bar"
}

send_notification() {
    local brightness=$(get_brightness_percentage)
    local bar=$(create_bar $brightness)

    if [ $brightness -eq 0 ]; then
        notify-send -u low -h string:x-canonical-private-synchronous:brightness \
                    -h int:value:$brightness \
                    "󰃞 Brightness" "$bar  $brightness%"
    elif [ $brightness -lt 30 ]; then
        notify-send -u low -h string:x-canonical-private-synchronous:brightness \
                    -h int:value:$brightness \
                    "󰃟 Brightness" "$bar  $brightness%"
    elif [ $brightness -lt 70 ]; then
        notify-send -u low -h string:x-canonical-private-synchronous:brightness \
                    -h int:value:$brightness \
                    " Brightness" "$bar  $brightness%"
    else
        notify-send -u low -h string:x-canonical-private-synchronous:brightness \
                    -h int:value:$brightness \
                    " Brightness" "$bar  $brightness%"
    fi
}

case $1 in
    up)
        brightnessctl s 5%+
        send_notification
        ;;
    down)
        brightnessctl s 5%-
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down}"
        exit 1
        ;;
esac
