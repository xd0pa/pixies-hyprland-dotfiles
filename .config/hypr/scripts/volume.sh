#!/bin/bash

# Script para control de volumen con barra visual en SwayNC

# Detectar si usamos PipeWire o PulseAudio
if command -v wpctl &> /dev/null && wpctl status &> /dev/null; then
    AUDIO_BACKEND="pipewire"
else
    AUDIO_BACKEND="pulseaudio"
fi

get_volume() {
    if [ "$AUDIO_BACKEND" = "pipewire" ]; then
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}'
    else
        pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\d+%' | head -1 | tr -d '%'
    fi
}

get_mute_status() {
    if [ "$AUDIO_BACKEND" = "pipewire" ]; then
        wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q "MUTED" && echo "true" || echo "false"
    else
        pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "true" || echo "false"
    fi
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
    local volume=$(get_volume)
    local muted=$(get_mute_status)
    local bar=$(create_bar $volume)

    if [ "$muted" = "true" ]; then
        notify-send -u low -h string:x-canonical-private-synchronous:volume \
                    -h int:value:0 \
                    " Muted" "$bar  $volume%"
    else
        if [ $volume -eq 0 ]; then
            notify-send -u low -h string:x-canonical-private-synchronous:volume \
                        -h int:value:$volume \
                        "󰖁 Volume" "$bar  $volume%"
        elif [ $volume -lt 50 ]; then
            notify-send -u low -h string:x-canonical-private-synchronous:volume \
                        -h int:value:$volume \
                        " Volume" "$bar  $volume%"
        else
            notify-send -u low -h string:x-canonical-private-synchronous:volume \
                        -h int:value:$volume \
                        " Volume" "$bar  $volume%"
        fi
    fi
}

case $1 in
    up)
        if [ "$AUDIO_BACKEND" = "pipewire" ]; then
            wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
        else
            pactl set-sink-volume @DEFAULT_SINK@ +5%
        fi
        send_notification
        ;;
    down)
        if [ "$AUDIO_BACKEND" = "pipewire" ]; then
            wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
        else
            pactl set-sink-volume @DEFAULT_SINK@ -5%
        fi
        send_notification
        ;;
    mute)
        if [ "$AUDIO_BACKEND" = "pipewire" ]; then
            wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
        else
            pactl set-sink-mute @DEFAULT_SINK@ toggle
        fi
        sleep 0.1  # Pequeña pausa para asegurar que el cambio se aplique
        send_notification
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac
