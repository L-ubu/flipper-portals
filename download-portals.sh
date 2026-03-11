#!/bin/bash
# Downloads premade evil portal HTML files from popular GitHub repos
# into ~/Projects/flipper-portals/portals/

BASE_DIR="$HOME/Projects/flipper-portals/portals"
mkdir -p "$BASE_DIR/bigbrodude" "$BASE_DIR/european" "$BASE_DIR/custom"

echo "╔════════════════════════════════════════╗"
echo "║   🐬 Evil Portal Downloader            ║"
echo "╚════════════════════════════════════════╝"
echo ""

# ── Repo 1: bigbrodude6119/flipper-zero-evil-portal ──
echo "📥 [1/2] Downloading from bigbrodude6119/flipper-zero-evil-portal..."
PORTALS=(
  "AlaskaAirline" "Amazon" "Better_Google_Mobile" "CoxWifi" "Facebook"
  "FakeHack" "FakeHack2" "Frequency" "Google_Modern" "Jet_Blue" "Matrix"
  "Microsoft" "Prank_Game" "Spectrum" "SpiritAirlines" "Starlink"
  "T_Mobile" "Twitch" "Twitter" "Verizon" "american_airline" "apple"
  "detla_airline" "southwest_airline" "united_airline"
)
COUNT=0
for name in "${PORTALS[@]}"; do
  url="https://raw.githubusercontent.com/bigbrodude6119/flipper-zero-evil-portal/main/portals/${name}.html"
  if curl -sfL "$url" -o "$BASE_DIR/bigbrodude/${name}.html" 2>/dev/null; then
    COUNT=$((COUNT + 1))
  fi
done
echo "   ✅ Downloaded $COUNT portals"

# Special case for at&t
if curl -sfL "https://raw.githubusercontent.com/bigbrodude6119/flipper-zero-evil-portal/main/portals/at%26t.html" -o "$BASE_DIR/bigbrodude/att.html" 2>/dev/null; then
  COUNT=$((COUNT + 1))
fi

# ── Repo 2: FlippieHacks/FlipperZeroEuropeanPortals ──
echo ""
echo "📥 [2/2] Downloading from FlippieHacks/FlipperZeroEuropeanPortals..."
EURO_CATEGORIES=(
  "Airlines"
  "Brands"
  "Fast%20Foods%20%26%20coffeeshops"
  "Gyms"
  "Hotels"
  "Internet%20Providers"
  "Railway%20Companies"
  "Supermarkets"
  "Theme%20Parks"
  "WiFi%20Routers"
)
EURO_DIRS=(
  "airlines"
  "brands"
  "fastfood-coffee"
  "gyms"
  "hotels"
  "isp"
  "railway"
  "supermarkets"
  "theme-parks"
  "wifi-routers"
)
EURO_COUNT=0
for i in "${!EURO_CATEGORIES[@]}"; do
  cat_url="${EURO_CATEGORIES[$i]}"
  local_dir="${EURO_DIRS[$i]}"
  mkdir -p "$BASE_DIR/european/$local_dir"
  
  files=$(curl -sf "https://api.github.com/repos/FlippieHacks/FlipperZeroEuropeanPortals/contents/${cat_url}?ref=main" 2>/dev/null \
    | grep '"download_url"' | grep -o 'https://[^"]*\.html' || true)

  for file_url in $files; do
    filename=$(basename "$file_url")
    if curl -sfL "$file_url" -o "$BASE_DIR/european/$local_dir/$filename" 2>/dev/null; then
      EURO_COUNT=$((EURO_COUNT + 1))
    fi
  done
done
echo "   ✅ Downloaded $EURO_COUNT European portals"

echo ""
echo "════════════════════════════════════════"
echo " Total: $((COUNT + EURO_COUNT)) premade portals downloaded"
echo ""
echo " 📂 $BASE_DIR/"
echo "  ├── bigbrodude/    (US-focused portals)"
echo "  ├── european/      (EU brands, sorted by category)"
echo "  │   ├── airlines/"
echo "  │   ├── brands/"
echo "  │   ├── fastfood-coffee/"
echo "  │   ├── gyms/"
echo "  │   ├── hotels/"
echo "  │   ├── isp/"
echo "  │   ├── railway/"
echo "  │   ├── supermarkets/"
echo "  │   ├── theme-parks/"
echo "  │   └── wifi-routers/"
echo "  └── custom/        (your custom portals)"
echo "════════════════════════════════════════"
