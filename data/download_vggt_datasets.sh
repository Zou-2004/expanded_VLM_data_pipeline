#!/bin/bash

################################################################################
# VGGT Datasets Download Script
# Downloads all datasets used in the VGGT paper
# Supports: Hugging Face, Google Drive, Google Cloud Storage, Facebook CDN, 
#           Direct downloads, and GitHub repositories
################################################################################

set -e  # Exit on error

# Color output functions
print_info() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
print_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
print_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }
print_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }

# Get script directory (works even if script is sourced)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATASETS_DIR="${SCRIPT_DIR}/vggt_datasets"
LOG_FILE="${SCRIPT_DIR}/vggt_download.log"

# Create datasets directory
mkdir -p "${DATASETS_DIR}"

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${LOG_FILE}"
}

################################################################################
# Setup Python Environment
################################################################################
setup_python_env() {
    print_info "Setting up Python environment..."
    
    # Check if conda is available
    if ! command -v conda &> /dev/null; then
        print_error "Conda not found. Please install Anaconda or Miniconda first."
        exit 1
    fi
    
    # Create or activate environment
    if conda env list | grep -q "vggt_download"; then
        print_info "Environment 'vggt_download' already exists. Activating..."
        eval "$(conda shell.bash hook)"
        conda activate vggt_download
    else
        print_info "Creating new conda environment 'vggt_download'..."
        conda create -n vggt_download python=3.9 -y
        eval "$(conda shell.bash hook)"
        conda activate vggt_download
    fi
    
    # Install required Python packages
    print_info "Installing required Python packages..."
    pip install -q --upgrade pip
    pip install -q gdown huggingface_hub[cli] tqdm requests
    
    # Install Google Cloud SDK if not present (for gsutil)
    if ! command -v gsutil &> /dev/null; then
        print_warning "gsutil not found. Installing Google Cloud SDK..."
        pip install -q google-cloud-storage
    fi
    
    print_success "Python environment setup complete"
}

################################################################################
# Download Utilities
################################################################################

# Download with progress bar
download_with_progress() {
    local url="$1"
    local output="$2"
    
    if command -v wget &> /dev/null; then
        wget --continue --show-progress -O "${output}" "${url}"
    elif command -v curl &> /dev/null; then
        curl -L -C - --progress-bar -o "${output}" "${url}"
    else
        print_error "Neither wget nor curl is available"
        return 1
    fi
}

# Download from Google Drive
download_from_gdrive() {
    local file_id="$1"
    local output="$2"
    
    print_info "Downloading from Google Drive: ${file_id}"
    gdown "${file_id}" -O "${output}" --fuzzy
}

# Download from Hugging Face
download_from_huggingface() {
    local repo="$1"
    local local_dir="$2"
    local file_pattern="${3:-*}"  # Optional file pattern
    
    print_info "Downloading from Hugging Face: ${repo}"
    huggingface-cli download "${repo}" \
        --repo-type dataset \
        --local-dir "${local_dir}" \
        --local-dir-use-symlinks False \
        ${file_pattern:+--include "$file_pattern"}
}

# Extract if needed
extract_if_needed() {
    local file="$1"
    local dest_dir="$2"
    
    if [[ ! -f "${file}" ]]; then
        print_warning "File not found: ${file}"
        return 1
    fi
    
    print_info "Extracting: $(basename ${file})"
    
    case "${file}" in
        *.tar.gz|*.tgz)
            tar -xzf "${file}" -C "${dest_dir}"
            ;;
        *.tar)
            tar -xf "${file}" -C "${dest_dir}"
            ;;
        *.zip)
            unzip -q "${file}" -d "${dest_dir}"
            ;;
        *.7z)
            7z x "${file}" -o"${dest_dir}"
            ;;
        *)
            print_warning "Unknown archive format: ${file}"
            return 1
            ;;
    esac
    
    print_success "Extraction complete"
}

