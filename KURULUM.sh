#!/bin/bash

# Tüm haklaro Nişanyan'dan sonra sizlere aittir.
# Gönlünüzce kullanınız, değiştiriniz, dağıtınız.
# sybau

set -e

BASE_DIR="$HOME/scripts"
JSON_FILE="$BASE_DIR/nisanyansozluk.json"
DATABASE_ARCHIVE_NAME="nisanyan-db.tar.gz"
FINAL_DATABASE_PATH="/usr/local/share/$DATABASE_ARCHIVE_NAME"
SCRIPTS_DIR="$HOME/scripts"
ROFI_SCRIPT_PATH="$SCRIPTS_DIR/rofi-nisanyan.sh"
DESKTOP_FILE_PATH="$SCRIPTS_DIR/rofi-nisanyan.desktop"

echo "#################################################"
echo "# NİŞANYAN SÖZLÜK KURULUYOR... #"
echo "#################################################"
echo

if ! command -v jq &> /dev/null; then
    echo "HATA: 'jq' komutu bulunamadı. Lütfen 'sudo pacman -S jq' veya 'sudo apt install jq' ile yükleyin." >&2
    exit 1
fi
if [ ! -f "$JSON_FILE" ]; then
    echo "HATA: 'nisanyansozluk.json' dosyası bu klasörde bulunamadı." >&2
    exit 1
fi
mkdir -p "$SCRIPTS_DIR"

# --- VERİTABANI OLUŞTURMA ---
echo "[1/4] Veritabanı oluşturuluyor..."
BUILD_DIR=$(mktemp -d); trap 'rm -rf -- "$BUILD_DIR"' EXIT
DB_DIR="$BUILD_DIR/nisanyan-db"; mkdir -p "$DB_DIR"

jq -r '[.[] | .words[]? | select(.name != null)] | group_by(.name) | map(.[0]) | .[].name' "$JSON_FILE" | grep -v "^\+" > "$DB_DIR/list"
jq -c '[.[] | .words[]? | select(.name != null)] | group_by(.name) | map(.[0]) | .[].' "$JSON_FILE" | while read -r line; do
    WORD=$(echo "$line" | jq -r '.name'); if [[ "$WORD" == \+* ]]; then continue; fi
    MEANING=$(echo "$line" | jq -r '.etymologies[0].definition')
    HASH=$(echo -n "$WORD" | md5sum | awk '{print $1}')
    DEFINITION_CONTENT="<b>$WORD</b>"; if [ "$MEANING" != "null" ] && [ ! -z "$MEANING" ]; then DEFINITION_CONTENT+=$(printf "\n%s" "$MEANING"); fi
    echo -e "$DEFINITION_CONTENT" > "$DB_DIR/$HASH"
done
echo "Veritabanı başarıyla oluşturuldu."

# --- VERİTABANINI PAKETLEME VE TAŞIMA ---
echo
echo "[2/4] Veritabanı paketleniyor ve taşınıyor..."
tar -czf "$BUILD_DIR/$DATABASE_ARCHIVE_NAME" -C "$DB_DIR" .
echo "Yönetici izni gerekiyor. Lütfen şifrenizi girin..."
sudo mv "$BUILD_DIR/$DATABASE_ARCHIVE_NAME" "$FINAL_DATABASE_PATH"
echo "Veritabanı başarıyla '$FINAL_DATABASE_PATH' konumuna kuruldu."

# --- ROFİ BETİĞİNİ VE KISAYOLUNU OLUŞTURMA ---
echo
echo "[3/4] Nihai Rofi betiği ve uygulama kısayolu oluşturuluyor..."
cat > "$ROFI_SCRIPT_PATH" << 'ROFIEOF'
#!/bin/bash
DATABASE="/usr/local/share/nisanyan-db.tar.gz"
CACHE="/dev/shm/rofi-nisanyan-cache"
if ! [ -f "$DATABASE" ]; then rofi -e "HATA: Veritabanı bulunamadı!\n($DATABASE)"; exit 1; fi
if ! [ -d "$CACHE" ]; then mkdir -p "$CACHE"; tar -xzf "$DATABASE" -C "$CACHE/"; fi
CURRENT_FILTER=""; while true; do
SELECTED_WORD=$(cat "$CACHE/list" | rofi -dmenu -p "Nişanyan Sözlük:" -i -filter "$CURRENT_FILTER"); ROFI_EXIT_CODE=$?
if [ $ROFI_EXIT_CODE -eq 0 ]; then
if [ -z "$SELECTED_WORD" ]; then continue; fi
CURRENT_FILTER=$(echo "$SELECTED_WORD" | sed 's/[0-9]*$//'); WORD_HASH=$(echo -n "$SELECTED_WORD" | md5sum | awk '{print $1}')
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
"$PLAIN_FOOTER_TEXT") xdg-open "/usr/local/share/" & xdg-open "$HOME/scripts/" & ;;
*) SEARCH_QUERY=$(echo -n "$CLEAN_CHOSEN_LINE" | jq -sRr @uri); xdg-open "https://www.google.com/search?q=$SEARCH_QUERY" & ;;
esac; else rofi -e "Hata: '$SELECTED_WORD' için tanım bulunamadı."; fi
elif [ $ROFI_EXIT_CODE -eq 1 ]; then if [ -n "$CURRENT_FILTER" ]; then CURRENT_FILTER=""; continue; else exit 0; fi
else exit 0; fi; done
ROFIEOF
chmod +x "$ROFI_SCRIPT_PATH"

# DÜZELTME: .desktop dosyasını oluştururken 'cat << EOF' kullanarak $HOME değişkeninin okunmasını sağla.
cat > "$DESKTOP_FILE_PATH" << DESKTOPEOF
[Desktop Entry]
Type=Application
Name=Nişanyan Sözlük (Rofi)
Comment=Rofi üzerinden Nişanyan Etimolojik Sözlük'te arama yap
Exec=$HOME/scripts/rofi-nisanyan.sh
Icon=utilities-dictionary
Terminal=false
Categories=Utility;Office;
DESKTOPEOF
echo "Rofi betiği ve uygulama kısayolu başarıyla '$SCRIPTS_DIR' içine oluşturuldu."

# --- BİTİŞ ---
echo
echo "[4/4] Kurulum Tamamlandı!"
echo "################################################################"
echo "# HER ŞEY HAZIR!                                               #"
echo "################################################################"
echo
echo "Oluşturulan uygulama kısayolunu sisteminize tanıtmak için,"
echo "aşağıdaki komutları çalıştırmanız yeterli:"
echo
echo "   mv ~/scripts/rofi-nisanyan.desktop ~/.local/share/applications/"
echo "   update-desktop-database ~/.local/share/applications/"
echo
