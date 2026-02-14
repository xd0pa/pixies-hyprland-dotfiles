#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/wallpaper"

mkdir -p "$WALLPAPER_DIR"

case "$1" in
    set)
        if [ -z "$2" ]; then
            echo "Uso: $0 set <ruta_imagen>"
            exit 1
        fi
        swww img "$2" --transition-type wipe --transition-fps 60
        ;;
    random)
        WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" \) | shuf -n 1)
        if [ -n "$WALLPAPER" ]; then
            swww img "$WALLPAPER" --transition-type random --transition-fps 60
            notify-send "Wallpaper" "Cambiado a: $(basename "$WALLPAPER")"
        else
            notify-send "Wallpaper" "No se encontraron imágenes en $WALLPAPER_DIR"
        fi
        ;;
    *)
        echo "Uso: $0 {set <imagen>|random}"
        exit 1
        ;;
esac
