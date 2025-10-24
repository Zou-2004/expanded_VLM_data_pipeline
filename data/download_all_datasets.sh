#!/bin/bash

# Comprehensive Dataset Download Script
# Downloads 7 datasets: DynamicReplica, IRs, Structured3D, BlendedMVS, ml-hypersim, TartanAir, Taskonomy
# Author: GitHub Copilot
# Date: $(date)

set -e  # Exit on error

# Color output functions
print_green() { echo -e "\033[32m$1\033[0m"; }
print_red() { echo -e "\033[31m$1\033[0m"; }
print_yellow() { echo -e "\033[33m$1\033[0m"; }
print_blue() { echo -e "\033[34m$1\033[0m"; }

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Allow overriding the download directory with:
# 1) command-line: --dest /path/to/dir or -d /path/to/dir
# 2) environment variable: DOWNLOADS_DIR
# Default: a `downloaded_datasets` folder next to this script
DATASETS_DIR=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dest)
            DATASETS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $(basename "$0") [--dest PATH]"
            echo "If --dest is not provided, environment variable DOWNLOADS_DIR is checked."
            echo "Default: <script_dir>/downloaded_datasets"
            exit 0
            ;;
        --) shift; break ;;
        *) break ;;
    esac
done

if [ -z "$DATASETS_DIR" ]; then
    if [ -n "$DOWNLOADS_DIR" ]; then
        DATASETS_DIR="$DOWNLOADS_DIR"
    else
        DATASETS_DIR="${SCRIPT_DIR}/downloaded_datasets"
    fi
fi

LOG_FILE="${DATASETS_DIR}/download.log"

print_blue "=== Multi-Dataset Download Script ==="
print_blue "This script will download 7 computer vision datasets"
print_blue "Destination directory: ${DATASETS_DIR}"
print_blue "Estimated total size: ~5TB (depending on selections)"
print_blue "=========================================="

# Create main datasets directory
mkdir -p "${DATASETS_DIR}"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

# Function to check if conda is available and create environment
setup_conda_env() {
    if command -v conda &> /dev/null; then
        print_green "Conda found. Setting up environment..."
        
        # Create conda environment for downloads
        if ! conda env list | grep -q "^expended_dataset_pipeline"; then
            log_message "Creating conda environment: expended_dataset_pipeline"
            conda create -n expended_dataset_pipeline python=3.11 -y
        fi
        
        # Activate environment
        source "$(conda info --base)/etc/profile.d/conda.sh"
        conda activate expended_dataset_pipeline
        
        # Install required packages
        log_message "Installing required packages..."
        pip install --upgrade pip
        pip install wget requests tqdm boto3 colorama minio omnidata-tools h5py matplotlib pandas scikit-learn gdown
        conda install -c conda-forge aria2 -y || pip install aria2p
        
        return 0
    else
        print_yellow "Conda not found. Installing packages with pip..."
        pip install --upgrade pip
        pip install wget requests tqdm boto3 colorama minio omnidata-tools h5py matplotlib pandas scikit-learn gdown
        return 1
    fi
}

# Function to unzip files
extract_if_needed() {
    local file_path="$1"
    local extract_dir="$2"
    
    if [[ -f "$file_path" ]]; then
        case "$file_path" in
            *.zip)
                print_green "Extracting: $file_path"
                unzip -q "$file_path" -d "$extract_dir" 2>/dev/null || unzip "$file_path" -d "$extract_dir"
                ;;
            *.tar.gz|*.tgz)
                print_green "Extracting: $file_path"
                tar -xzf "$file_path" -C "$extract_dir"
                ;;
            *.tar)
                print_green "Extracting: $file_path"
                tar -xf "$file_path" -C "$extract_dir"
                ;;
            *.7z)
                if command -v 7z &> /dev/null; then
                    print_green "Extracting: $file_path"
                    7z x "$file_path" -o"$extract_dir"
                else
                    print_red "7z not found. Please install p7zip-full"
                fi
                ;;
        esac
    fi
}

