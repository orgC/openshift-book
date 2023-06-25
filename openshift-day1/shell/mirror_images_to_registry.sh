#!/usr/bin/env bash

images_file=$1
echo "images_file: "$images_file

dest_registry="quay.ocp.example.com"
from_redhat=${from_redhat:-"true"}

auth_file='/root/install/all-secret.json'

for line in `cat $images_file`;do
  redhat_domain=$(echo $line | awk -F '/' '{print $1}')
  if [[ $from_redhat == "true" ]]; then
    src_image_name=$line
  else
    src_image_name=$(echo $line | sed "s/${redhat_domain}/${src_registry}/g")
  fi
  dest_image_name=$(echo $line | awk -F '@' '{print $1} '| sed "s/${redhat_domain}/${dest_registry}/g")
  sha=$(echo $line | awk -F '@' '{print $2} ')
  tag=$(echo $line | awk -F ':' '{print $2}')
  if [[ "$sha" == "sha256"* ]]; then
    tag=${tag:0:8}
    dest_image_name=$dest_image_name:$tag
  fi

  echo "========================================="
  echo "oc image mirror $src_image_name $dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*' --insecure=true"
  echo "========================================="
  oc image mirror $src_image_name $dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*'
  echo ""
done

