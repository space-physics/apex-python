#!/usr/bin/env python
import pytest
import apexpy3


def test_gc2gm():
    dat = apexpy3.geo2mag(2018.5, 40, -105)

    assert dat["gmlat"] == pytest.approx(47.79, abs=0.01)
    assert dat["gmlon"] == pytest.approx(-37.59, abs=0.01)


def test_gm2gc():
    dat = apexpy3.mag2geo(2018.5, 47.79, -37.59)

    assert dat["glat"] == pytest.approx(40.0, abs=0.01)
    assert dat["glon"] == pytest.approx(-105.0, abs=0.01)


if __name__ == "__main__":
    pytest.main([__file__])
