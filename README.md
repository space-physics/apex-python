# apex-python

![Actions Status](https://github.com/space-physics/apex-python/workflows/ci/badge.svg)
[![Language grade: Python](https://img.shields.io/lgtm/grade/python/g/space-physics/apex-python.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/space-physics/apex-python/context:python)

clean Python interface to Apex without f2py--compute millions of points per second on laptop.


## setup

```sh
cmake -B build
cmake --build build

pip install -e .
```

## Ninja

for Windows users and in general for best performance we suggest using the ninja back end.
To use ninja, replace the directions above with:

```sh
pip install ninja

cmake -B build -G Ninja

cmake --build build
```

to make this change permanent, which we suggest in general for best performance,
set environment variable `CMAKE_GENERATOR=Ninja`


## Usage

Typically, users would input Numpy ndarray of arbitrary dimension and shape.
There is a fixed setup time for Apex of 5-10 seconds, but then it only takes about 100 ns per point.
Thus it behooves the user to feed in a large array of points once, rather than call repeatedly.

```python
import apexpy3

dat = apexpy3.geo2mag(yeardec=2018.5, glat=40, glon=-105)

print(dat)
```

> {'gmlat': array([47.7939873]), 'gmlon': array([-37.5895653])}

### Benchmark

Just to show raw Fortran speed

```sh
./build/apex_benchmark 40. 25. 2020.
```

coordinate conversion (geographic to geomag) ~ 100 ns per point on modest laptop with Gfortran or Intel oneAPI.
