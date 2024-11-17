#!/bin/bash
function validate_asset_conf {
    # Validate if the asset configuration is correct
    # Must return 1 if the asset configuration is correct
    local conf_file="$1"
    has_path=$(cat "$conf_file" | yq -r 'has("path")')
    has_content=$(cat "$conf_file" | yq -r 'has("content")')
    if [ "$has_path" == "true" ] && \
        [ "$has_content" == "true" ]; then
        echo "1"
    fi
}

function list_assets {
    # Get a list of all deployed assets
    # Function must return the name / ID for all the assets which were deployed and will be parsed by should_asset_exist and delete_asset
    find ./files -type f | xargs -I ARG echo "path: ARG"
}

function should_asset_exist {
    # Function to determine if the asset ID (eg name) returned by list assets should exist
    # Function must return 1 if the asset must exist otherwise it will be deleted
    local conf_folder="$1"
    local asset_details="$2"

    asset_file_path=$(echo "$asset_details" | cut -d" " -f2)

    IFS=$'\n'
    conf_files_list=$(ls -1 "$conf_folder")
    for conf_file in $conf_files_list; do
        conf_asset_id=$(yq -r ".path" "$conf_folder/$conf_file")
        echo "$asset_file_path" "$conf_asset_id" 1>&2
        if [ "$asset_file_path" == "$conf_asset_id" ]; then
            echo "1"
            break
        fi
    done
}

function get_asset {
    # Get the deployed asset's details
    # Function must return the asset's details
    local conf_file="$1"
    asset_details=""
    conf_file_path=$(yq -r ".path" "$conf_file")
    if [ -e "$conf_file_path" ]; then
        conf_file_content=$(cat "$conf_file_path")
        asset_details="{\"path\": \"$conf_file_path\", \"content\": \"$conf_file_content\"}"
    fi
    echo "$asset_details"
}

#function create_asset {
#    # Create a new deployed asset
#    # Function must return the asset details that were recently deployed
#    local conf_file="$1"
#
#    asset_details=""
#    conf_file_path=$(yq -r ".path" $conf_file)
#    if [ -e "$conf_file_path" ]; then
#        conf_file_content=$(cat "$conf_file_path")
#        asset_details="{\"path\": \"$conf_file_path\", \"content\": \"$conf_file_content\"}"
#        echo "$conf_file_content" > "$conf_file_path"
#    fi
#
#    echo "$asset_details"
#}
#

function check_asset {
    # Check if the asset that is deployed the asset's config in config folder
    local conf_file="$1"
    local asset_details="$2"

    conf_file_path=$(yq -r ".path" "$conf_file")
    conf_file_content=$(yq -r ".content" "$conf_file")

    asset_details_path=$(echo "$asset_details" | jq -r ".path")
    asset_details_content=$(echo "$asset_details" | jq -r ".content")
    
    if [ "$conf_file_path" == "$asset_details_path" ] && \
        [ "$conf_file_content" == "$asset_details_content" ]; then
        echo "1"
    fi
}


function create_asset {
    # Create a new deployed asset
    local conf_file="$1"

    conf_file_path=$(yq -r ".path" $conf_file)
    conf_file_content=$(yq -r ".content" $conf_file)

    echo "$conf_file_content" > "$conf_file_path"
}


function update_asset {
    # Function to update existing asset
    local conf_file="$1"
    
    create_asset "$conf_file"
}

function delete_asset {
    # Function to delete existing asset
    local asset_details="$1" 
    
    asset_file_path=$(echo "$asset_details" | cut -d" " -f2)
    echo "asset_to_delete: $asset_details" 1>&2
    rm "$asset_file_path"
}

