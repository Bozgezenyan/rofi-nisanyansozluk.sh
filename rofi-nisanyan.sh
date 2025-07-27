#!/bin/bash

# Tüm hakları Nişanyan'dan sonra sizlere aittir.
# Gönlünüzce kullanınız, değiştiriniz, dağıtınız.
# sybau

# --- AKILLI YOL TANIMLAMA ---
# Bu betiğin nerede olduğunu bul
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
# Veritabanının, betiğin tam yanında olduğunu varsay
DATABASE="$SCRIPT_DIR/nisanyan-db.tar.gz"
CACHE="/dev/shm/rofi-nisanyan-cache"

# --- AKILLI KURULUM (İLK ÇALIŞTIRMA) ---
if ! [ -d "$CACHE" ]; then 
    if ! [ -f "$DATABASE" ]; then 
        rofi -e "HATA: Veritabanı bulunamadı!\nBetiğin ($0) ve 'nisanyan-db.tar.gz' dosyasının aynı klasörde olduğundan emin olun."
        exit 1
    fi
    mkdir -p "$CACHE"; tar -xzf "$DATABASE" -C "$CACHE/"
fi

# --- ANA UYGULAMA MANTIĞI ---
CURRENT_FILTER=""
while true; do
    SELECTED_WORD=$(cat "$CACHE/list" | rofi -dmenu -p "Nişanyan Sözlük:" -i -filter "$CURRENT_FILTER")
    ROFI_EXIT_CODE=$?
    if [ $ROFI_EXIT_CODE -eq 0 ]; then
        if [ -z "$SELECTED_WORD" ]; then continue; fi
        CURRENT_FILTER=$(echo "$SELECTED_WORD" | sed 's/[0-9]*$//')
        WORD_HASH=$(echo -n "$SELECTED_WORD" | md5sum | awk '{print $1}')
        if [ -f "$CACHE/$WORD_HASH" ]; then
            DEFINITION=$(cat "$CACHE/$WORD_HASH"); URL_ENCODED_WORD=$(echo -n "$SELECTED_WORD" | jq -sRr @uri); FULL_URL="https://www.nisanyansozluk.com/kelime/$URL_ENCODED_WORD"
            PLAIN_ACTION_TEXT="(Alıntı, Argo, Tarihçe, Etyma, Gramer, Vezin, Dil, Tarih, -ek, ve Notlar için Tıklayınız!!!)"; FORMATTED_ACTION_TEXT="<span size='x-small'>$PLAIN_ACTION_TEXT</span>"
            FORMATTED_URL_TEXT="<span size='x-small'>$FULL_URL</span>"; PLAIN_FOOTER_TEXT="Dataset: 02.12.22 Code: 26.07.25 All rights lovingly yours"; FORMATTED_FOOTER_TEXT="<i>$PLAIN_FOOTER_TEXT</i>"
            MENU_CONTENT=$(printf "%s\n\n%s\n%s\n\n%s" "$DEFINITION" "$FORMATTED_ACTION_TEXT" "$FORMATTED_URL_TEXT" "$FORMATTED_FOOTER_TEXT")
            CHOSEN_LINE=$(echo -e "$MENU_CONTENT" | rofi -dmenu -p "$SELECTED_WORD" -markup-rows)
            if [ -z "$CHOSEN_LINE" ]; then CURRENT_FILTER=$(echo "$CURRENT_FILTER" | sed 's/[0-9]*$//'); continue; fi
            CLEAN_CHOSEN_LINE=$(echo "$CHOSEN_LINE" | sed 's/<[^>]*>//g')
            case "$CLEAN_CHOSEN_LINE" in
                "$PLAIN_ACTION_TEXT" | "$FULL_URL") xdg-open "$FULL_URL" & ;;
                "$PLAIN_FOOTER_TEXT") xdg-open "$SCRIPT_DIR" & ;;
                *) SEARCH_QUERY=$(echo -n "$CLEAN_CHOSEN_LINE" | jq -sRr @uri); xdg-open "https://www.google.com/search?q=$SEARCH_QUERY" & ;;
            esac
        else
            rofi -e "Hata: '$SELECTED_WORD' için tanım bulunamadı."
        fi
    elif [ $ROFI_EXIT_CODE -eq 1 ]; then
        if [ -n "$CURRENT_FILTER" ]; then CURRENT_FILTER=""; continue; else exit 0; fi
    else
        exit 0
    fi
done
