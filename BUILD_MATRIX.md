# Build Matrix

Build dispatch recipes for each package. Python versions within each torch
release are determined by `get_jobs.py`; the tables below show the effective
combinations after filtering.

### Example dispatch

```bash
gh workflow run build_wheels.yml -f repo="NVlabs/curobo" -f repo-tag="v0.7.8" \
  -f torch-version="2.5.1,2.6.0,2.7.1,2.8.0" \
  -f limit-python="3.9,3.10,3.11,3.12,3.13" \
  -f limit-compute-platform="cu118,cu126,cu128" \
  -f linux-wheels=true -f windows-wheels=false -f macos-wheels=false
```

---

## nvdiffrast 0.3.3

**Repo:** `NVlabs/nvdiffrast` | **Tag:** `v0.3.3` | **OS:** Linux

| Torch  | CUDA                | Python                       |
| ------ | ------------------- | ---------------------------- |
| 2.3.1  | cu118               | 3.8, 3.9, 3.10, 3.11, 3.12   |
| 2.4.1  | cu118               | 3.8, 3.9, 3.10, 3.11, 3.12   |
| 2.5.1  | cu118               | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.6.0  | cu118, cu126        | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.7.1  | cu118, cu126, cu128 | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.8.0  | cu126, cu128        | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.9.1  | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |
| 2.10.0 | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |
| 2.11.0 | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |

---

## nvidia-curobo 0.7.8

**Repo:** `NVlabs/curobo` | **Tag:** `v0.7.8` | **OS:** Linux

| Torch  | CUDA                | Python                       |
| ------ | ------------------- | ---------------------------- |
| 2.3.1  | cu118               | 3.8, 3.9, 3.10, 3.11, 3.12   |
| 2.4.1  | cu118               | 3.8, 3.9, 3.10, 3.11, 3.12   |
| 2.5.1  | cu118               | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.6.0  | cu118, cu126        | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.7.1  | cu118, cu126, cu128 | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.8.0  | cu126, cu128        | 3.9, 3.10, 3.11, 3.12, 3.13  |
| 2.9.1  | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |
| 2.10.0 | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |
| 2.11.0 | cu126, cu128        | 3.10, 3.11, 3.12, 3.13, 3.14 |
