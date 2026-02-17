#!/usr/bin/env bash

set -e

echo ""
echo "==============================================="
echo " WordPress Batch Search & Replace Utility"
echo "==============================================="
echo ""

if ! command -v wp &> /dev/null; then
  echo "❌ wp-cli not found. Install wp-cli first."
  exit 1
fi

if [ ! -f wp-config.php ]; then
  echo "❌ wp-config.php not found. Run this from WP root."
  exit 1
fi

PREFIX=$(wp config get table_prefix --quiet)

if [ -z "$PREFIX" ]; then
  echo "❌ Could not detect table prefix."
  exit 1
fi

echo "Detected table prefix: $PREFIX"
echo ""

read -p "Search for: " SEARCH
read -p "Replace with: " REPLACE

echo ""
echo "Choose mode:"
echo "1) Full database (recommended for migrations)"
echo "2) Only large tables (posts, postmeta, options, usermeta)"
echo ""
read -p "Selection [1/2]: " MODE

echo ""
read -p "Run dry-run first? (y/n): " DRY

DRY_FLAG=""
if [[ "$DRY" == "y" || "$DRY" == "Y" ]]; then
  DRY_FLAG="--dry-run"
fi

BATCH_SIZE=10000

BIG_TABLES=(
  "${PREFIX}posts"
  "${PREFIX}postmeta"
  "${PREFIX}options"
  "${PREFIX}usermeta"
)

ALL_TABLES=$(wp db tables --all-tables-with-prefix --quiet)

run_batch() {
  local table=$1
  local col=$2

  echo ""
  echo "Processing $table.$col"

  MIN=$(wp db query "SELECT MIN(id) FROM $table;" --skip-column-names 2>/dev/null || true)
  MAX=$(wp db query "SELECT MAX(id) FROM $table;" --skip-column-names 2>/dev/null || true)

  [[ -z "$MIN" || -z "$MAX" ]] && return

  for ((i=MIN; i<=MAX; i+=BATCH_SIZE)); do
    END=$((i+BATCH_SIZE-1))
    echo " → IDs $i to $END"

    wp search-replace "$SEARCH" "$REPLACE" \
      "$table" \
      --where="id BETWEEN $i AND $END" \
      --skip-columns=guid \
      --precise \
      --recurse-objects \
      $DRY_FLAG \
      --quiet
  done
}

if [[ "$MODE" == "1" ]]; then
  echo "Running FULL database search-replace"
  wp search-replace "$SEARCH" "$REPLACE" \
    --all-tables-with-prefix \
    --skip-columns=guid \
    --precise \
    --recurse-objects \
    $DRY_FLAG
else
  echo "Running BATCHED large-table updates"

  run_batch "${PREFIX}posts" "ID"
  run_batch "${PREFIX}postmeta" "meta_id"
  run_batch "${PREFIX}options" "option_id"
  run_batch "${PREFIX}usermeta" "umeta_id"

  echo ""
  echo "Running remaining tables (small tables, non-batched)"
  wp search-replace "$SEARCH" "$REPLACE" \
    --all-tables-with-prefix \
    --skip-columns=guid \
    --precise \
    --recurse-objects \
    $DRY_FLAG
fi

echo ""
echo "✅ Search & replace completed"
echo ""

