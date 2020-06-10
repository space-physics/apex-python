# apex-python


clean Python interface to Apex without f2py--compute millions of points per second on laptop.

Initially we are benchmarking and verifying accuracy before deciding on Python UI.

For now:

```sh
cmake -B build
cmake --build build
```

then benchmark by:

```sh
./build/apex_benchmark 40. 25. 2020.
```

coordinate conversion (geographic to geomag) ~ 100 ns per point on modest laptop with Gfortran or Intel oneAPI.
