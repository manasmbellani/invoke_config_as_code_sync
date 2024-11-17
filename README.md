# invoke_config_as_code_sync

Bash code with an example of how to setup configuration as code without using terraform OR state files

## Setup

Only pre-requisites required are `jq`, for parsing response and `yq`, for parsing conf files

## Usage

### Example 1

This example creates files in `files` folder based on YAML templates in folder `fileconf`

```
cd example1_files
../main.sh asset.sh fileconf
```
