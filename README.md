# Torch Packages Compiler Repository

This repository serves as a comprehensive toolset for building and indexing PyTorch-based packages with custom ops. It includes two primary GitHub workflows:

1. **PyTorch Packages Builder Workflow:**
   - Automates the building of PyTorch-based packages with custom ops on common architectures.
   - Uses build attestation to establish provenance for wheels\*.
   - Publishes the built packages on GitHub releases.

2. **PEP 503 Compliant Package Index Builder Workflow:**
   - Creates a PEP 503 compliant package index.
   - Publishes the index using GitHub Pages for seamless integration with pip.

\*Keep in mind that releases can be reuploaded anytime.

## Usage with Pip

### Using the Entire Package Index

To utilize the complete package index from this repository, add the following to your `pip install` command:

```bash
pip install --extra-index-url https://miropsota.github.io/torch_packages_builder <your package list>
```

### Using Specific Package Links

If you only need links for specific packages, add the following to your `pip install` command:

```bash
pip install --find-links https://miropsota.github.io/torch_packages_builder/<pep 503 normalized name> <your package list>
```

For example:

```bash
pip install --find-links https://miropsota.github.io/torch_packages_builder/detectron2/ <your package list>
```

### Local Installation

You can also download a package and install it locally:

```bash
pip install <abs or rel path>
pip install --find-links <abs or rel dir path> <rel path of the package with respect to the directory>
```

Make sure to include the full version, including the local version identifier (part after `+`). The repository follows this version template:

```bash
<package_name>-<version>+<OPTIONAL_commit_hash>pt<PyTorch_version><compute_platform>
```

Where `<compute_platform>` is, as in PyTorch, one of `cpu`, `cu<CUDA_version>`, `rocm<ROCM_version>`.

### Example Package Install Lines

```bash
detectron2==0.6+864913fpt2.5.0cpu
pytorch3d==0.7.6+pt2.9.0cu130
```

## Supported combinations

Tested with PyTorch `2.3.0` - `2.11.0` and their respective compute platforms and supported OSes, with an exception for the `rocm` platform.

## Non-torch packages

The build workflow also handles packages that don't depend on PyTorch (native
pybind11 bindings, etc.). Leave `torch-version` blank when dispatching **Build
Wheels** — this skips the CUDA/PyTorch install steps and emits a matrix of
`(OS × python_version)` over Python 3.10–3.13 only. The resulting wheel goes
through `auditwheel repair` on Linux (`manylinux_2_28_x86_64`) and
`delvewheel repair` on Windows, so the bundled native `.so`/`.dll` ships
inside the wheel.

Version string is `<pkg>-<ver>+<hash>` (no `pt…` tail). Example:

```bash
pip install --extra-index-url https://jianglongye.github.io/torch_packages_builder \
    xrobotoolkit_sdk==1.0.2+abcdefg
```

Per-package native-lib staging (clone, build, copy headers + .so/.dll) is
handled in `package_specific.sh`.

### Manus SDK runtime wheel

`packages/manus_sdk_runtime` builds the `manus-sdk-runtime` wheel used by
RetargetingKit's `manus` extra. Dispatch **Build Wheels** with:

```text
repo: jianglongye/torch_packages_builder
repo-subdir: packages/manus_sdk_runtime
torch-version: <blank>
limit-python: 3.10
linux-wheels: true
windows-wheels: true
macos-wheels: false
```

The build downloads native assets from the `manus-sdk-native` release by
default. Repository secrets `MANUS_SDK_LINUX_URL` and `MANUS_SDK_WINDOWS_URL`
can override those URLs.

## Pitfalls

- **No Support for Pip Cache:**
  `pip` relies on http cache, and GitHub generates on-the-fly redirections for release links, so they are probably not playing nicely together.

## Credits

A huge thanks to <https://github.com/rusty1s/pytorch_cluster>
