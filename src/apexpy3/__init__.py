import subprocess
import numpy as np
import shutil
import logging
from pathlib import Path
import tempfile
import re
import typing as T

R = Path(__file__).resolve().parents[2] / "build"
if not R.is_dir():
    raise ImportError(f"build directory {R} not found, did you build Apex with CMake?")


def mag2geo(yeardec: float, gmlat: np.ndarray, gmlon: np.ndarray) -> T.Dict[str, T.Any]:
    fortexe = shutil.which("mag2geo", path=str(R))
    if not fortexe:
        raise ImportError(f"mag2geo executable not found in {R}, did you build Apex with CMake?")

    gmlat = np.atleast_1d(gmlat)
    gmlon = np.atleast_1d(gmlon)

    orig_shape = gmlat.shape

    nml = tempfile.NamedTemporaryFile(mode="w", suffix=".nml", delete=False)
    f = nml.file  # type: ignore

    f.write(
        f"""
&input_shape
N = {gmlat.size}
/\n
"""
    )

    f.write(
        """
&input
gmlat = """
    )
    f.write(",".join(gmlat.ravel().astype(str).tolist()) + "\n")

    f.write("gmlon = ")
    f.write(",".join(gmlon.ravel().astype(str).tolist()) + "\n")

    f.write("/\n")
    nml.close()  # avoids Permission Error in Fortran

    cmd = [fortexe, f"{yeardec:.3f}", nml.name]
    logging.info(" ".join(cmd))
    ret = subprocess.run(cmd)
    if ret.returncode != 0:
        raise RuntimeError("Apex error")

    dat = read_namelist(nml.name, "output")

    try:
        Path(nml.name).unlink()
    except PermissionError:
        pass

    for k, v in dat.items():
        dat[k] = v.reshape(orig_shape)

    return dat


def geo2mag(yeardec: float, glat: np.ndarray, glon: np.ndarray) -> T.Dict[str, T.Any]:
    fort_geo2mag = shutil.which("geo2mag", path=str(R))
    if not fort_geo2mag:
        raise ImportError(f"geo2mag executable not found in {R}, did you build Apex with CMake?")

    glat = np.atleast_1d(glat)
    glon = np.atleast_1d(glon)

    orig_shape = glat.shape

    nml = tempfile.NamedTemporaryFile(mode="w", suffix=".nml", delete=False)
    f = nml.file  # type: ignore

    f.write(
        f"""
&input_shape
N = {glat.size}
/\n
"""
    )

    f.write(
        """
&input
glat = """
    )
    f.write(",".join(glat.ravel().astype(str).tolist()) + "\n")

    f.write("glon = ")
    f.write(",".join(glon.ravel().astype(str).tolist()) + "\n")

    f.write("/\n")
    nml.close()  # avoids Permission Error in Fortran

    cmd = [fort_geo2mag, f"{yeardec:.3f}", nml.name]
    logging.info(" ".join(cmd))
    ret = subprocess.run(cmd)
    if ret.returncode != 0:
        raise RuntimeError("Apex error")

    dat = read_namelist(nml.name, "output")

    try:
        Path(nml.name).unlink()
    except PermissionError:
        pass

    for k, v in dat.items():
        dat[k] = v.reshape(orig_shape)

    return dat


def read_namelist(fn: T.Union[str, Path], namelist: str) -> T.Dict[str, T.Any]:
    """ read a namelist from an .nml file """

    fn = Path(fn).expanduser()
    raw: T.Dict[str, T.Sequence[str]] = {}
    nml_pat = re.compile(r"^\s*&(" + namelist + r")", re.IGNORECASE)
    end_pat = re.compile(r"^\s*/\s*$")
    val_pat = re.compile(r"^\s*(\w+)\s*=\s*['\"]?([^!'\"]*)['\"]?")

    with fn.open("r") as f:
        for line in f:
            if not nml_pat.match(line):
                continue

            for line in f:
                line = line.strip()
                if not line or line.startswith("!"):
                    continue

                if end_pat.match(line):
                    # end of namelist
                    return raw

                val_mat = val_pat.match(line)
                if val_mat:
                    # a new variable
                    key, vals = val_mat.group(1), val_mat.group(2).split(",")
                    key = key.lower()
                    if len(vals) == 1:
                        # scalar variable
                        raw[key] = vals[0]
                        continue
                    # array
                    try:
                        raw[key] = np.array([float(v) for v in vals if v])
                    except ValueError:
                        raw[key] = vals  # string data
                    continue

                try:
                    raw[key] = np.append(raw[key], [float(v) for v in line.split(",") if v])
                except ValueError:
                    pass

    raise KeyError(f"did not find Namelist {namelist} in {fn}")


# check if a continuation of array