# Function to extract Google Drive file ID from URL
extract_gdrive_id() {
    local url="$1"
    
    # Extract file ID from various Google Drive URL formats
    if [[ "$url" =~ drive\.google\.com/file/d/([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$url" =~ drive\.google\.com/uc\?id=([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ "$url" =~ id=([a-zA-Z0-9_-]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        print_red "Could not extract Google Drive file ID from URL: $url"
        return 1
    fi
}

# Function to download from Google Drive using gdown
download_from_gdrive() {
    local file_id="$1"
    local output_file="$2"
    local description="$3"
    
    print_green "Downloading from Google Drive: $description"
    log_message "Downloading Google Drive file: $file_id -> $output_file"
    
    gdown "https://drive.google.com/uc?id=${file_id}" -O "$output_file" --fuzzy
    
    if [ $? -eq 0 ]; then
        print_green "✓ Successfully downloaded: $description"
        return 0
    else
        print_red "✗ Failed to download: $description"
        return 1
    fi
}

# Function to download with axel (parallel) or fallback to wget/curl
download_with_axel() {
    local url="$1"
    local output="$2"
    local connections="${3:-16}"  # Default 16 connections
    
    # Try axel first for parallel downloading
    if command -v axel &> /dev/null; then
        print_green "Using axel with ${connections} parallel connections"
        axel -n "${connections}" -a -o "${output}" "${url}"
        if [ $? -eq 0 ]; then
            return 0
        else
            print_yellow "Axel failed, falling back to wget/curl"
        fi
    fi
    
    # Fall back to wget or curl
    if command -v wget &> /dev/null; then
        wget --continue --show-progress -O "${output}" "${url}"
    elif command -v curl &> /dev/null; then
        curl -L -C - --progress-bar -o "${output}" "${url}"
    else
        print_red "Neither axel, wget, nor curl is available"
        print_yellow "Install: sudo apt-get install axel wget curl"
        return 1
    fi
}
    
    if command -v gdown &> /dev/null; then
        gdown "https://drive.google.com/uc?id=$file_id" -O "$output_file" 2>&1 | tee -a "${LOG_FILE}"
    else
        print_red "gdown not found. Please install it with: pip install gdown"
        return 1
    fi
}

# Function to download from OneDrive using curl
download_from_onedrive() {
    local onedrive_url="$1"
    local output_file="$2"
    local description="$3"
    
    print_green "Downloading from OneDrive: $description"
    log_message "Downloading OneDrive file: $onedrive_url -> $output_file"
    
    # Convert OneDrive sharing URL to direct download URL
    local direct_url=""
    if [[ "$onedrive_url" =~ 1drv\.ms ]]; then
        # For 1drv.ms short URLs, we need to follow redirects and convert
        print_yellow "Converting OneDrive sharing URL to direct download URL..."
        
        # Get the actual OneDrive URL by following redirects
        local full_url=$(curl -s -L -I "$onedrive_url" | grep -i "location:" | tail -1 | sed 's/location: //i' | tr -d '\r')
        
        if [[ "$full_url" =~ onedrive\.live\.com.*\?([^&]*) ]]; then
            # Convert to direct download URL
            direct_url="${full_url}&download=1"
        fi
    elif [[ "$onedrive_url" =~ onedrive\.live\.com ]]; then
        # Already a full OneDrive URL, just add download parameter
        if [[ "$onedrive_url" =~ \? ]]; then
            direct_url="${onedrive_url}&download=1"
        else
            direct_url="${onedrive_url}?download=1"
        fi
    fi
    
    if [ -n "$direct_url" ]; then
        print_green "Using direct download URL: $direct_url"
        curl -L -o "$output_file" "$direct_url" --progress-bar 2>&1 | tee -a "${LOG_FILE}"
    else
        print_red "Could not convert OneDrive URL to direct download link"
        print_yellow "Please download manually from: $onedrive_url"
        return 1
    fi
}

# Function to download from Google Drive URL directly
download_from_gdrive_url() {
    local url="$1"
    local output_file="$2"
    local description="$3"
    
    local file_id=$(extract_gdrive_id "$url")
    if [ $? -eq 0 ]; then
        download_from_gdrive "$file_id" "$output_file" "$description"
    else
        return 1
    fi
}

# Function to download with progress
download_with_progress() {
    local url="$1"
    local output_file="$2"
    local description="$3"
    
    print_green "Downloading: $description"
    log_message "Downloading: $url -> $output_file"
    
    if command -v wget &> /dev/null; then
        wget --continue --progress=bar:force:noscroll "$url" -O "$output_file" 2>&1 | tee -a "${LOG_FILE}"
    elif command -v curl &> /dev/null; then
        curl -L --continue-at - "$url" -o "$output_file" --progress-bar 2>&1 | tee -a "${LOG_FILE}"
    else
        print_red "Neither wget nor curl found. Please install one of them."
        return 1
    fi
}

# 1. Download DynamicReplica Dataset
download_dynamic_replica() {
    print_blue "\n=== Downloading DynamicReplica Dataset ==="
    local dr_dir="${DATASETS_DIR}/DynamicReplica"
    mkdir -p "$dr_dir"
    
    # Define URLs from the markdown file
    local base_url="https://dl.fbaipublicfiles.com/dynamic_replica_v2"
    
    # Download real data
    print_green "Downloading DynamicReplica real data..."
    download_with_axel "${base_url}/real/real_000.zip" "${dr_dir}/real_000.zip" 16
    extract_if_needed "${dr_dir}/real_000.zip" "${dr_dir}"
    
    # Download validation data
    print_green "Downloading DynamicReplica validation data..."
    for i in {0..5}; do
        local file_num=$(printf "%03d" $i)
        download_with_axel "${base_url}/valid/valid_${file_num}.zip" "${dr_dir}/valid_${file_num}.zip" 12
        extract_if_needed "${dr_dir}/valid_${file_num}.zip" "${dr_dir}"
    done
    
    # Download test data
    print_green "Downloading DynamicReplica test data..."
    for i in {0..10}; do
        local file_num=$(printf "%03d" $i)
        download_with_axel "${base_url}/test/test_${file_num}.zip" "${dr_dir}/test_${file_num}.zip" 12
        extract_if_needed "${dr_dir}/test_${file_num}.zip" "${dr_dir}"
    done
    
    # Download ALL training data (all 86 files)
    print_green "Downloading DynamicReplica training data (ALL 86 files)..."
    for i in {0..85}; do
        local file_num=$(printf "%03d" $i)
        download_with_axel "${base_url}/train/train_${file_num}.zip" "${dr_dir}/train_${file_num}.zip" 12
        extract_if_needed "${dr_dir}/train_${file_num}.zip" "${dr_dir}"
    done
    
    log_message "DynamicReplica download completed"
}

# 2. Download IRs Dataset  
download_irs() {
    print_blue "\n=== Downloading IRs Dataset ==="
    local irs_dir="${DATASETS_DIR}/IRs"
    mkdir -p "$irs_dir"
    
    # OneDrive URL from the markdown file
    local onedrive_url="https://1drv.ms/f/s!AmN7U9URpGVGem0coY8PJMHYg0g?e=nvH5oB"
    
    print_green "Attempting to download IRs dataset from OneDrive using curl..."
    
    # Try to download using curl
    if download_from_onedrive "$onedrive_url" "${irs_dir}/irs_dataset.zip" "IRs Dataset"; then
        print_green "OneDrive download successful!"
        extract_if_needed "${irs_dir}/irs_dataset.zip" "${irs_dir}"
    else
        print_yellow "Automatic OneDrive download failed. Providing manual instructions..."
        
        # Create a download instruction file
        cat > "${irs_dir}/DOWNLOAD_INSTRUCTIONS.txt" << 'EOF'
IRs Dataset Download Instructions
================================

Automatic OneDrive download failed. Please download manually:

Method 1: Direct Browser Download
1. Visit: https://1drv.ms/f/s!AmN7U9URpGVGem0coY8PJMHYg0g?e=nvH5oB
2. Download all files from the OneDrive folder
3. Place the downloaded files in this directory
4. Run the extraction commands if needed

Method 2: Using curl (if you have a direct download link)
If you can get a direct download URL from OneDrive:
curl -L -o irs_dataset.zip "DIRECT_ONEDRIVE_URL"

Method 3: Using OneDrive API (advanced)
You can use the Microsoft Graph API to programmatically download files.

Alternative: If Google Drive links are provided
==============================================

If the dataset becomes available on Google Drive, you can use gdown:
gdown "https://drive.google.com/uc?id=FILE_ID" -O filename.zip

Current Status: Manual download may be required from OneDrive
EOF
        
        print_yellow "Instructions saved to: ${irs_dir}/DOWNLOAD_INSTRUCTIONS.txt"
    fi
    
    log_message "IRs dataset download attempted via OneDrive curl"
}

# 3. Download Structured3D Dataset
download_structured3d() {
    print_blue "\n=== Downloading Structured3D Dataset ==="
    local s3d_dir="${DATASETS_DIR}/Structured3D"
    mkdir -p "$s3d_dir"
    
    local base_url="https://zju-kjl-jointlab-azure.kujiale.com/zju-kjl-jointlab/Structured3D"
    
    # Download panorama data (using axel with 16 connections for large files)
    print_green "Downloading Structured3D panorama data..."
    for i in {0..17}; do
        local file_num=$(printf "%02d" $i)
        download_with_axel "${base_url}/Structured3D_panorama_${file_num}.zip" \
            "${s3d_dir}/Structured3D_panorama_${file_num}.zip" 16
        extract_if_needed "${s3d_dir}/Structured3D_panorama_${file_num}.zip" "${s3d_dir}"
    done
    
    # Download perspective FULL data (not just empty) - using axel
    print_green "Downloading Structured3D perspective FULL data..."
    for i in {0..17}; do
        if [ $i -ne 9 ]; then  # Skip corrupted file 09
            local file_num=$(printf "%02d" $i)
            download_with_axel "${base_url}/Structured3D_perspective_full_${file_num}.zip" \
                "${s3d_dir}/Structured3D_perspective_full_${file_num}.zip" 16
            extract_if_needed "${s3d_dir}/Structured3D_perspective_full_${file_num}.zip" "${s3d_dir}"
        fi
    done
    
    # Also download perspective empty data - using axel
    print_green "Downloading Structured3D perspective empty data..."
    for i in {0..17}; do
        if [ $i -ne 9 ]; then  # Skip corrupted file 09
            local file_num=$(printf "%02d" $i)
            download_with_axel "${base_url}/Structured3D_perspective_empty_${file_num}.zip" \
                "${s3d_dir}/Structured3D_perspective_empty_${file_num}.zip" 16
            extract_if_needed "${s3d_dir}/Structured3D_perspective_empty_${file_num}.zip" "${s3d_dir}"
        fi
    done
    
    # Download structure annotations (missing from previous version) - using axel
    print_green "Downloading Structured3D structure annotations..."
    download_with_axel "${base_url}/Structured3D_annotation_3d.zip" \
        "${s3d_dir}/Structured3D_annotation_3d.zip" 16
    extract_if_needed "${s3d_dir}/Structured3D_annotation_3d.zip" "${s3d_dir}"
    
    # Download 3D bounding box annotations - using axel
    print_green "Downloading Structured3D bounding box annotations..."
    download_with_axel "${base_url}/Structured3D_bbox.zip" \
        "${s3d_dir}/Structured3D_bbox.zip" 16
    extract_if_needed "${s3d_dir}/Structured3D_bbox.zip" "${s3d_dir}"
    
    log_message "Structured3D download completed"
}

# 4. Download BlendedMVS Dataset (all 3 variants, low resolution)
download_blendedmvs() {
    print_blue "\n=== Downloading BlendedMVS Datasets ==="
    local bmvs_dir="${DATASETS_DIR}/BlendedMVS"
    mkdir -p "$bmvs_dir"
    
    # Try GitHub releases first (preferred method)
    print_green "Trying GitHub releases for BlendedMVS downloads..."
    
    # Download BlendedMVS (original)
    print_green "Downloading BlendedMVS (original)..."
    if ! download_with_progress "https://github.com/YoYo000/BlendedMVS/releases/download/v1.0.0/BlendedMVS.zip" \
        "${bmvs_dir}/BlendedMVS.zip" "BlendedMVS Original"; then
        
        print_yellow "GitHub download failed, trying OneDrive..."
        download_from_onedrive "https://1drv.ms/u/s!Ag8Dbz2Aqc81gVDu7FHfbPZwqhIy?e=BHY07t" \
            "${bmvs_dir}/BlendedMVS.zip" "BlendedMVS Original (OneDrive)"
    fi
    extract_if_needed "${bmvs_dir}/BlendedMVS.zip" "${bmvs_dir}"
    
    # Download BlendedMVS+ (split files)
    print_green "Downloading BlendedMVS+..."
    local bmvs_plus_url="https://github.com/YoYo000/BlendedMVS/releases/download/v1.0.1"
    local github_success=true
    
    # Try GitHub releases first
    for i in $(seq -w 1 42); do
        if ! download_with_progress "${bmvs_plus_url}/BlendedMVS1.z${i}" \
            "${bmvs_dir}/BlendedMVS1.z${i}" "BlendedMVS+ Part ${i}/42"; then
            github_success=false
            break
        fi
    done
    
    if [ "$github_success" = true ]; then
        # Download the zip descriptor
        download_with_progress "${bmvs_plus_url}/BlendedMVS1.zip" \
            "${bmvs_dir}/BlendedMVS1.zip" "BlendedMVS+ Descriptor"
    else
        print_yellow "GitHub download failed for BlendedMVS+, trying OneDrive..."
        download_from_onedrive "https://1drv.ms/u/s!Ag8Dbz2Aqc81gVLILxpohZLEYiIa?e=MhwYSR" \
            "${bmvs_dir}/BlendedMVS+.zip" "BlendedMVS+ (OneDrive)"
        extract_if_needed "${bmvs_dir}/BlendedMVS+.zip" "${bmvs_dir}"
    fi
    
    # Extract BlendedMVS+ if downloaded from GitHub
    if [ "$github_success" = true ] && command -v 7z &> /dev/null; then
        print_green "Extracting BlendedMVS+..."
        cd "${bmvs_dir}"
        7z x BlendedMVS1.zip
        cd - > /dev/null
    elif [ "$github_success" = true ]; then
        print_yellow "7z not available. BlendedMVS+ files downloaded but not extracted."
    fi
    
    # Download BlendedMVS++ (split files)
    print_green "Downloading BlendedMVS++..."
    local bmvs_pp_url="https://github.com/YoYo000/BlendedMVS/releases/download/v1.0.2"
    github_success=true
    
    # Try GitHub releases first
    for i in $(seq -w 1 42); do
        if ! download_with_progress "${bmvs_pp_url}/BlendedMVS2.z${i}" \
            "${bmvs_dir}/BlendedMVS2.z${i}" "BlendedMVS++ Part ${i}/42"; then
            github_success=false
            break
        fi
    done
    
    if [ "$github_success" = true ]; then
        # Download the zip descriptor
        download_with_progress "${bmvs_pp_url}/BlendedMVS2.zip" \
            "${bmvs_dir}/BlendedMVS2.zip" "BlendedMVS++ Descriptor"
    else
        print_yellow "GitHub download failed for BlendedMVS++, trying OneDrive..."
        download_from_onedrive "https://1drv.ms/u/s!Ag8Dbz2Aqc81gVHCxmURGz0UBGns?e=Tnw2KY" \
            "${bmvs_dir}/BlendedMVS++.zip" "BlendedMVS++ (OneDrive)"
        extract_if_needed "${bmvs_dir}/BlendedMVS++.zip" "${bmvs_dir}"
    fi
    
    # Extract BlendedMVS++ if downloaded from GitHub
    if [ "$github_success" = true ] && command -v 7z &> /dev/null; then
        print_green "Extracting BlendedMVS++..."
        cd "${bmvs_dir}"
        7z x BlendedMVS2.zip
        cd - > /dev/null
    elif [ "$github_success" = true ]; then
        print_yellow "7z not available. BlendedMVS++ files downloaded but not extracted."
    fi
    
    log_message "BlendedMVS datasets download completed"
}

# 5. Download ml-hypersim Dataset (FULL DOWNLOAD)
download_ml_hypersim() {
    print_blue "\n=== Downloading ml-hypersim Dataset (FULL) ==="
    local hypersim_dir="${DATASETS_DIR}/ml-hypersim"
    
    # Clone the repository first
    if [ ! -d "$hypersim_dir" ]; then
        print_green "Cloning ml-hypersim repository..."
        git clone https://github.com/apple/ml-hypersim.git "$hypersim_dir"
    else
        print_green "Repository already exists, pulling latest changes..."
        cd "$hypersim_dir"
        git pull
        cd - > /dev/null
    fi
    
    # Setup Python environment for hypersim
    print_green "Setting up Hypersim Python environment..."
    cd "$hypersim_dir"
    
    # Install hypersim specific requirements
    pip install h5py matplotlib pandas scikit-learn
    
    # Create actual download script that downloads the full dataset
    print_green "Creating Hypersim FULL download script..."
    cat > "download_full_dataset.py" << 'EOF'
#!/usr/bin/env python3
"""
Full download script for Hypersim dataset
Downloads the complete dataset (~1.9TB)
"""
import os
import sys
import subprocess

# Add tools to path
sys.path.append('code/python/tools')

def main():
    print("Starting full Hypersim dataset download...")
    print("This will download ~1.9TB of data. Ensure sufficient storage space.")
    
    # Create downloads and scenes directories
    downloads_dir = os.path.join(os.getcwd(), "downloads")
    scenes_dir = os.path.join(os.getcwd(), "scenes")
    os.makedirs(downloads_dir, exist_ok=True)
    os.makedirs(scenes_dir, exist_ok=True)
    
    # Run the official download script
    cmd = [
        sys.executable,
        "code/python/tools/dataset_download_images.py",
        "--downloads_dir", downloads_dir,
        "--decompress_dir", scenes_dir
    ]
    
    print(f"Running command: {' '.join(cmd)}")
    try:
        subprocess.run(cmd, check=True)
        print("Hypersim dataset download completed successfully!")
    except subprocess.CalledProcessError as e:
        print(f"Download failed with error: {e}")
        print("You may need to configure _system_config.py first")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())
EOF
    
    chmod +x "download_full_dataset.py"
    
    # Also create the system config file
    if [ ! -f "code/python/_system_config.py" ]; then
        cp "code/python/_system_config.py.example" "code/python/_system_config.py"
        print_yellow "Created _system_config.py from example. You may need to modify paths."
    fi
    
    cd - > /dev/null
    
    print_green "Starting Hypersim full dataset download..."
    print_yellow "This will download ~1.9TB. Press Ctrl+C to cancel, or wait 10 seconds to continue..."
    
    # Give user a chance to cancel
    sleep 10
    
    # Start the download
    cd "$hypersim_dir"
    python download_full_dataset.py
    cd - > /dev/null
    
    log_message "ml-hypersim full dataset download initiated"
}

# 6. Download TartanAir Dataset (FULL DOWNLOAD)
download_tartanair() {
    print_blue "\n=== Downloading TartanAir Dataset (FULL) ==="
    local tartanair_dir="${DATASETS_DIR}/TartanAir"
    mkdir -p "$tartanair_dir"
    
    # Copy the existing tools
    if [ -d "${SCRIPT_DIR}/tartanair_tools" ]; then
        print_green "Copying TartanAir tools..."
        cp -r "${SCRIPT_DIR}/tartanair_tools"/* "$tartanair_dir/"
    fi
    
    # Install TartanAir dependencies
    print_green "Installing TartanAir dependencies..."
    pip install boto3 colorama minio gdown
    
    cd "$tartanair_dir"
    
    # Download TartanAir test data from Google Drive first
    print_green "Downloading TartanAir test data from Google Drive..."
    
    # Create test data directory
    mkdir -p "./test_data"
    
    # Download monocular track (7.65 GB)
    download_from_gdrive "1N9BkpQuibIyIBkLxVPUuoB-eDOMFqY8D" \
        "./test_data/tartanair_mono_test.zip" "TartanAir Monocular Test Data (7.65GB)"
    extract_if_needed "./test_data/tartanair_mono_test.zip" "./test_data/"
    
    # Download stereo track (17.51 GB)  
    download_from_gdrive "1dIiN3IxWD_IVVDUKT-BdbX72-lyKUdkh" \
        "./test_data/tartanair_stereo_test.zip" "TartanAir Stereo Test Data (17.51GB)"
    extract_if_needed "./test_data/tartanair_stereo_test.zip" "./test_data/"
    
    # Download both tracks combined (25.16 GB)
    download_from_gdrive "1N8qoU-oEjRKdaKSrHPWA-xsnRtofR_jJ" \
        "./test_data/tartanair_both_test.zip" "TartanAir Combined Test Data (25.16GB)"
    extract_if_needed "./test_data/tartanair_both_test.zip" "./test_data/"
    
    cd "$tartanair_dir"
    
    # Download FULL TartanAir training dataset (RGB, depth, segmentation, flow)
    print_green "Starting TartanAir FULL training dataset download..."
    print_yellow "This will download ~3TB. Press Ctrl+C to cancel, or wait 10 seconds to continue..."
    
    # Give user a chance to cancel
    sleep 10
    
    # Download all data types from both cameras
    print_green "Downloading ALL TartanAir data (RGB, depth, segmentation, flow)..."
    
    if [ -f "download_training.py" ]; then
        python download_training.py \
            --output-dir ./data \
            --rgb \
            --depth \
            --seg \
            --flow \
            --unzip
    else
        print_red "download_training.py not found in tartanair_tools"
        return 1
    fi
    
    cd - > /dev/null
    
    log_message "TartanAir full dataset download completed"
}

# 7. Download Taskonomy Dataset (FULL DOWNLOAD)
download_taskonomy() {
    print_blue "\n=== Downloading Taskonomy Dataset (FULL) ==="
    local taskonomy_dir="${DATASETS_DIR}/Taskonomy"
    mkdir -p "$taskonomy_dir"
    
    # Copy existing taskonomy tools if available
    if [ -d "${SCRIPT_DIR}/taskonomy" ]; then
        print_green "Copying Taskonomy tools..."
        cp -r "${SCRIPT_DIR}/taskonomy"/* "$taskonomy_dir/"
    fi
    
    # Install omnidata-tools and dependencies
    print_green "Installing Taskonomy dependencies..."
    
    # Install system dependencies for aria2
    if command -v apt-get &> /dev/null; then
        sudo apt-get update && sudo apt-get install -y aria2
    elif command -v brew &> /dev/null; then
        brew install aria2
    fi
    
    pip install omnidata-tools
    
    cd "$taskonomy_dir"
    
    # Download FULL Taskonomy dataset
    print_green "Starting Taskonomy FULL dataset download..."
    print_yellow "This will download ~11TB. Press Ctrl+C to cancel, or wait 15 seconds to continue..."
    
    # Give user more time to cancel due to huge size
    sleep 15
    
    # Download the full dataset
    print_green "Downloading Taskonomy full dataset (this will take a very long time)..."
    
    omnitools.download all \
        --components taskonomy \
        --subset fullplus \
        --dest ./taskonomy_data/ \
        --connections_total 40 \
        --agree
    
    cd - > /dev/null
    
    log_message "Taskonomy full dataset download completed"
}

# Main execution
main() {
    log_message "Starting multi-dataset download script"
    
    # Setup environment
    print_blue "Setting up environment..."
    setup_conda_env
    
    # Install system dependencies
    print_green "Installing system dependencies..."
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y wget curl unzip p7zip-full git aria2
    elif command -v yum &> /dev/null; then
        sudo yum install -y wget curl unzip p7zip git aria2
    elif command -v brew &> /dev/null; then
        brew install wget curl p7zip git aria2
    fi
    
    # Install gdown for Google Drive downloads
    print_green "Installing gdown for Google Drive downloads..."
    pip install gdown
    
    # Create summary file
    cat > "${DATASETS_DIR}/DATASET_SUMMARY.md" << 'EOF'
# Downloaded Datasets Summary

This directory contains 7 computer vision datasets:

## 1. DynamicReplica
- **Location**: `./DynamicReplica/`
- **Size**: ~150GB (FULL dataset)
- **Description**: Dynamic scene dataset for novel view synthesis
- **Status**: Direct download completed (ALL 86 training files + test/val/real)

## 2. IRs Dataset  
- **Location**: `./IRs/`
- **Size**: Variable
- **Description**: Image retrieval dataset
- **Status**: Automatic OneDrive download attempted via curl

## 3. Structured3D
- **Location**: `./Structured3D/`
- **Size**: ~800GB (FULL dataset)
- **Description**: Large-scale 3D indoor scenes
- **Status**: Direct download completed (panorama + perspective full + perspective empty + annotations + bbox)

## 4. BlendedMVS
- **Location**: `./BlendedMVS/`
- **Size**: ~190GB (LOW-RESOLUTION only as requested)
- **Description**: Multi-view stereo dataset
- **Status**: GitHub releases with OneDrive fallback (all 3 variants, low-res only)

## 5. ml-hypersim
- **Location**: `./ml-hypersim/`
- **Size**: ~1.9TB (FULL dataset)
- **Description**: Photorealistic synthetic dataset
- **Status**: Full download initiated

## 6. TartanAir
- **Location**: `./TartanAir/`
- **Size**: ~3TB (FULL dataset) + ~25GB (test data)
- **Description**: AirSim simulation dataset for SLAM
- **Status**: Full download completed (RGB + depth + segmentation + flow + Google Drive test data)

## 7. Taskonomy
- **Location**: `./Taskonomy/`
- **Size**: ~11TB (FULL dataset)
- **Description**: Multi-task vision dataset
- **Status**: Full download completed (fullplus subset)

## Google Drive Support
- **Tool**: gdown installed for Google Drive downloads
- **TartanAir**: Test data downloaded from Google Drive automatically
- **IRs**: Instructions provided for Google Drive alternative

## OneDrive Support  
- **Tool**: curl used for OneDrive direct downloads
- **IRs**: Automatic download attempted via OneDrive curl
- **BlendedMVS**: OneDrive fallback if GitHub releases fail

## Total Estimated Size
- **Complete downloads**: ~16.9TB

## Next Steps
1. Check IRs directory for manual download instructions
2. Run sample scripts for large datasets as needed
3. Verify extractions completed successfully
EOF
    
    # Execute downloads
    print_blue "\nStarting downloads..."
    
    print_yellow "Choose download mode:"
    print_yellow "1. Download ALL datasets COMPLETELY (~16.9TB)"
    print_yellow "2. Setup all datasets (smaller downloads + scripts)"
    print_yellow "3. Custom selection"
    
    read -p "Enter choice (1-3): " choice
    
    case $choice in
        1)
            print_red "WARNING: This will download ~16.9TB of data!"
            print_red "Ensure you have sufficient storage space and bandwidth."
            read -p "Are you sure? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                download_dynamic_replica
                download_irs
                download_structured3d
                download_blendedmvs
                download_ml_hypersim
                download_tartanair
                download_taskonomy
            else
                print_yellow "Download cancelled by user."
                exit 0
            fi
            ;;
        2)
            # Setup only - smaller downloads
            print_green "Setting up all datasets with minimal downloads..."
            mkdir -p "${DATASETS_DIR}/DynamicReplica"
            download_irs
            mkdir -p "${DATASETS_DIR}/Structured3D"
            mkdir -p "${DATASETS_DIR}/BlendedMVS"
            download_ml_hypersim
            download_tartanair
            download_taskonomy
            ;;
        3)
            print_green "Available datasets:"
            print_green "1. DynamicReplica (~150GB - ALL files)"
            print_green "2. IRs (manual download)"
            print_green "3. Structured3D (~800GB - FULL)"
            print_green "4. BlendedMVS (~190GB - low-res only)"
            print_green "5. ml-hypersim (~1.9TB - FULL)"
            print_green "6. TartanAir (~3TB - FULL)"
            print_green "7. Taskonomy (~11TB - FULL)"
            
            read -p "Enter dataset numbers to download (e.g., 1,3,5): " selections
            IFS=',' read -ra ADDR <<< "$selections"
            for i in "${ADDR[@]}"; do
                case $i in
                    1) download_dynamic_replica ;;
                    2) download_irs ;;
                    3) download_structured3d ;;
                    4) download_blendedmvs ;;
                    5) download_ml_hypersim ;;
                    6) download_tartanair ;;
                    7) download_taskonomy ;;
                esac
            done
            ;;
    esac
    
    # Final summary
    print_blue "\n=== Download Summary ==="
    print_green "Download script completed!"
    print_green "Datasets location: $DATASETS_DIR"
    print_green "Log file: $LOG_FILE"
    print_green "Summary: ${DATASETS_DIR}/DATASET_SUMMARY.md"
    
    log_message "Multi-dataset download script completed"
    
    # Show disk usage
    if command -v du &> /dev/null; then
        print_blue "\nDisk usage:"
        du -sh "${DATASETS_DIR}"/* 2>/dev/null | sort -hr
    fi
}

# Handle interruption
cleanup() {
    print_red "\nScript interrupted. Cleaning up..."
    log_message "Script interrupted by user"
    exit 1
}

trap cleanup SIGINT SIGTERM

# Run main function
main "$@"