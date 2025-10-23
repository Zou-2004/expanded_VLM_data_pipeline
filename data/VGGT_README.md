# VGGT Datasets Download Guide

Comprehensive download script for all datasets used in the VGGT (Video Generation Grounded in Text) paper.

## 📊 Datasets Overview

This collection includes 13 major computer vision datasets:

| # | Dataset | Size | Source | Description |
|---|---------|------|--------|-------------|
| 1 | **Aria Digital Twin** | ~100GB | Hugging Face | High-quality indoor scenes with multi-modal data |
| 2 | **Aria Synthetic Environments** | ~50GB | Hugging Face | Synthetic indoor environments |
| 3 | **DL3DV** | ~500GB | Hugging Face | Large-scale 3D video dataset (480P + 960P) |
| 4 | **Kubric** | ~200GB | Google Cloud | Synthetic scenes with 3D annotations |
| 5 | **Mapillary** | ~100GB | Facebook CDN | Street-level imagery with semantic labels |
| 6 | **MegaDepth** | ~300GB | Cornell | Large-scale SfM reconstruction dataset |
| 7 | **Point Odyssey** | ~150GB | Google Drive | Long-term point tracking dataset |
| 8 | **Virtual KITTI** | ~50GB | RWTH Aachen | Synthetic driving scenes |
| 9 | **MVS-Synth** | ~200GB | Hugging Face | Multi-view stereo synthetic data |
| 10 | **CO3D** | ~5.5TB | GitHub | Common Objects in 3D v2 |
| 11 | **Replica** | ~100GB | GitHub | Realistic indoor scenes |
| 12 | **WildRGBD** | ~150GB | Hugging Face | RGB-D data in the wild |
| 13 | **Habitat 2.0** | ~1TB+ | habitat-sim | Scene datasets + task datasets for embodied AI |

**Total Estimated Size:** ~7.5+ TB

## 🚀 Quick Start

### Prerequisites

1. **Operating System:** Linux (Ubuntu 18.04+, CentOS 7+) or macOS
2. **Storage:** At least 7TB of free disk space (for all datasets)
3. **Internet:** Stable high-speed connection
4. **Software:**
   - Conda (Anaconda or Miniconda)
   - Git
   - Basic tools: wget, curl, unzip, tar, 7z

### Installation

1. Clone or download the repository:
```bash
cd /mnt/sdd/zcy/expended_dataset
chmod +x download_vggt_datasets.sh
```

2. Run the script:
```bash
./download_vggt_datasets.sh
```

## 📖 Usage

### Interactive Mode

The script provides an interactive menu:

```
============================================================
       VGGT Datasets Download Script
============================================================
Select download option:

  1) Download ALL datasets (~6+ TB)
  2) Setup environment only
  3) Select specific datasets
  0) Exit

Individual datasets:
  4)  Aria Digital Twin
  5)  Aria Synthetic Environments
  6)  DL3DV (480P + 960P)
  7)  Kubric
  8)  Mapillary
  9)  MegaDepth
  10) Point Odyssey
  11) Virtual KITTI
  12) MVS-Synth
  13) CO3D (5.5 TB)
  14) Replica Dataset
  15) WildRGBD
  16) Habitat 2.0 (Scene + Task Datasets)
============================================================
```

### Command-Line Examples

**Download everything:**
```bash
# Select option 1 from the menu
./download_vggt_datasets.sh
```

**Setup environment only:**
```bash
# Select option 2 from the menu
./download_vggt_datasets.sh
```

**Download specific datasets:**
```bash
# Select option 3, then enter: 4 5 6 16 (for Aria Digital Twin, Aria Synthetic, DL3DV, Habitat 2.0)
./download_vggt_datasets.sh
```

## 📁 Directory Structure

After download, your directory structure will be:

