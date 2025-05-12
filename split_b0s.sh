#!/usr/bin/env bash
#------------------------------------------------------------------
# Script: split_4D_to_3D.sh
# Purpose: Split a 4D MRtrix/MRI image into separate 3D volumes.
# Usage:   ./split_4D_to_3D.sh <input_4D> <output_prefix> [nthreads]
# Example: ./split_4D_to_3D.sh dwi_b0s.nii.gz b0 4
# Requirements:
#   - MRtrix3 (mrinfo, mrconvert) in your PATH
#   - Bash >=4.2 for negative‐index arrays (or fallback shown below)
#------------------------------------------------------------------



if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <input_4D> <output_prefix> [nthreads]"
  exit 1
fi

IN="$1"              # e.g. dwi_b0s.nii.gz
PREFIX="$2"          # e.g. b0
NTHREADS="${3:-1}"   # optional: number of threads for mrconvert

# 1) Query image size (X Y Z V) into an array
size=( $(mrinfo "$IN" -size) )
#    size=(192 192 132 3)  # example

# 2) Extract the number of volumes (last element)
#    Method A: negative indexing (Bash ≥4.2)
N_volumes=${size[-1]}

#    # Method B (more portable):
#    # len=${#size[@]}
#    # N_volumes=${size[$((len - 1))]}

echo "Found $N_volumes volumes in '$IN'"

# 3) Loop over each volume and export as a 3D file
for (( i=0; i< N_volumes; i++ )); do
  # zero‐padded index, e.g. 002
  idx=$(printf "%03d" "$i")
  out="${PREFIX}_${idx}.nii.gz"

  echo "Extracting volume $i → $out"
  mrconvert "$IN" \
    -force -nthreads "$NTHREADS" \
    -coord 3 "$i" \
    "$out"
done

echo "Done: split into ${PREFIX}_000.nii.gz … ${PREFIX}_$(printf "%03d" $((N_volumes-1))).nii.gz"
