cmake_minimum_required(VERSION 3.12)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Debug or Release" FORCE)
endif()
project(ApexPy LANGUAGES Fortran)
enable_testing()

add_library(apex OBJECT src/apex.f90)

add_executable(apex_benchmark src/geo2mag.f90)
target_link_libraries(apex_benchmark apex)
