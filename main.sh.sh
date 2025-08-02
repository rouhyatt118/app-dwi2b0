#!/bin/bash
#PBS -l nodes=1:ppn=1,vmem=8g,walltime=2:00:00
#PBS -N app-registration-dwi2anat
#PBS -V


#set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/"
split_b0s=${SCRIPT_DIR}/split_b0s.sh
merge_b0s=${SCRIPT_DIR}/merge_b0s.sh

### === Load parameters from config.json ===
dwi=$(jq -r '.dwi' config.json)
bvals=`jq -r '.bvals' config.json`
bvecs=`jq -r '.bvecs' config.json`
template=`jq -r '.template' config.json`

dwi_b0s=${SCRIPT_DIR}/dwi_b0s.nii.gz
dwi_b0s_bvec=${SCRIPT_DIR}/dwi_b0s.bvecs
dwi_b0s_bval=${SCRIPT_DIR}/dwi_b0s.bvals

singularity exec -e docker://brainlife/mrtrix3:3.0.3 dwiextract -shell 0 -fslgrad $bvecs $bvals $dwi $dwi_b0s -export_grad_fsl $dwi_b0s_bvec $dwi_b0s_bval

mkdir b0

if [ "${template}" == "true" ]; then
  singularity exec -e docker://brainlife/mrtrix3:3.0.3 \
    bash ${split_b0s} $dwi_b0s b0
singularity exec -e docker://brainlife/ants:2.3.1 \
  antsMultivariateTemplateConstruction2.sh -h
singularity exec -e docker://brainlife/ants:2.3.1 \
    bash ${merge_b0s} Template_b  b0_0*.nii.gz
  mv Template_btemplate0.nii.gz b0/dwi.nii.gz
else
  singularity exec -e docker://brainlife/mrtrix3:3.0.3 mrmath -axis 3 $dwi_b0s mean b0_avg.nii.gz
  mv b0_avg.nii.gz b0/dwi.nii.gz
fi

mkdir b0_series

mv ${dwi_b0s} b0_series/dwi.nii.gz
mv ${dwi_b0s_bvec} b0_series/dwi.bvecs
mv ${dwi_b0s_bval} b0_series/dwi.bvals

