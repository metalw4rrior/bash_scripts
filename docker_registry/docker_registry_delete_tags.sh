REGISTRY="your"
REPO="your"
USER="your"
PASS="your"

# все теги
tags=$(curl -s -u $USER:$PASS "http://$REGISTRY/v2/$REPO/tags/list" | jq -r '.tags[]')

for tag in $tags; do
  echo "Deleting tag: $tag"
  # digest манифеста для тега
  digest=$(curl -s -I -u $USER:$PASS -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "http://$REGISTRY/v2/$REPO/manifests/$tag" | grep Docker-Content-Digest | awk '{print $2}' | tr -d $'\r')

  # удаляем манифест по digest
  curl -v -X DELETE -u $USER:$PASS "http://$REGISTRY/v2/$REPO/manifests/$digest"
done
