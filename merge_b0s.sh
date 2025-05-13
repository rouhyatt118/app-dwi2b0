#!/usr/bin/env bash
#------------------------------------------------------------------
# Script: ants_rigid_template_construction.sh
# Purpose: Generate a group template from a set of anatomical images
#          using only rigid-body registration (no affine or nonlinear steps).
# Usage: ./ants_rigid_template_construction.sh <output_prefix> <image1> <image2> [image3 ...]
# Requirements:
#   - ANTs (antsMultivariateTemplateConstruction2.sh) installed and in PATH
#   - Input images should be skull-stripped, bias-corrected, and in the same space
#   - Sufficient memory and cores for parallel execution
#------------------------------------------------------------------

# Function to estimate available CPU cores based on system load
CPUs_available() {
    local cpu_load=$( top -b -n2 | grep "Cpu(s)" | awk '{print $2+$4}' | tail -n1 )
    local cpu_num_all=$( getconf _NPROCESSORS_ONLN )
    # estimate used cores
    local used=$( printf "%.0f" "$(echo "$cpu_load/100*$cpu_num_all" | bc -l)" )
    echo $(( cpu_num_all - used ))
}

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <output_prefix> <image1> <image2> [image3 ...]"
  exit 1
fi

# Parse arguments
OUTPUT_PREFIX=$1
shift
INPUT_IMAGES=("$@")

# Rigid‐only template construction parameters
DIMENSION=3                       # 3D images
ITERATIONS=1                      # template‐building iterations
CPU_CORES=$(nproc)                # number of local cores

# Create output directory
mkdir -p "${OUTPUT_PREFIX}_rigid_template"

# Run ANTs multivariate template construction (rigid only, serial)
echo "antsMultivariateTemplateConstruction2.sh   -d ${DIMENSION}   -c 0  -n 0  -q  100x100x0x0  -j ${CPU_CORES}  -i ${ITERATIONS}  -k 1  -m CC[4]  -t Rigid  -o "${OUTPUT_PREFIX}" "${INPUT_IMAGES[@]}""

antsMultivariateTemplateConstruction2.sh   -d ${DIMENSION}   -c 0  -n 0  -q  100x100x0x0  -j ${CPU_CORES}  -i ${ITERATIONS}  -k 1  -m CC[4]  -t Rigid  -o "${OUTPUT_PREFIX}" "${INPUT_IMAGES[@]}"

# Output:
#   * Template0.nii.gz  (resulting group template)
#   * Warp and inverse transforms from each subject to template
# Notes:
#  - This pipeline uses only rigid-body alignment. For affine or
#    nonlinear templates, include additional transforms.
#  - Adjust CPU_CORES, METRIC_PARAMS, and TRANSFORM parameters as needed.
#------------------------------------------------------------------
