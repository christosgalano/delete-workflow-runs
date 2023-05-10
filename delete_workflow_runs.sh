#!/bin/bash

### Functions ###

# Dispaly help message
function display_help() {
    echo "Usage: $0 -o owner -r repo -t token [-w workflow]"
    echo ""
    echo "Options:"
    echo " -o,  specify repository owner                                     (required)"
    echo " -r,  specify repository name                                      (required)"
    echo " -t,  specify api token to get and delete the workflow/s           (required)"
    echo " -w,  specify workflow to delete or \"all\" which is the default   (optional)"
    echo " -h,  display this help message and exit"
    echo ""
}

# Parse input
function parse_params() {
    while getopts ":o:r:t:w:h-:" opt; do
        case $opt in
        o )
            owner=$OPTARG
            ;;
        r )
            repo=$OPTARG
            ;;
        t )
            token=$OPTARG
            ;;
        w )
            workflow=$OPTARG
            ;;
        h )
            display_help
            exit 0
            ;;
        * )
            echo "Invalid option: $1" >&2
            display_help
            exit 1
            ;;
        esac
    done
}

# Check if all required options are provided
function validate_params() {
    if [ -z "$owner" ] || [ -z "$repo" ] || [ -z "$token" ]; then
        echo "Error: All options -o, -r, -t are required"
        display_help
        exit 1
    fi
}

# Delete a workflow run id
function delete_run() {
    curl -s \
    -X DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $token"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$owner/$repo/actions/runs/$1
    echo "Successfully deleted run with id: $1."
}


### Script ###

# Parse and validate parameters
parse_params "$@"
validate_params

# If workflow is not provided or is "all" then get all the runs
if [ -z "$workflow" ] || [ "$workflow" == "all" ]; then
    run_ids=( $(curl -s \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $token" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "https://api.github.com/repos/$owner/$repo/actions/runs?per_page=100" | jq '.workflow_runs[].id') )
else
    # Get the id of the given workflow
    workflow_id=$(curl -s \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $token"\
    -H "X-GitHub-Api-Version: 2022-11-28" \
    https://api.github.com/repos/$owner/$repo/actions/workflows | jq --arg name "$workflow" '.workflows[] | select(.name == $name) | .id')
    
    # If workflow_id is empty then the workflow does not exist
    if [ -z "$workflow_id" ]; then
        echo "Error: Workflow \"$workflow\" not found"
        exit 1
    fi

    # Get the id of all the runs of the given workflow
    run_ids=( $(curl -s \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer $token" \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            "https://api.github.com/repos/$owner/$repo/actions/workflows/$workflow_id/runs?per_page=100" | jq '.workflow_runs[].id') )
fi

# Delete all the runs
for id in ${run_ids[@]}
do
    delete_run $id
done