################################################################################
# Dataset Download Functions
################################################################################

# 1. Aria Digital Twin
download_aria_digital_twin() {
    print_info "========== Downloading Aria Digital Twin =========="
    local OUTPUT_DIR="${DATASETS_DIR}/aria_digital_twin"
    mkdir -p "${OUTPUT_DIR}"
    
    download_from_huggingface "projectaria/aria-digital-twin" "${OUTPUT_DIR}"
    
    print_success "Aria Digital Twin download complete"
    log_message "Aria Digital Twin downloaded to ${OUTPUT_DIR}"
}

# 2. Aria Synthetic Environments
download_aria_synthetic() {
    print_info "========== Downloading Aria Synthetic Environments =========="
    local OUTPUT_DIR="${DATASETS_DIR}/aria_synthetic_environments"
    mkdir -p "${OUTPUT_DIR}"
    
    download_from_huggingface "projectaria/aria-synthetic-environments" "${OUTPUT_DIR}"
    
    print_success "Aria Synthetic Environments download complete"
    log_message "Aria Synthetic Environments downloaded to ${OUTPUT_DIR}"
}

# 3. DL3DV (Both 480P and 960P versions)
download_dl3dv() {
    print_info "========== Downloading DL3DV =========="
    local OUTPUT_DIR="${DATASETS_DIR}/dl3dv"
    mkdir -p "${OUTPUT_DIR}"
    
    print_info "Downloading DL3DV-ALL-480P..."
    download_from_huggingface "DL3DV/DL3DV-ALL-480P" "${OUTPUT_DIR}/480P"
    
    print_info "Downloading DL3DV-ALL-960P..."
    download_from_huggingface "DL3DV/DL3DV-ALL-960P" "${OUTPUT_DIR}/960P"
    
    print_success "DL3DV download complete"
    log_message "DL3DV downloaded to ${OUTPUT_DIR}"
}

# 4. Kubric (Google Cloud Storage)
download_kubric() {
    print_info "========== Downloading Kubric =========="
    local OUTPUT_DIR="${DATASETS_DIR}/kubric"
    mkdir -p "${OUTPUT_DIR}"
    
    print_warning "Kubric dataset is hosted on Google Cloud Storage (kubric-public bucket)"
    print_warning "This requires Google Cloud SDK with proper authentication."
    print_info "Attempting to download sample data..."
    
    # Check if gsutil is available
    if command -v gsutil &> /dev/null; then
        print_info "Using gsutil to download from gs://kubric-public/..."
        gsutil -m cp -r gs://kubric-public/tfds "${OUTPUT_DIR}/" || {
            print_warning "Failed to download with gsutil. You may need to authenticate:"
            print_warning "Run: gcloud auth login"
            print_warning "Or download manually from: https://console.cloud.google.com/storage/browser/kubric-public"
        }
    else
        print_error "gsutil not found. Please install Google Cloud SDK:"
        print_error "Visit: https://cloud.google.com/sdk/docs/install"
        print_error "Or manually download from: https://console.cloud.google.com/storage/browser/kubric-public"
        return 1
    fi
    
    print_success "Kubric download attempted (check logs for errors)"
    log_message "Kubric download attempted at ${OUTPUT_DIR}"
}

