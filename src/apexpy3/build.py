"""
A generic, clean way to build C/C++/Fortran code "build on run"

Michael Hirsch, Ph.D.
https://www.scivision.dev
"""
import shutil
from pathlib import Path
import subprocess
import os
import pkg_resources

R = Path(__file__).resolve().parent
SRCDIR = R
BINDIR = SRCDIR / "build"


def build(src_dir: Path = SRCDIR, bin_dir: Path = BINDIR):
    """
    attempts build with CMake
    """
    if not check_cmake_version("3.13"):
        raise ValueError("Need at least CMake 3.13")
    cmake_setup(src_dir, bin_dir)


def cmake_setup(src_dir: Path, bin_dir: Path):
    """
    attempt to build using CMake >= 3
    """
    cmake_exe = shutil.which("cmake")
    if not cmake_exe:
        raise FileNotFoundError("CMake not available")

    cfgfn = bin_dir / "CMakeCache.txt"
    if cfgfn.is_file():
        cfgfn.unlink()

    wopts = []
    if os.name == "nt" and not os.getenv("CMAKE_GENERATOR"):
        if shutil.which("ninja"):
            wopts = ["-G", "Ninja"]
        else:
            wopts = ["-G", "MinGW Makefiles"]

    subprocess.run([cmake_exe, "-S", str(src_dir), "-B", str(bin_dir)] + wopts)

    subprocess.run([cmake_exe, "--build", str(bin_dir), "--parallel"])


def check_cmake_version(min_version: str) -> bool:
    cmake = shutil.which("cmake")
    if not cmake:
        return False

    cmake_version = subprocess.check_output([cmake, "--version"], universal_newlines=True).split()[
        2
    ]

    pmin = pkg_resources.parse_version(min_version)
    pcmake = pkg_resources.parse_version(cmake_version)

    return pcmake >= pmin
