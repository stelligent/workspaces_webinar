#!/bin/bash

BUNDLE_ID=$1
DIRECTORY_ID=$2
USER=$3

aws workspaces create-workspaces --workspaces DirectoryId=${DIRECTORY_ID},UserName=${USER},BundleId=${BUNDLE_ID}
