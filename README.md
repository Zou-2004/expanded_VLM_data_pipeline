# Expanded VLM Data Pipeline

Comprehensive collection of dataset download scripts for computer vision and embodied AI research.

## 📦 Overview

This repository contains automated download scripts for multiple large-scale datasets used in:
- **Original 7 Datasets** - DynamicReplica, IRs, Structured3D, BlendedMVS, ml-hypersim, TartanAir, Taskonomy
- **VGGT Paper Datasets** - 13 datasets including Aria, DL3DV, Kubric, Mapillary, CO3D, Habitat 2.0, and more

**Total Combined Size:** ~24+ TB

## 🚀 Quick Start

### Original Datasets (7 datasets, ~16.9 TB)
```bash
cd data
./download_all_datasets.sh
```

### VGGT Datasets (13 datasets, ~7.5 TB)
```bash
cd data
./download_vggt_datasets.sh
```

## 📚 Documentation

### Original Datasets
- **Script:** [`data/download_all_datasets.sh`](data/download_all_datasets.sh)
- **Documentation:** [`data/README.md`](data/README.md)
- **Datasets:**
  1. DynamicReplica - 150GB ([details](data/DynamicReplica.md))
  2. IRs - OneDrive download ([details](data/IRs.md))
  3. Structured3D - 800GB ([details](data/Structured_3d.md))
  4. BlendedMVS - 190GB (low-res)
  5. ml-hypersim - 1.9TB
  6. TartanAir - 3TB + 25GB test data
  7. Taskonomy - 11TB

### VGGT Paper Datasets
- **Script:** [`data/download_vggt_datasets.sh`](data/download_vggt_datasets.sh)
- **Documentation:** [`data/VGGT_README.md`](data/VGGT_README.md)
- **Habitat 2.0 Addition:** [`data/HABITAT2_ADDITION.md`](data/HABITAT2_ADDITION.md)
- **Datasets:**
  1. Aria Digital Twin - 100GB
  2. Aria Synthetic Environments - 50GB
  3. DL3DV - 500GB (480P + 960P)
  4. Kubric - 200GB
  5. Mapillary - 100GB
  6. MegaDepth - 300GB
  7. Point Odyssey - 150GB
  8. Virtual KITTI - 50GB
  9. MVS-Synth - 200GB
  10. CO3D - 5.5TB
  11. Replica - 100GB
  12. WildRGBD - 150GB
  13. Habitat 2.0 - 1TB+ (Scene + Task datasets)

## 🔧 Features

### Multi-Source Support
- ✅ **Direct Downloads** - wget/curl with resume support
- ✅ **Google Drive** - gdown for large files
- ✅ **OneDrive** - curl with URL conversion
- ✅ **Hugging Face** - huggingface-cli for datasets
- ✅ **Google Cloud Storage** - gsutil for GCS buckets
- ✅ **GitHub Repositories** - Clone and run official scripts
- ✅ **Facebook CDN** - Direct downloads from Meta

### Smart Features
- 🎯 Interactive menu for dataset selection
- 🔄 Resume interrupted downloads
- 📊 Progress tracking and logging
- 🎨 Color-coded terminal output
- 🔧 Automatic environment setup (conda)
- 📦 Automatic extraction (tar.gz, zip, 7z)
- 🚫 No hardcoded paths (fully portable)

## 📋 Requirements

- **OS:** Linux (Ubuntu 18.04+, CentOS 7+) or macOS
- **Storage:** 7TB - 25TB depending on datasets
- **Tools:** wget, curl, git, unzip, tar, 7z
- **Python:** Anaconda or Miniconda
- **Network:** Stable high-speed internet connection

## 📖 Usage Examples

### Download Everything
```bash
cd data
./download_all_datasets.sh       # Select option 1
./download_vggt_datasets.sh      # Select option 1
```

### Download Specific Datasets
```bash
cd data
./download_vggt_datasets.sh      # Select option 3
# Then enter: 4 5 16 (for Aria Digital Twin, Aria Synthetic, Habitat 2.0)
```

### Setup Environment Only
```bash
cd data
./download_vggt_datasets.sh      # Select option 2
```

## 📁 Directory Structure

```
expended_dataset/
├── README.md                    # This file
├── data/                        # All download scripts and docs
│   ├── download_all_datasets.sh       # Original 7 datasets
│   ├── download_vggt_datasets.sh      # VGGT 13 datasets
│   ├── README.md                      # Original datasets docs
│   ├── VGGT_README.md                 # VGGT datasets docs
│   ├── HABITAT2_ADDITION.md           # Habitat 2.0 details
│   ├── DynamicReplica.md
│   ├── IRs.md
│   └── Structured_3d.md
├── downloaded_datasets/         # Original datasets download location
├── vggt_datasets/              # VGGT datasets download location
├── BlendedMVS/                 # BlendedMVS project structure
├── ml-hypersim/                # Hypersim project structure
├── tartanair_tools/            # TartanAir tools
├── taskonomy/                  # Taskonomy project structure
└── Dataset_from_VGGT/          # VGGT dataset references
```

## 🤝 Contributing

Feel free to:
- Add new datasets
- Improve download scripts
- Fix bugs
- Update documentation

## 📄 License

Please refer to individual dataset licenses:
- Most datasets: Research/Non-commercial use only
- Check each dataset's terms before use

## 🆘 Support

For issues:
1. Check the troubleshooting sections in the documentation
2. Review log files (`*_download.log`)
3. Check individual dataset documentation
4. Open an issue on GitHub

## 📊 Dataset Size Summary

| Category | Datasets | Size |
|----------|----------|------|
| Original Collection | 7 | ~16.9 TB |
| VGGT Collection | 13 | ~7.5 TB |
| **Total** | **20** | **~24+ TB** |

## 🔗 Related Repositories

- [Habitat-Lab](https://github.com/facebookresearch/habitat-lab) - Embodied AI platform
- [Habitat-Sim](https://github.com/facebookresearch/habitat-sim) - 3D simulator
- [CO3D](https://github.com/facebookresearch/co3d) - Common Objects in 3D
- [Replica Dataset](https://github.com/facebookresearch/Replica-Dataset) - Indoor scenes
- [WildRGBD](https://github.com/wildrgbd/wildrgbd) - RGB-D in the wild

## 📝 Citation

If you use these datasets, please cite the respective papers as detailed in the individual README files.

---

**Repository:** https://github.com/Zou-2004/expanded_VLM_data_pipeline.git  
**Last Updated:** October 23, 2025  
**Maintainer:** ZCY