# 5. Mapillary
download_mapillary() {
    print_info "========== Downloading Mapillary =========="
    local OUTPUT_DIR="${DATASETS_DIR}/mapillary"
    mkdir -p "${OUTPUT_DIR}"
    
    cd "${OUTPUT_DIR}"
    
    # Download MD5 checksum file
    print_info "Downloading MD5 checksum..."
    download_with_progress \
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An8zNzC23cON9AK2LyVFjVRuEiAaqbhbMnLAzpqPRB-K2l7LPWYDdiqwmJPLO5vWLqYDxA8FRkONTJQz5ZgBNfVB_3ssjhHY6Hg6zEZPkZ1t09Q.txt?ccb=10-5&oh=00_AYAmgr6-UpFuaYI-O3i8x7p8G-BqMWTFV2cSkVGWZ_bujg&oe=679E6BDF&_nc_sid=6a2159" \
        "mapillary_public_mly_vistas.txt"
    
    # Download all 8 zip files
    local urls=(
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An-KVy5k8Uwo5Uq8u0B9m1NB-7dg3J6ZK5Z8y10wILT-L1meBVZkNUP0H2dPxM_08kRKZJc4Q7CX0Ft7jLpAH26Ahy0.zip?ccb=10-5&oh=00_AYDrLSznzp-mGfR0XL-39VTjZJlZ-w95jV9ZsYbSs3Jv8g&oe=679E4CF3&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An8y5xTqjZ2x6Bf_fOVPK0-R1hOsPAUdG96lJ7Qr5KT6qpxLxSL_XC-YC4W3kxBCYS9vxnK5VeWqIXgaUv1kA9qfgOY.zip?ccb=10-5&oh=00_AYCn3_RApbBGjI4mD5rIg2G4bwGgb6k2TJzrvMf0Yr9qCg&oe=679E5AD7&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An_JWnlFRVTrFTdHGIDLsUfTMy03Ik86E4Sle3Rx26V1OjGWaPApZEXkKxDxBOXUE1q8pOdSvQzlvZcTPGM1wWgUlWU.zip?ccb=10-5&oh=00_AYBVGMN9sMTU5VPWwwqIh7FTfCWB2vJ1x7DzTzmrcFPBFA&oe=679E4EC2&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An8R33rSL0lh7-IZwTjpEMPkqjLZH7P8PmJH1gPc2hqJ4oC-UiUTYEaYaQWwq6uZ9eWV4Xtf5MG5YVWfJgSkrWFAm2w.zip?ccb=10-5&oh=00_AYCm-6pWOqO9t2S4EPZRU-I1kTyaKe5-vVq9LgzQEH7eFw&oe=679E4EC8&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An97U22_a7LuS1GJI2rJuD2k92fCzg_7vOMU55y1tjovVe-OmKljr1L8AoaqN-Q56f1hnD-K6jYBXEKG87EqE5N3v-o.zip?ccb=10-5&oh=00_AYBdpqzrqHbVZGM6vOj_YV4jUDmIJ3iqNV8lp0OcCMPUpQ&oe=679E3833&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An_Bw_L2_C-ZhvvxpfmfCu1qkZpO9l4IjJ-U-OBsqgAo2mCAJ0t_QOEeqw5JrXdXq90TAbmKc3r7c8yOOsCkafr_WX0.zip?ccb=10-5&oh=00_AYBh1svb3UZE8bGhG6R9R5b5rpJ9BCJ_-VmFpxG1lXiAFQ&oe=679E5638&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An-QZX_1hjqYfSbzp3j7oCNuElwLO6-SgJIZmDSRZPvKFOTlpSGpGxwEhfU8RLfCZV5UH2fvzB1dUQRxGrHLhPxmQwE.zip?ccb=10-5&oh=00_AYASmP-5xKHaJGGy_IcYiY6XfTH3XDZBIiD2dU1Ll4Wq0A&oe=679E472A&_nc_sid=6a2159"
        "https://scontent-lga3-2.xx.fbcdn.net/m1/v/t6/An-GKDg7NW8ck6jv5oZXxmEfTGgRz_rBl2rP83HsJ8iJQO0vhZmk3yF0jjOW5Th2nxb4I7Nge3zMJI6e8M62k2n4yiw.zip?ccb=10-5&oh=00_AYCvFwJfNtfcC0s0dM2-q9W3T1m5G8KVPUkkC29gQRXfQg&oe=679E52D4&_nc_sid=6a2159"
    )
    
    local file_num=1
    for url in "${urls[@]}"; do
        print_info "Downloading part ${file_num}/8..."
        download_with_progress "${url}" "mapillary_vistas_part${file_num}.zip"
        ((file_num++))
    done
    
    # Extract all parts
    print_info "Extracting all parts..."
    for zipfile in mapillary_vistas_part*.zip; do
        extract_if_needed "${zipfile}" "${OUTPUT_DIR}"
    done
    
    cd "${SCRIPT_DIR}"
    
    print_success "Mapillary download complete"
    log_message "Mapillary downloaded to ${OUTPUT_DIR}"
}

