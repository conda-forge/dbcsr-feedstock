#!/usr/bin/env bash

set -xe

# In cross-compilation mode, CMake's FindMPI cannot run test executables
# to detect MPI. Provide explicit hints to bypass the need for runtime detection.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
    CMAKE_ARGS="${CMAKE_ARGS} -DMPI_HOME=$PREFIX"
fi

cmake -S . -B build \
    -DCMAKE_C_COMPILER=${CC} \
    -DCMAKE_CXX_COMPILER=${CXX} \
    -DCMAKE_Fortran_COMPILER=${FC} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DBUILD_TESTING=OFF \
    -DWITH_EXAMPLES=OFF \
    ${CMAKE_ARGS}

cmake --build build --target install -j"${CPU_COUNT}" -v