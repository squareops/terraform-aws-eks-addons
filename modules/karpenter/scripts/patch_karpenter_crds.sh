#!/bin/bash

set -e

echo "Patching Karpenter CRDs with Helm labels and annotations..."

# Define CRD names
CRDS=(
  "ec2nodeclasses.karpenter.k8s.aws"
  "nodepools.karpenter.sh"
  "nodeclaims.karpenter.sh"
)

# Define Helm release name (should match Terraform Helm release)
HELM_RELEASE="karpenter-crd"  # Make sure this matches your Helm release name
KARPENTER_NAMESPACE="karpenter"  # Change if using a different namespace

# Apply Helm labels and annotations if the CRD exists
for CRD in "${CRDS[@]}"; do
  if kubectl get crd "$CRD" > /dev/null 2>&1; then
    echo "Patching $CRD..."
    kubectl label crd "$CRD" app.kubernetes.io/managed-by=Helm --overwrite
    kubectl annotate crd "$CRD" meta.helm.sh/release-name="$HELM_RELEASE" --overwrite
    kubectl annotate crd "$CRD" meta.helm.sh/release-namespace="$KARPENTER_NAMESPACE" --overwrite
  else
    echo "CRD $CRD does not exist. Skipping..."
  fi
done

echo "Karpenter CRDs patching completed!"
