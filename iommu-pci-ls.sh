#!/bin/bash
# Kanged from https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF
# List each PCI device and its IOMMU group
shopt -s nullglob
for d in /sys/kernel/iommu_groups/*/devices/*; do 
    n=${d#*/iommu_groups/*}; n=${n%%/*}
    printf 'IOMMU Group %s ' "$n"
    lspci -nns "${d##*/}"
done;
