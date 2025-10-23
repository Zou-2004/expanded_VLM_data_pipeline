# Habitat 2.0 Dataset Addition Summary

## What Was Added

I've successfully integrated **Habitat 2.0** datasets into your VGGT datasets download script.

### Habitat 2.0 Overview

Habitat 2.0 (from https://github.com/facebookresearch/habitat-lab) is Facebook Research's platform for training embodied AI agents. It includes:

1. **Scene Datasets** - 3D environments for simulation
2. **Task/Episode Datasets** - Pre-defined navigation and manipulation tasks

### What the Script Downloads

The script automatically downloads the following Habitat 2.0 components:

#### Scene Datasets (via habitat-sim utility):
- ✅ **Habitat test scenes** (89 MB) - Testing scenes
- ✅ **ReplicaCAD** (123 MB) - Interactive indoor scenes for manipulation
- ✅ **YCB objects** - Object manipulation dataset
- ✅ **MP3D example scene** - Sample from Matterport3D

#### Task/Episode Datasets (direct downloads):
- ✅ **Rearrange Pick** (11 MB) - Pick task episodes for ReplicaCAD
- ✅ **PointNav Gibson v1** (385 MB) - Point-goal navigation
- ✅ **PointNav MP3D v1** (400 MB) - Point-goal navigation
- ✅ **ObjectNav MP3D v1** (170 MB) - Object-goal navigation
- ✅ **ImageNav** (reuses PointNav datasets)

#### Optional (Requires Authentication):
- ⚠️ **HM3D** (~130GB) - Requires Matterport credentials
- ⚠️ **HSSD** - Requires Hugging Face credentials

### Total Size
- **Basic download:** ~1-1.5 GB (without HM3D/HSSD)
- **With HM3D:** ~130+ GB
- **Full setup:** 1+ TB (if downloading all optional datasets)

## How to Use

### Download Habitat 2.0 Only
```bash
./download_vggt_datasets.sh
# Select option: 16
```

### Download All Datasets Including Habitat 2.0
```bash
./download_vggt_datasets.sh
# Select option: 1
```

### Download HM3D (Optional - Requires Credentials)
1. Get access at: https://matterport.com/habitat-matterport-3d-research-dataset
2. Generate API token at: https://my.matterport.com/settings/account/devtools
3. Run:
```bash
conda activate vggt_download
python -m habitat_sim.utils.datasets_download \
    --username <api-token-id> \
    --password <api-token-secret> \
    --uids hm3d_minival_v0.2 \
    --data-path vggt_datasets/habitat2/
```

### Download HSSD (Optional - Requires Credentials)
1. Register at: https://huggingface.co/datasets/hssd/hssd-hab
2. Get token at: https://huggingface.co/settings/tokens
3. Run:
```bash
conda activate vggt_download
python -m habitat_sim.utils.datasets_download \
    --username <hf-username> \
    --password <hf-token> \
    --uids hssd-hab \
    --data-path vggt_datasets/habitat2/
```

## Dataset Structure

After download, the Habitat 2.0 data will be organized as:

```
vggt_datasets/habitat2/
├── scene_datasets/           # 3D Scene datasets
│   ├── habitat-test-scenes/  # Test scenes
│   │   ├── apartment_0.glb
│   │   ├── apartment_1.glb
│   │   └── skokloster-castle.glb
│   ├── replica_cad/          # ReplicaCAD scenes
│   │   └── configs/scenes/
│   ├── mp3d/                 # Matterport3D example
│   │   └── 17DRP5sb8fy/
│   └── objects/              # Object models
│       └── ycb/              # YCB object set
└── datasets/                 # Task/Episode datasets
    ├── rearrange_pick/       # Rearrangement tasks
    │   └── replica_cad/v0/
    ├── pointnav/             # Point navigation
    │   ├── gibson/v1/
    │   └── mp3d/v1/
    ├── objectnav/            # Object navigation
    │   └── mp3d/v1/
    └── imagenav/             # Image navigation
        └── (uses pointnav data)
```

## Using the Data

### With Habitat-Lab

```python
import gym
import habitat.gym

# Example 1: Load a rearrangement task
env = gym.make("HabitatRenderPick-v0")
observations = env.reset()

# Example 2: Load point navigation
import habitat
config = habitat.get_config(
    "benchmark/nav/pointnav/pointnav_habitat_test.yaml"
)
config.defrost()
config.SIMULATOR.SCENE = "vggt_datasets/habitat2/scene_datasets/habitat-test-scenes/apartment_0.glb"
config.freeze()
env = habitat.gym.make_gym_from_config(config)
```

### Available Tasks

1. **PointNav** - Navigate to coordinates
2. **ObjectNav** - Navigate to object categories
3. **ImageNav** - Navigate to image-specified locations
4. **Rearrange Pick** - Pick and place manipulation

## File Changes

### Modified Files:
1. **`download_vggt_datasets.sh`**
   - Added `download_habitat2()` function (lines ~450-550)
   - Updated menu to include option 16
   - Updated `download_all()` to include Habitat 2.0
   - Updated case statements to handle option 16

2. **`VGGT_README.md`**
   - Added Habitat 2.0 to dataset overview table
   - Added detailed Habitat 2.0 section with authentication instructions
   - Updated total size estimate (6.5 TB → 7.5+ TB)
   - Added Habitat 2.0 to download order recommendations
   - Added directory structure for Habitat 2.0 data

## Dependencies

The script automatically installs:
- `habitat-sim` (via conda)

These are installed when you select the Habitat 2.0 download option.

## Benefits of Habitat 2.0

1. **Standardized Format** - Easy integration with embodied AI research
2. **Multiple Tasks** - Navigation, manipulation, rearrangement
3. **Realistic Simulations** - Physics-based interactions
4. **Episode Datasets** - Pre-defined evaluation benchmarks
5. **Active Community** - Well-maintained by Facebook AI Research
6. **Multi-modal Sensing** - RGB, depth, semantic segmentation

## References

- **Habitat-Lab Repository:** https://github.com/facebookresearch/habitat-lab
- **Habitat-Sim Repository:** https://github.com/facebookresearch/habitat-sim
- **Documentation:** https://aihabitat.org/docs/habitat-lab/
- **Paper (Habitat 2.0):** https://arxiv.org/abs/2106.14405
- **Paper (Habitat 3.0):** https://arxiv.org/abs/2310.13724

## Notes

- The basic Habitat 2.0 download (~1.5GB) works out-of-the-box without authentication
- HM3D and HSSD are optional and require separate authentication
- The script provides clear instructions for downloading authenticated datasets
- All data follows Habitat's standard directory structure for easy use

---

**Created:** January 15, 2025  
**Script Version:** v1.1 (with Habitat 2.0 support)