```
expended_dataset/
├── download_vggt_datasets.sh      # Main download script
├── VGGT_README.md                 # This file
├── vggt_download.log              # Download log
├── vggt_datasets/                 # Downloaded datasets
    ├── aria_digital_twin/
    ├── aria_synthetic_environments/
    ├── dl3dv/
    │   ├── 480P/
    │   └── 960P/
    ├── kubric/
    ├── mapillary/
    ├── megadepth/
    ├── point_odyssey/
    ├── virtual_kitti/
    ├── mvs_synth/
    ├── co3d/
    │   ├── co3d_repo/
    │   └── co3d_data/
    ├── replica/
    │   └── replica_data/
    ├── wildrgbd/
    └── habitat2/
        ├── scene_datasets/           # Scene datasets
        │   ├── habitat-test-scenes/
        │   ├── replica_cad/
        │   ├── mp3d/
        │   └── objects/ycb/
        └── datasets/                 # Task/episode datasets
            ├── rearrange_pick/
            ├── pointnav/
            ├── objectnav/
            └── imagenav/
```

## 🔧 Dataset Details

### 1. Aria Digital Twin
- **Source:** Hugging Face (projectaria/aria-digital-twin)
- **Download Method:** huggingface-cli
- **Format:** Various formats (images, depth, poses)
- **Use Case:** Indoor scene understanding, AR/VR

### 2. Aria Synthetic Environments
- **Source:** Hugging Face (projectaria/aria-synthetic-environments)
- **Download Method:** huggingface-cli
- **Format:** Synthetic rendered scenes
- **Use Case:** Training with synthetic data

### 3. DL3DV
- **Source:** Hugging Face (DL3DV/DL3DV-ALL-480P, DL3DV/DL3DV-ALL-960P)
- **Download Method:** huggingface-cli
- **Format:** Two resolutions (480P and 960P)
- **Use Case:** 3D video understanding

### 4. Kubric
- **Source:** Google Cloud Storage (kubric-public bucket)
- **Download Method:** gsutil
- **Format:** TFRecord format
- **Use Case:** Synthetic scene generation
- **Note:** Requires Google Cloud SDK authentication

### 5. Mapillary
- **Source:** Facebook CDN
- **Download Method:** Direct download (curl/wget)
- **Format:** 8 zip files + 1 MD5 checksum
- **Use Case:** Street-level semantic segmentation

### 6. MegaDepth
- **Source:** Cornell University
- **Download Method:** Direct download
- **Format:** .tar.gz archive
- **Use Case:** Structure-from-Motion, depth estimation

### 7. Point Odyssey
- **Source:** Google Drive (folder ID: 1W6wxsbKbTdtV8-2TwToqa_QgLqRY3ft0)
- **Download Method:** gdown
- **Format:** Video sequences with point tracks
- **Use Case:** Long-term point tracking

### 8. Virtual KITTI
- **Source:** RWTH Aachen University
- **Download Method:** Direct download
- **Format:** .zip archive
- **Use Case:** Autonomous driving simulation

### 9. MVS-Synth
- **Source:** Hugging Face (phuang17/MVS-Synth)
- **Download Method:** Direct download from Hugging Face
- **Format:** GTAV_540.tar.gz
- **Use Case:** Multi-view stereo training

### 10. CO3D (Common Objects in 3D v2)
- **Source:** GitHub (facebookresearch/co3d)
- **Download Method:** Official Python script
- **Format:** Chunked downloads (20GB each)
- **Use Case:** Object-centric 3D reconstruction
- **Note:** Very large dataset (5.5 TB)

### 11. Replica Dataset
- **Source:** GitHub (facebookresearch/Replica-Dataset)
- **Download Method:** Bash script (downloads from GitHub releases)
- **Format:** Multi-part tar.gz archives
- **Use Case:** Indoor scene reconstruction

### 12. WildRGBD
- **Source:** Hugging Face (hongchi/wildrgbd)
- **Download Method:** Python script with category selection
- **Format:** Split zip files per category
- **Use Case:** RGB-D object recognition in the wild