# 6. MegaDepth
download_megadepth() {
    print_info "========== Downloading MegaDepth =========="
    local OUTPUT_DIR="${DATASETS_DIR}/megadepth"
    mkdir -p "${OUTPUT_DIR}"
    
    cd "${OUTPUT_DIR}"
    
    print_info "Downloading MegaDepth v1..."
    download_with_progress \
        "https://www.cs.cornell.edu/projects/megadepth/dataset/Megadepth_v1/MegaDepth_v1.tar.gz" \
        "MegaDepth_v1.tar.gz"
    
    print_info "Extracting MegaDepth..."
    extract_if_needed "MegaDepth_v1.tar.gz" "${OUTPUT_DIR}"
    
    cd "${SCRIPT_DIR}"
    
    print_success "MegaDepth download complete"
    log_message "MegaDepth downloaded to ${OUTPUT_DIR}"
}

# 7. Point Odyssey
download_point_odyssey() {
    print_info "========== Downloading Point Odyssey =========="
    local OUTPUT_DIR="${DATASETS_DIR}/point_odyssey"
    mkdir -p "${OUTPUT_DIR}"
    
    cd "${OUTPUT_DIR}"
    
    print_info "Downloading from Google Drive folder..."
    # Google Drive folder ID: 1W6wxsbKbTdtV8-2TwToqa_QgLqRY3ft0
    download_from_gdrive "1W6wxsbKbTdtV8-2TwToqa_QgLqRY3ft0" "${OUTPUT_DIR}"
    
    cd "${SCRIPT_DIR}"
    
    print_success "Point Odyssey download complete"
    log_message "Point Odyssey downloaded to ${OUTPUT_DIR}"
}

# 8. Virtual KITTI
download_virtual_kitti() {
    print_info "========== Downloading Virtual KITTI =========="
    local OUTPUT_DIR="${DATASETS_DIR}/virtual_kitti"
    mkdir -p "${OUTPUT_DIR}"
    
    cd "${OUTPUT_DIR}"
    
    print_info "Downloading Virtual KITTI 2.0..."
    download_with_progress \
        "https://www-vrl.cs.rwth-aachen.de/download/vkitti3d_dataset_v2.0.zip" \
        "vkitti3d_dataset_v2.0.zip"
    
    print_info "Extracting Virtual KITTI..."
    extract_if_needed "vkitti3d_dataset_v2.0.zip" "${OUTPUT_DIR}"
    
    cd "${SCRIPT_DIR}"
    
    print_success "Virtual KITTI download complete"
    log_message "Virtual KITTI downloaded to ${OUTPUT_DIR}"
}

# 9. MVS-Synth
download_mvs_synth() {
    print_info "========== Downloading MVS-Synth =========="
    local OUTPUT_DIR="${DATASETS_DIR}/mvs_synth"
    mkdir -p "${OUTPUT_DIR}"
    
    cd "${OUTPUT_DIR}"
    
    print_info "Downloading MVS-Synth GTAV_540 from Hugging Face..."
    # Download specific file from Hugging Face repo
    wget --continue "https://huggingface.co/phuang17/MVS-Synth/resolve/main/GTAV_540.tar.gz"
    
    print_info "Extracting MVS-Synth..."
    extract_if_needed "GTAV_540.tar.gz" "${OUTPUT_DIR}"
    
    cd "${SCRIPT_DIR}"
    
    print_success "MVS-Synth download complete"
    log_message "MVS-Synth downloaded to ${OUTPUT_DIR}"
}

