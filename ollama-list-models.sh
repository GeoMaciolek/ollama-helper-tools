#!/usr/bin/env bash

# Script to query ollama's API to get a list of models, with a bit more detail


### Settings

# Set to the API host, in the format e.g. 'http://localhost:11434/'
api_host_root='http://localhost:11434/'

### Constants

# You shouldn't normally need to change these

script_version="0.1"
script_name="ollama-list-models"
script_site="https://github.com/GeoMaciolek/ollama-helper-scripts"
valid_sort_keys=("name" "size" "modified" "date" "param_size" "quant_level")

################################################

### Functions

# You shouldn't normally need to change these

# Query the API for the models
get_models_json () {
	curl -s "${api_host_root}api/tags"
}

# Convert the size fom bytes to human-readable
size_fmt () {
	numfmt --to=iec-i --suffix=B --format="%.1f" <<< "$1"
#	numfmt --suffix=B --format="%.1f" <<< "$1"
}

# Format the date
date_fmt_simple () {
	cut -f1 -d'T' <<< "$1"
}

# Convert the parameter sizes to be consistent - e.g. "4B" to "4.0B"
param_size_fmt () {
	size=$1
	# Check for a period in the string
	if [[ $size == *"."* ]]; then
		# All set, pass as-is
		echo "$size"
	else
		# Reformat (Add trailing .0)
		echo "${size/B/.0B}"
	fi
}

join_by () {
  local d=${1-} f=${2-}
  if shift 2; then
    printf %s "$f" "${@/#/$d}"
  fi
}

show_valid_sort_keys () {
	join_by ", " "${valid_sort_keys[@]}"
}

# Parses the json file, and outputs space-delimited values for each model, one model per line
split_json () {
	jq -j '.models[]|"\(.name) \(.size) \(.modified_at) \(.details.parameter_size) \(.details.quantization_level)\n"' <<< "$1"
}

validate_sort_key () {
  sort_key="$1"
  if [[ ! " ${valid_sort_keys[*]} " =~ [[:space:]]${sort_key}[[:space:]] ]]; then
    echo "Error: Sort key \"$sort_key\" not found."
    echo "Possible valid values: $(show_valid_sort_keys)."
    echo
    exit 1
  fi
}

display_version () {
	echo "$script_name Version $script_version"
}

display_help () {
	display_version
	echo "$script_site"
	echo
	echo "Usage: $0 [option... [value]]"
	echo
	echo "-s, --sort (key)	Sorts by the key provided. Valid keys:"
	echo "	    		$(show_valid_sort_keys)"
	echo "-r, --reverse	Reverse-sort the output"
	echo "-V, --version	Display utility version"
	echo "-h, --help	Display this information"
}


## Parse command-line args
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL_ARGS=()
sort_key=""
reverse=0

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      display_help
      echo # Extra newline
      shift # past argument
      exit 1
      ;;
    -V|--version)
      display_version
      shift # past argument
      exit 1
      ;;
    -s|--sort)
      sort_key="$2"
      validate_sort_key "$sort_key"
      shift # past argument
      shift # past value
      ;;
    -r|--reverse)
      reverse=1
      shift
      ;;
#    --default)
#      DEFAULT=YES
#      shift # past argument
#      ;;
    -*)
      echo "Unknown option $1"
      echo
      display_help
      exit 1
      ;;
    *)
      # Save positional arguments, if relevant (unused)
      POSITIONAL_ARGS+=("$1")
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters


##### Start Main Script

models_json=$(get_models_json)
split_values=$(split_json "$models_json")

table_output_raw=$(while IFS= read -r line ; do

	IFS=' ' read -r model_name model_size_bytes model_modified_raw model_param_size_raw model_quant_level <<< "$line"
	# Reformat certain parameters as needed
	model_param_size=$(param_size_fmt "$model_param_size_raw")
	model_size=$(size_fmt "$model_size_bytes")
	model_modified=$(date_fmt_simple "$model_modified_raw")

	echo "$model_name $model_size $model_modified $model_param_size $model_quant_level"
done <<< "$split_values")

# Sort if needed

case "$sort_key" in
  size)
    sort_args=("-h" "-k2")
    ;;
  date|modified)
    sort_args=("-k3")
    ;;
  name)
    sort_args=("-k1")
    ;;
  param_size|parameter_size)
    sort_args=("-h" "-k4")
    ;;    
  quant_level|quantize_level)
    sort_args=("-k5")
    ;;
  *)
    # Don't sort
    sort_args=()
   ;;
esac

# Perform the sort if we need to
if [[ ${#sort_args} == 0 ]]; then
	table_output="$table_output_raw"
else
	if [[ $reverse == 1 ]]; then # Add reverse if needed
		sort_args+=("-r")
       	fi
	table_output=$(sort "${sort_args[@]}" <<< "$table_output_raw")
fi

# Output the actual results, with column headers
column --table --table-columns "Model,Size,Modified,Param Size,Quant Level" --table-right 2,4 <<< "$table_output"