### 13. Habitat 2.0 (Scene + Task Datasets)
- **Source:** Facebook Research (habitat-sim utility + direct downloads)
- **Download Method:** habitat-sim datasets_download utility + direct downloads
- **Format:** Multiple scene formats (.glb) and episode datasets (.json.gz)
- **Use Case:** Embodied AI, navigation, manipulation, rearrangement tasks
- **Components:**
  - **Scene Datasets:**
    - Habitat test scenes (89 MB) - For testing
    - ReplicaCAD (123 MB) - Interactive indoor scenes
    - YCB objects (object manipulation)
    - MP3D example scene (sample from Matterport3D)
    - HM3D (requires Matterport credentials, ~130GB)
    - HSSD (requires Hugging Face credentials)
  - **Task Datasets (Episodes):**
    - Rearrange Pick (ReplicaCAD) - 11 MB
    - PointNav Gibson v1 - 385 MB
    - PointNav MP3D v1 - 400 MB
    - ObjectNav MP3D v1 - 170 MB
    - ImageNav (reuses PointNav datasets)
- **Note:** HM3D and HSSD require separate authentication (instructions provided during download)

## ⚙️ Requirements

### Python Environment

The script automatically creates a conda environment named `vggt_download` with:

- Python 3.9
- gdown (Google Drive downloads)
- huggingface_hub[cli] (Hugging Face datasets)
- tqdm (progress bars)
- requests (HTTP requests)
- google-cloud-storage (Google Cloud Storage)

### System Tools

Ensure these are installed:

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y wget curl git unzip tar p7zip-full

# CentOS/RHEL
sudo yum install -y wget curl git unzip tar p7zip p7zip-plugins

# macOS (using Homebrew)
brew install wget curl git p7zip
```

### Google Cloud SDK (for Kubric)

```bash
# Follow instructions at: https://cloud.google.com/sdk/docs/install
# After installation, authenticate:
gcloud auth login
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Conda Environment Issues
```bash
# If conda command not found:
export PATH="$HOME/anaconda3/bin:$PATH"  # or miniconda3
source ~/.bashrc

# If environment activation fails:
conda init bash
source ~/.bashrc
```

#### 2. Google Drive Rate Limiting
```bash
# If gdown fails with rate limit:
# Wait a few hours and retry, or download manually from:
# https://drive.google.com/drive/folders/1W6wxsbKbTdtV8-2TwToqa_QgLqRY3ft0
```

#### 3. Hugging Face Authentication
```bash
# For private datasets, login first:
huggingface-cli login
# Then enter your token from: https://huggingface.co/settings/tokens
```

#### 4. Google Cloud Storage Authentication
```bash
# Authenticate with Google Cloud:
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

#### 5. Disk Space Issues
```bash
# Check available space:
df -h