# 10. CO3D
download_co3d() {
    print_info "========== Downloading CO3D =========="
    local OUTPUT_DIR="${DATASETS_DIR}/co3d"
    mkdir -p "${OUTPUT_DIR}"
    
    # Clone the CO3D repository which contains the download script
    if [[ ! -d "${OUTPUT_DIR}/co3d_repo" ]]; then
        print_info "Cloning CO3D repository..."
        git clone https://github.com/facebookresearch/co3d.git "${OUTPUT_DIR}/co3d_repo"
    else
        print_info "CO3D repository already exists"
    fi
    
    cd "${OUTPUT_DIR}/co3d_repo"
    
    print_warning "CO3D dataset is very large (5.5 TB)"
    print_info "Using CO3D's official download script..."
    
    # Install CO3D requirements
    if [[ -f "requirements.txt" ]]; then
        pip install -q -r requirements.txt
    fi
    
    # Run the download script (downloads to OUTPUT_DIR/co3d_data)
    mkdir -p "${OUTPUT_DIR}/co3d_data"
    python ./co3d/download_dataset.py --download_folder "${OUTPUT_DIR}/co3d_data"
    
    cd "${SCRIPT_DIR}"
    
    print_success "CO3D download complete"
    log_message "CO3D downloaded to ${OUTPUT_DIR}"
}

# 11. Replica Dataset
download_replica() {
    print_info "========== Downloading Replica Dataset =========="
    local OUTPUT_DIR="${DATASETS_DIR}/replica"
    mkdir -p "${OUTPUT_DIR}"
    
    # Clone or use existing Replica repository
    local REPO_DIR="${SCRIPT_DIR}/Dataset_from_VGGT/Replica-Dataset"
    
    if [[ ! -d "${REPO_DIR}" ]]; then
        print_info "Cloning Replica Dataset repository..."
        git clone https://github.com/facebookresearch/Replica-Dataset.git "${REPO_DIR}"
    fi
    
    cd "${REPO_DIR}"
    
    print_info "Running Replica download script..."
    bash download.sh "${OUTPUT_DIR}/replica_data"
    
    cd "${SCRIPT_DIR}"
    
    print_success "Replica Dataset download complete"
    log_message "Replica Dataset downloaded to ${OUTPUT_DIR}"
}

# 12. WildRGBD
download_wildrgbd() {
    print_info "========== Downloading WildRGBD =========="
    local OUTPUT_DIR="${DATASETS_DIR}/wildrgbd"
    mkdir -p "${OUTPUT_DIR}"
    
    # Use existing WildRGBD repository
    local REPO_DIR="${SCRIPT_DIR}/Dataset_from_VGGT/wildrgbd"
    
    if [[ ! -d "${REPO_DIR}" ]]; then
        print_info "Cloning WildRGBD repository..."
        git clone https://github.com/wildrgbd/wildrgbd.git "${REPO_DIR}"
    fi
    
    cd "${OUTPUT_DIR}"
    
    print_info "Running WildRGBD download script for all categories..."
    python "${REPO_DIR}/download.py" --cat all
    
    cd "${SCRIPT_DIR}"
    
    print_success "WildRGBD download complete"
    log_message "WildRGBD downloaded to ${OUTPUT_DIR}"
}

