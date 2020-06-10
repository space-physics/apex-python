# apex-python


clean Python interface to Apex without f2py--compute millions of points per second on laptop.


## setup

```sh
cmake -B build
cmake --build build

pip install -e .
```

## Usage

```python
import apexpy3

dat = apexpy3.gc2gm()

### Benchmark

Just to show raw Fortran speed

```sh
./build/apex_benchmark 40. 25. 2020.
```

coordinate conversion (geographic to geomag) ~ 100 ns per point on modest laptop with Gfortran or Intel oneAPI.
