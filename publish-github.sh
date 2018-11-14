#!/bin/bash

# Deploy Hugo site to GitHub Pages (master branch)
#
# Adapted from Joshua Powers' script: https://powersj.io/post/github-hugo/
# Main differences being the removal of submodules, some
# stylistic choices, and allowing more assumptions.
#
# Requires the current branch to be 'source', builds the site in the
# 'public' directory, then pushes that directory to the master branch.
# GitHub Pages automatically publishes the contents.

set -uex

BRANCH_CURRENT=$(git rev-parse --abbrev-ref HEAD)
GIT_REMOTE="origin"
GIT_REMOTE_URL=$(git remote get-url --push "${GIT_REMOTE}")
PUBLISH_DIR="public"

cleanup() {
    if [ -d "${PUBLISH_DIR}" ]; then
        rm -rf "${PUBLISH_DIR}"
    fi
}

error() {
    echo "$@" 1>&2
    exit 1
}

if [ "${BRANCH_CURRENT}" != "source" ]; then
    echo("Not on source branch!")
fi

echo "Updating Git submodules..."
git submodule init
git submodule update

echo "Building the Hugo site..."
cleanup
hugo --destination "${PUBLISH_DIR}"

echo "Committing to master branch..."
cd "${PUBLISH_DIR}"
git init
git remote add "${GIT_REMOTE}" "${GIT_REMOTE_URL}"
git checkout --orphan master
git add .
git commit -m "Site published: $(date -Iseconds -u) UTC, $(date -Iseconds) local"

echo "Publishing site..."
git push --force "${GIT_REMOTE}" master

echo "Publish complete!"
cd -
cleanup
