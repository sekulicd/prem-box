#!/bin/bash

owner="premai-io"

app="app"
app_repo="prem-app"
app_image="prem-app"

daemon="daemon"
daemon_repo="prem-daemon"
daemon_image="premd"


# JSON file
json_file="versions.json"

# Function to fetch latest GitHub tag and Docker image digest
bump_to_latest_tag() {
    # Fetch latest release tag from GitHub
    latest_release=$(curl -s https://api.github.com/repos/${owner}/${1}/releases/latest | jq -r .tag_name)
    echo "Latest release tag: $latest_release"

    # Assuming Docker image tag follows the same naming convention as the GitHub tag
    # Pull the Docker image from GitHub Container Registry
    image=ghcr.io/${owner}/${3}:$latest_release
    echo "Pulling image: $image"
    docker pull ${image} &> /dev/null

    # Get the Docker image digest
    image_digest=$(docker inspect --format='{{.RepoDigests}}' ghcr.io/${owner}/${3}:$latest_release | awk -F '@' '{print $2}' | tr -d '[]')
    echo "Image digest: $image_digest"


    # Update JSON with new tag and digest
    jq --arg rep "$2" --arg ver "$latest_release" --arg dig "$image_digest" \
    '.prem[$rep].version = $ver | .prem[$rep].digest = $dig' $json_file > temp.json && mv temp.json $json_file
}

# Fetch info for repo
bump_to_latest_tag $app_repo $app $app_image

# Fetch info for repo2
bump_to_latest_tag $daemon_repo $daemon $daemon_image