# 13. Habitat 2.0 Datasets (Scene + Task Datasets)
download_habitat2() {
    print_info "========== Downloading Habitat 2.0 Datasets =========="
    local OUTPUT_DIR="${DATASETS_DIR}/habitat2"
    mkdir -p "${OUTPUT_DIR}"
    
    # Install habitat-sim if not already installed
    if ! python -c "import habitat_sim" &> /dev/null; then
        print_info "Installing habitat-sim..."
        conda install -y -c conda-forge -c aihabitat habitat-sim
    fi
    
    cd "${OUTPUT_DIR}"
    
    print_info "Downloading Habitat test scenes..."
    python -m habitat_sim.utils.datasets_download --uids habitat_test_scenes --data-path "${OUTPUT_DIR}"
    
    print_info "Downloading Habitat test PointNav dataset..."
    python -m habitat_sim.utils.datasets_download --uids habitat_test_pointnav_dataset --data-path "${OUTPUT_DIR}"
    
    print_info "Downloading ReplicaCAD dataset..."
    python -m habitat_sim.utils.datasets_download --uids ReplicaCAD --data-path "${OUTPUT_DIR}"
    
    print_info "Downloading YCB object dataset..."
    python -m habitat_sim.utils.datasets_download --uids ycb --data-path "${OUTPUT_DIR}"
    
    print_info "Downloading MP3D example scene..."
    python -m habitat_sim.utils.datasets_download --uids mp3d_example_scene --data-path "${OUTPUT_DIR}"
    
    print_warning "Downloading HM3D dataset requires Matterport credentials..."
    print_info "To download HM3D, you need to:"
    print_info "1. Get access at: https://matterport.com/habitat-matterport-3d-research-dataset"
    print_info "2. Generate API token at: https://my.matterport.com/settings/account/devtools"
    print_info "3. Run: python -m habitat_sim.utils.datasets_download --username <api-token-id> --password <api-token-secret> --uids hm3d_minival_v0.2 --data-path ${OUTPUT_DIR}"
    
    print_warning "Downloading HSSD dataset requires Hugging Face credentials..."
    print_info "To download HSSD, you need to:"
    print_info "1. Register at: https://huggingface.co/datasets/hssd/hssd-hab"
    print_info "2. Run: python -m habitat_sim.utils.datasets_download --username <hf-username> --password <hf-password> --uids hssd-hab --data-path ${OUTPUT_DIR}"
    
    # Download task datasets (episode datasets)
    print_info "Downloading Habitat-Lab task datasets..."
    
    # Rearrange Pick task
    print_info "Downloading Rearrange Pick dataset..."
    download_with_progress \
        "https://dl.fbaipublicfiles.com/habitat/data/datasets/rearrange_pick/replica_cad/v0/rearrange_pick_replica_cad_v0.zip" \
        "rearrange_pick_replica_cad_v0.zip"
    extract_if_needed "rearrange_pick_replica_cad_v0.zip" "${OUTPUT_DIR}"
    
    # PointNav Gibson
    print_info "Downloading PointNav Gibson v1 dataset..."
    download_with_progress \
        "https://dl.fbaipublicfiles.com/habitat/data/datasets/pointnav/gibson/v1/pointnav_gibson_v1.zip" \
        "pointnav_gibson_v1.zip"
    extract_if_needed "pointnav_gibson_v1.zip" "${OUTPUT_DIR}"
    
    # PointNav MP3D
    print_info "Downloading PointNav MP3D v1 dataset..."
    download_with_progress \
        "http://dl.fbaipublicfiles.com/habitat/data/datasets/pointnav/mp3d/v1/pointnav_mp3d_v1.zip" \
        "pointnav_mp3d_v1.zip"
    extract_if_needed "pointnav_mp3d_v1.zip" "${OUTPUT_DIR}"
    
    # ObjectNav MP3D
    print_info "Downloading ObjectNav MP3D v1 dataset..."
    download_with_progress \
        "https://dl.fbaipublicfiles.com/habitat/data/datasets/objectnav/m3d/v1/objectnav_mp3d_v1.zip" \
        "objectnav_mp3d_v1.zip"
    extract_if_needed "objectnav_mp3d_v1.zip" "${OUTPUT_DIR}"
    
    # ImageNav Gibson
    print_info "Downloading ImageNav Gibson dataset (reuses PointNav)..."
    # Note: ImageNav uses the same pointnav_gibson_v1.zip already downloaded
    
    cd "${SCRIPT_DIR}"
    
    print_success "Habitat 2.0 datasets download complete"
    print_info "Note: HM3D and HSSD require separate authentication - see instructions above"
    log_message "Habitat 2.0 datasets downloaded to ${OUTPUT_DIR}"
}

