#!/bin/bash

if [ -z "$1" ]; then
  echo "имя нового namespace как аргумент:"
  echo "пример: ./automatic_namespace_copy.sh new-namespace"
  exit 1
fi

TARGET_NS="$1"

echo "namespace: $TARGET_NS"

FILES=("secrets.yaml" "configmaps.yaml" "rbac.yaml" "np.yaml")

for file in "${FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo " $file ukrali tsigane."
    continue
  fi

  echo " processing $file..."

  yq e ".items[].metadata.namespace = \"$TARGET_NS\"" -i "$file"

  yq e "del(.items[].metadata.uid, .items[].metadata.resourceVersion, .items[].metadata.creationTimestamp)" -i "$file"

  kubectl apply -f "$file"
done

echo "exist or not. namespace..."
kubectl get ns "$TARGET_NS" >/dev/null 2>&1 || {
  echo "creating namespace $TARGET_NS..."
  kubectl create ns "$TARGET_NS"
}

echo "otrabotalo blya"
