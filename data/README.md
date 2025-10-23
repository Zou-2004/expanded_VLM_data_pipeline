# Dataset Download Guide

## Quick Start

Run the comprehensive download script:
```bash
./download_all_datasets.sh
```

## Datasets Included

### 1. DynamicReplica (~150GB COMPLETE)
- **Source**: Facebook Research
- **Type**: Dynamic scene reconstruction
- **Download**: Direct URLs from Facebook servers
- **Components**: Real, validation, test, training (ALL 86 files)

### 2. IRs Dataset (OneDrive - Auto Download)
- **Source**: OneDrive link
- **Type**: Image retrieval dataset  
- **Download**: Automatic via curl (OneDrive URL conversion)
- **Fallback**: Manual download if auto-download fails

### 3. Structured3D (~800GB COMPLETE)
- **Source**: Zhejiang University & Kujiale
- **Type**: Large-scale 3D indoor scenes
- **Download**: Direct URLs
- **Components**: Panorama, perspective (full + empty), 3D bounding boxes, structure annotations

### 4. BlendedMVS (~190GB LOW-RESOLUTION ONLY)
- **Source**: GitHub releases + OneDrive fallback
- **Type**: Multi-view stereo dataset
- **Components**: 
  - BlendedMVS (original) - ~27GB
  - BlendedMVS+ - ~81GB  
  - BlendedMVS++ - ~80GB
- **Note**: Only low-resolution versions, OneDrive fallback if GitHub fails

### 5. ml-hypersim (~1.9TB COMPLETE)
- **Source**: Apple GitHub repository
- **Type**: Photorealistic synthetic indoor scenes
- **Download**: Full dataset download initiated
- **Note**: Complete dataset with all scenes

### 6. TartanAir (~3TB COMPLETE)
- **Source**: CMU AirLab
- **Type**: SLAM simulation dataset
- **Download**: Full dataset with all modalities
- **Components**: RGB, depth, segmentation, optical flow (all cameras, all difficulties)

### 7. Taskonomy (~11TB COMPLETE)
- **Source**: Stanford Vision Lab via Omnidata
- **Type**: Multi-task computer vision dataset
- **Download**: Full dataset (fullplus subset)
- **Note**: Complete multi-task dataset with all annotations

## Usage Options

### Option 1: Download All Complete Datasets (~16.9TB)
```bash
./download_all_datasets.sh
# Choose option 1 when prompted
```

### Option 2: Setup All (Minimal Downloads + Scripts)
```bash
./download_all_datasets.sh
# Choose option 2 when prompted
```

### Option 3: Custom Selection
```bash
./download_all_datasets.sh
# Choose option 3 and select specific datasets
```

## Manual Steps Required

### For IRs Dataset:
1. Visit the OneDrive link provided in the script output
2. Download files manually
3. Place in `downloaded_datasets/IRs/` directory

### For Large Datasets (Hypersim, TartanAir, Taskonomy):
1. Navigate to respective directories in `downloaded_datasets/`
2. Run the provided sample scripts
3. Modify scripts to download full datasets if needed

## Dependencies

The script automatically installs:
- wget/curl for downloads
- unzip, p7zip-full for extraction
- Python packages: boto3, colorama, minio, omnidata-tools
- System tools: git, aria2

## Environment Setup

- Creates conda environment `dataset_download` if conda is available
- Falls back to pip installation if conda not found
- Installs all required dependencies automatically

## Output Structure

```
downloaded_datasets/
├── DynamicReplica/          # Dynamic scene data
├── IRs/                     # Image retrieval (manual download)
├── Structured3D/            # 3D indoor scenes
├── BlendedMVS/              # Multi-view stereo
├── ml-hypersim/             # Photorealistic synthetic (repo + tools)
├── TartanAir/               # SLAM simulation (tools + sample)
├── Taskonomy/               # Multi-task vision (tools + sample)
├── download.log             # Download log
└── DATASET_SUMMARY.md       # Detailed summary
```

## Tips

1. **Storage Requirements**: Ensure sufficient disk space (~16.9TB for complete datasets)
2. **Network**: Downloads may take days/weeks depending on connection
3. **Resumable**: Most downloads support resume if interrupted
4. **Extraction**: Archives are automatically extracted when possible
5. **Logging**: All operations logged to `download.log`
6. **BlendedMVS**: Only low-resolution versions downloaded as requested
7. **Large Datasets**: Script includes confirmation prompts for multi-TB downloads

## Troubleshooting

### If download fails:
- Check internet connection
- Re-run script (supports resume)
- Check log file for specific errors

### If extraction fails:
- Ensure p7zip-full is installed for .7z files
- Check available disk space
- Manual extraction may be needed for some formats

### For conda issues:
- Script falls back to pip if conda unavailable
- Manually create environment if needed

## Repository Cloning

For datasets hosted on GitHub (ml-hypersim), the script:
1. Clones the repository to get tools and scripts
2. Sets up download scripts
3. Provides instructions for actual data download

This approach ensures you have all necessary tools while managing storage efficiently.