# Clean up extracted archives if needed:
find vggt_datasets/ -name "*.tar.gz" -delete
find vggt_datasets/ -name "*.zip" -delete
```

#### 6. Network Interruptions
- The script uses `--continue` for wget downloads (resume support)
- For failed downloads, simply re-run the script
- Check `vggt_download.log` for detailed error messages

### Download Verification

After download, verify data integrity:

```bash
# Check dataset sizes
du -sh vggt_datasets/*/

# Verify specific dataset
cd vggt_datasets/
ls -lh aria_digital_twin/
```

## 📊 Performance Tips

### 1. Parallel Downloads
For faster downloads, you can run multiple dataset downloads in parallel:

```bash
# Download 3 small datasets simultaneously
./download_vggt_datasets.sh  # Select 4 (Aria Digital Twin) in one terminal
./download_vggt_datasets.sh  # Select 5 (Aria Synthetic) in another terminal
./download_vggt_datasets.sh  # Select 11 (Virtual KITTI) in a third terminal
```

### 2. Download Order
Recommended download order (small to large):

1. Virtual KITTI (50GB) - Quick test
2. Aria Synthetic (50GB)
3. Mapillary (100GB)
4. Aria Digital Twin (100GB)
5. Replica (100GB)
6. WildRGBD (150GB)
7. Point Odyssey (150GB)
8. MVS-Synth (200GB)
9. Kubric (200GB)
10. MegaDepth (300GB)
11. DL3DV (500GB)
12. Habitat 2.0 (1TB+) - Scene and task datasets
13. CO3D (5.5TB) - Download last

### 3. Storage Management
- Download to a fast SSD for better extraction performance
- Use external HDD/NAS for final storage
- Delete compressed archives after extraction to save space

## 🤖 Habitat 2.0 Special Instructions

### Authentication Required Datasets

#### HM3D (Habitat-Matterport 3D)
1. Register for access: https://matterport.com/habitat-matterport-3d-research-dataset
2. Generate API token: https://my.matterport.com/settings/account/devtools
3. Download using:
```bash
# After activating the vggt_download environment
python -m habitat_sim.utils.datasets_download \
    --username <api-token-id> \
    --password <api-token-secret> \
    --uids hm3d_minival_v0.2 \
    --data-path vggt_datasets/habitat2/
```

#### HSSD (Habitat Synthetic Scene Dataset)
1. Register on Hugging Face: https://huggingface.co/datasets/hssd/hssd-hab
2. Get your Hugging Face token: https://huggingface.co/settings/tokens
3. Download using:
```bash
python -m habitat_sim.utils.datasets_download \
    --username <hf-username> \
    --password <hf-token> \
    --uids hssd-hab \
    --data-path vggt_datasets/habitat2/
```

### Using Habitat Datasets

After downloading, you can use the datasets with Habitat-Lab:

```python
import gym
import habitat.gym

# Load a task with downloaded data
env = gym.make("HabitatRenderPick-v0")
observations = env.reset()

# Or use custom config
import habitat
config = habitat.get_config(
    "benchmark/nav/pointnav/pointnav_habitat_test.yaml"
)
env = habitat.gym.make_gym_from_config(config)
```

For more details, see:
- Habitat-Lab: https://github.com/facebookresearch/habitat-lab
- Habitat-Sim: https://github.com/facebookresearch/habitat-sim
- Documentation: https://aihabitat.org/docs/habitat-lab/

## 📝 Citation

If you use these datasets, please cite the respective papers:

```bibtex
# Aria Digital Twin
@article{aria2023,
  title={Aria Digital Twin: A New Benchmark for Egocentric 3D Machine Perception},
  author={Pan, Xiaqing and others},
  journal={arXiv preprint},
  year={2023}
}

# CO3D
@inproceedings{reizenstein2021common,
  title={Common objects in 3d: Large-scale learning and evaluation of real-life 3d category reconstruction},
  author={Reizenstein, Jeremy and others},
  booktitle={ICCV},
  year={2021}
}

# Replica
@inproceedings{straub2019replica,
  title={The Replica dataset: A digital replica of indoor spaces},
  author={Straub, Julian and others},
  booktitle={arXiv preprint arXiv:1906.05797},
  year={2019}
}

# (Add other citations as needed)
```

## 🤝 Contributing

To add new datasets or improve the download script:

1. Fork the repository
2. Add your dataset download function
3. Update this README
4. Submit a pull request

## 📄 License

Please refer to individual dataset licenses:

- **Aria Digital Twin:** Check Hugging Face page
- **CO3D:** CC BY-NC 4.0
- **Replica:** CC BY-NC 4.0
- **WildRGBD:** Check Hugging Face page
- **(Others):** Check respective dataset pages

## 🆘 Support

For issues or questions:

1. Check the troubleshooting section above
2. Review `vggt_download.log` for error details
3. Check individual dataset documentation
4. Open an issue on the repository

## 📈 Version History

- **v1.0** (2025-01-15): Initial release with 12 VGGT datasets

---

**Last Updated:** January 15, 2025  
**Maintainer:** ZCY  
**Repository:** https://github.com/Zou-2004/expanded_VLM_data_pipeline.git
