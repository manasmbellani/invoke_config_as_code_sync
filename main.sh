#!/bin/bash
USAGE="$0 <asset_functions> <conf_folder>"
if [ $# -lt 2 ]; then
    echo "$USAGE"
    exit 1
fi
asset_functions="$1"
conf_folder="$2"

# Source the asset file which contains the functions for the asset
source "$asset_functions"

echo "[*] Syncing assets: conf -> deployed asset..."
conf_files_list=$(ls -1 "$conf_folder")
IFS=$'\n'
for conf_file in $conf_files_list; do
    echo "[*] Validating asset for conf: $conf_folder/$conf_file..."
    conf_valid_flag=$(validate_asset_conf "$conf_folder/$conf_file")
    if [ "$conf_valid_flag" != "" ]; then
        echo "[*] Getting asset for conf: $conf_folder/$conf_file..."
        asset_details=$(get_asset "$conf_folder/$conf_file")
        if [ "$asset_details" == "" ]; then
            echo "[*] Creating asset for conf: $conf_folder/$conf_file..."
            create_asset "$conf_folder/$conf_file"
        else
            echo "[*] Checking asset for conf: $conf_folder/$conf_file..."
            asset_matches=$(check_asset "$conf_folder/$conf_file" "$asset_details")
            if [ "$asset_matches" == "" ]; then
                echo "[*] Updating asset for conf: $conf_folder/$conf_file..."
                update_asset "$conf_folder/$conf_file" "$asset_details"
            fi
        fi
    else
        echo "[-] conf in $conf_file is invalid"
    fi
done

echo "[*] Syncing assets: deployed assets -> conf..."
deployed_assets_list=$(list_assets)
IFS=$'\n'
for deployed_asset in $deployed_assets_list; do
    should_asset_exist_flag=$(should_asset_exist "$conf_folder" "$deployed_asset")
    if [ "$should_asset_exist_flag" == "" ]; then
        echo "[*] Deleting asset for conf: $conf_folder/$conf_file..."
        delete_asset "$deployed_asset"
    fi
done

