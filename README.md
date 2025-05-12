# DWI-to-b0 

A reproducible and automated pipeline to extract non–diffusion-weighted (b₀) volumes from diffusion-weighted imaging (DWI) series and, optionally, construct an unbiased b₀ template using ANTs. The workflow supports configurable execution via containerized environments (Singularity) and HPC schedulers.

---

## Author

**Gabriele Amorosino**
(email: [gabriele.amorosino@utexas.edu](mailto:gabriele.amorosino@utexas.edu))

---

## Description

This pipeline isolates all b₀ images from a 4D DWI dataset, exports the corresponding `.bval` and `.bvec` gradient files, and computes either a simple voxel-wise average or a template using ANTs’ template construction. Configuration is handled via a `config.json` file, ensuring reproducible execution on both local and cluster environments.

---

## Usage

### Running on Brainlife.io via Web UI

1. Navigate to [Brainlife.io](https://brainlife.io) and locate the **app-dwi2b0** application.
2. In the **Execute** tab, upload:

   * DWI file (`.nii.gz` or `.mif`)
   * Optionally, a **config.json** to override default settings
3. Launch the job. Outputs will include extracted b₀ volumes, and average b0 or an ANTs-derived template if enabled.

### Running on Brainlife.io via CLI

```bash
# Install the Brainlife CLI
pip install brainlife-cli

# Authenticate
bl login

# Execute the app
bl app run --id gh:gamorosino/app-dwi2b0 \
  --project <project_id> \
  --input dwi:<dwi_id> \
  --input bvals:<bval_id> \
  --input bvecs:<bvec_id> \
  --input template:<true_or_false>
```

Replace `<...>` with your project and dataset identifiers.

### Running Locally

1. Clone this repository:

   ```bash
   git clone https://github.com/gamorosino/app-dwi2b0.git
   cd app-dwi2b0
   ```
2. Create or edit `config.json`:

   ```json
   {
     "dwi":      "sub-01_dwi.mif",
     "bvals":    "sub-01.bval",
     "bvecs":    "sub-01.bvec",
     "template": true
   }
   ```
3. Submit or run directly:

   ```bash
   bash main.sh
   ```

---

## Outputs

* **b0/** — directory containing:

  * `dwi.nii.gz` — average b₀ or ANTs-derived template
* **dwi/** — directory containing:

  * `dwi.nii.gz` — raw extracted b₀ volumes
  * `dwi.bval`, `dwi.bvec` — corresponding gradient files

---

## Requirements

* [Singularity](https://sylabs.io) ≥ 3.0

---


## Citation

If using the ANTs template component, please cite:

- Avants BB, Tustison NJ, Song G, Cook PA, Klein A, Gee JC. A reproducible evaluation of ANTs similarity metric performance in brain image registration. *NeuroImage*. 2011;54(3):2033–2044. PMID: 20851191.
- Tournier et al., MRtrix3: A fast, flexible and open software framework for medical image processing and visualisation, NeuroImage, 2019.
- Hayashi, S., Caron, B.A., et al. brainlife.io: a decentralized and open-source cloud platform to support neuroscience research. Nat Methods 

---

## License

This project is released under the [MIT License](LICENSE).
