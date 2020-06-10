#!/usr/bin/env python
"""
demo converting millions of points / second with Apex
"""
import numpy as np
import argparse
import typing as T

import apexpy3

try:
    from matplotlib.pyplot import figure, show
except ImportError:
    figure = show = None


def main():
    p = argparse.ArgumentParser()
    p.add_argument("yeardec", help="decimal year e.g. 2020.352", type=float)
    P = p.parse_args()

    # demoing a grid
    glat = np.arange(-90, 90, 1)
    glon = np.arange(0, 360, 2)

    glat, glon = np.meshgrid(glat, glon)

    dat = apexpy3.geo2mag(P.yeardec, glat, glon)
    dat.update({"glat": glat, "glon": glon, "date": P.yeardec})

    if show is None:
        return

    mag_contour(dat)


def mag_contour(dat: T.Dict[str, np.ndarray]):

    print("Converted", dat["gmlat"].shape, "points")

    fg = figure()
    ax = fg.subplots(1, 2, sharey=True)
    fg.suptitle("WMM2020  {}".format(dat["date"]))
    h = ax[0].contour(dat["glon"], dat["glat"], dat["gmlat"], range(-90, 90 + 20, 20))
    ax[0].clabel(h, inline=True, fmt="%0.1f")
    ax[0].set_title("Magnetic latitude [degrees]")

    h = ax[1].contour(dat["glon"], dat["glat"], dat["gmlon"], range(-90, 90 + 20, 20))
    ax[1].clabel(h, inline=True, fmt="%0.1f")
    ax[1].set_title("Magnetic longitude [degrees]")

    ax[0].set_ylabel("Geographic latitude (deg)")
    for a in ax:
        a.set_xlabel("Geographic longitude (deg)")

    show()


if __name__ == "__main__":
    main()
