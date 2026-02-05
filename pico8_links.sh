#!/bin/bash

DRACULA_PURPLE='\033[38;2;189;147;249m'
NC='\033[0m' 
draw_header() {
    clear
    echo -e "${DRACULA_PURPLE}"
    echo " ██▓    ▓█████ ▒██   ██▒    ██▓     ██▓ ███▄    █  ██ ▄█▀  ██████ "
    echo "▓██▒    ▓█   ▀ ▒▒ █ █ ▒░   ▓██▒    ▓██▒ ██ ▀█   █  ██▄█▒ ▒██    ▒ "
    echo "▒██░    ▒███   ░░  █   ░   ▒██░    ▒██▒▓██  ▀█ ██▒▓███▄░ ░ ▓██▄   "
    echo "▒██░    ▒▓█  ▄  ░ █ █ ▒    ▒██░    ░██░▓██▒  ▐▌██▒▓██ █▄   ▒   ██▒"
    echo "░██████▒░▒████▒▒██▒ ▒██▒   ░██████▒░██░▒██░   ▓██░▒██▒ █▄▒██████▒▒"
    echo "░ ▒░▓  ░░░ ▒░ ░▒▒ ░ ░▓ ░   ░ ▒░▓  ░░▓  ░ ▒░   ▒ ▒ ▒ ▒▒ ▓▒▒ ▒▓▒ ▒ ░"
    echo "░ ░ ▒  ░ ░ ░  ░░░   ░▒ ░   ░ ░ ▒  ░ ▒ ░░ ░░   ░ ▒░░ ░▒ ▒░░ ░▒  ░ ░"
    echo "  ░ ░      ░    ░    ░       ░ ░    ▒ ░   ░   ░ ░ ░ ░░ ░ ░  ░  ░  "
    echo "    ░  ░   ░  ░ ░    ░         ░  ░ ░           ░ ░  ░         ░  "                                                
    echo -e "${NC}"
}

draw_header                                      
                                                
# --- Configuration ---
URL_PICO="https://www.lexaloffle.com/dl/docs/pico-8_changelog.txt"
URL_PICO_TRON="https://www.lexaloffle.com/dl/docs/picotron_changelog.txt"
URL_VOX_WEB="https://www.lexaloffle.com/voxatron.php?page=dev"

# --- Step 1: Product Selection ---
echo "Which product do you want to download?"
select prod in "PICO-8" "Picotron" "Voxatron"; do
    case $prod in
        "PICO-8")
            PROD_NAME="pico-8"
            DL_HASH="7wdekp"
            TARGET_URL="$URL_PICO"
            MODE="TEXT"
            break
            ;;
        "Picotron")
            PROD_NAME="picotron"
            DL_HASH="8pwrtp"
            TARGET_URL="$URL_PICO_TRON"
            MODE="TEXT"
            break
            ;;
        "Voxatron")
            PROD_NAME="voxatron"
            DL_HASH="5r8npa"
            TARGET_URL="$URL_VOX_WEB"
            MODE="HTML"
            break
            ;;
        *) echo "Invalid option. Please select 1, 2, or 3.";;
    esac
done

echo "---------------------------------------------------"
echo "Fetching info for $prod..."

TMP_FILE=$(mktemp)

# --- Step 2: Download Info ---
if ! curl -s -L -A "Mozilla/5.0" "$TARGET_URL" -o "$TMP_FILE"; then
    echo "Error: Could not download version info."
    rm "$TMP_FILE"
    exit 1
fi

# --- Step 3: Extract Version ---
if [[ "$MODE" == "HTML" ]]; then
    version_match=$(grep -i "Current version:" "$TMP_FILE" | grep -o -E "[0-9]+\.[0-9]+\.[0-9]+")
    latest_version_raw="$version_match"
else
    latest_version_raw=$(grep -o -i -E "v?[0-9]+\.[0-9]+(\.[0-9]+)?[a-z]?" "$TMP_FILE" | head -n 1)
fi

if [[ -z "$latest_version_raw" ]]; then
    echo "Error: Could not detect version number."
    rm "$TMP_FILE"
    exit 1
else
    version_nov=$(echo "$latest_version_raw" | sed 's/^[vV]//')
fi

echo "Detected version: $version_nov"
echo "---------------------------------------------------"
echo "Direct Download Links for $prod:"
echo

# --- Step 4: Generate Links ---

# Windows
echo "  [Windows]"
if [[ "$prod" == "PICO-8" ]]; then
    echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_setup.exe"
fi
echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_windows.zip"
echo

# Linux
echo "  [Linux]"
echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_amd64.zip"
if [[ "$prod" == "PICO-8" ]]; then
    echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_i386.zip"
fi
echo

# MacOS
echo "  [MacOS]"
echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_osx.zip"
echo

# Raspberry Pi (Только для PICO-8)
if [[ "$prod" == "PICO-8" ]]; then
    echo "  [Raspberry Pi]"
    echo "  https://www.lexaloffle.com/dl/$DL_HASH/${PROD_NAME}_${version_nov}_raspi.zip"
    echo
fi

rm "$TMP_FILE"
