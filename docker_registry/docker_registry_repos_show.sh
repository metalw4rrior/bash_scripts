#!/bin/bash

USER="your"
PASS="your"
REGISTRY="your"

# список репозиториев
repos=$(curl -s -u $USER:$PASS http://$REGISTRY/v2/_catalog | jq -r '.repositories[]')

#  список тегов
for repo in $repos; do
  echo "Repo: $repo"
  tags=$(curl -s -u $USER:$PASS http://$REGISTRY/v2/$repo/tags/list | jq -r '.tags[]?')
  if [ -z "$tags" ]; then
    echo "  (no tags)"
  else
    for tag in $tags; do
      echo "  - $tag"
    done
  fi
done
