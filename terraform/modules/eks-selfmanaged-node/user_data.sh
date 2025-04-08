#!/bin/bash
set -o xtrace
systemctl stop kubelet
/etc/eks/bootstrap.sh \
    --kubelet-extra-args '--node-labels=${join(",", [for label, value in node_labels : "${label}=${value}"])}' \
    ${cluster_name}