################################################################################
# Main Execution
################################################################################

show_menu() {
    echo ""
    echo "============================================================"
    echo "       VGGT Datasets Download Script"
    echo "============================================================"
    echo "Select download option:"
    echo ""
    echo "  1) Download ALL datasets (~7+ TB)"
    echo "  2) Setup environment only"
    echo "  3) Select specific datasets"
    echo "  0) Exit"
    echo ""
    echo "Individual datasets:"
    echo "  4)  Aria Digital Twin"
    echo "  5)  Aria Synthetic Environments"
    echo "  6)  DL3DV (480P + 960P)"
    echo "  7)  Kubric"
    echo "  8)  Mapillary"
    echo "  9)  MegaDepth"
    echo "  10) Point Odyssey"
    echo "  11) Virtual KITTI"
    echo "  12) MVS-Synth"
    echo "  13) CO3D (5.5 TB)"
    echo "  14) Replica Dataset"
    echo "  15) WildRGBD"
    echo "  16) Habitat 2.0 (Scene + Task Datasets)"
    echo ""
    echo "============================================================"
    read -p "Enter your choice [0-16]: " choice
    echo ""
}

download_all() {
    print_info "Starting download of ALL VGGT datasets..."
    print_warning "This will download approximately 7+ TB of data"
    print_warning "Make sure you have sufficient disk space!"
    
    read -p "Continue? (y/n): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        print_info "Download cancelled"
        return
    fi
    
    download_aria_digital_twin
    download_aria_synthetic
    download_dl3dv
    download_kubric
    download_mapillary
    download_megadepth
    download_point_odyssey
    download_virtual_kitti
    download_mvs_synth
    download_co3d
    download_replica
    download_wildrgbd
    download_habitat2
    
    print_success "All VGGT datasets downloaded successfully!"
}

# Main script logic
main() {
    print_info "VGGT Datasets Download Script"
    print_info "Data will be saved to: ${DATASETS_DIR}"
    
    # Setup environment first
    setup_python_env
    
    # Show menu
    show_menu
    
    case $choice in
        0)
            print_info "Exiting..."
            exit 0
            ;;
        1)
            download_all
            ;;
        2)
            print_success "Environment setup complete"
            ;;
        3)
            print_info "Select datasets to download (space-separated numbers 4-16):"
            read -p "Enter dataset numbers: " -a selections
            for num in "${selections[@]}"; do
                case $num in
                    4) download_aria_digital_twin ;;
                    5) download_aria_synthetic ;;
                    6) download_dl3dv ;;
                    7) download_kubric ;;
                    8) download_mapillary ;;
                    9) download_megadepth ;;
                    10) download_point_odyssey ;;
                    11) download_virtual_kitti ;;
                    12) download_mvs_synth ;;
                    13) download_co3d ;;
                    14) download_replica ;;
                    15) download_wildrgbd ;;
                    16) download_habitat2 ;;
                    *) print_warning "Invalid selection: $num" ;;
                esac
            done
            ;;
        4) download_aria_digital_twin ;;
        5) download_aria_synthetic ;;
        6) download_dl3dv ;;
        7) download_kubric ;;
        8) download_mapillary ;;
        9) download_megadepth ;;
        10) download_point_odyssey ;;
        11) download_virtual_kitti ;;
        12) download_mvs_synth ;;
        13) download_co3d ;;
        14) download_replica ;;
        15) download_wildrgbd ;;
        16) download_habitat2 ;;
        *)
            print_error "Invalid choice"
            exit 1
            ;;
    esac
    
    print_success "Script execution completed"
    log_message "Script execution completed"
}

# Run main function
main
