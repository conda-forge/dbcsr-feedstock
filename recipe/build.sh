#!/usr/bin/env bash

set -euxo pipefail

# In cross-compilation mode, CMake's FindMPI cannot run test executables
# to detect MPI. Provide explicit hints to bypass the need for runtime detection.
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" == "1" ]]; then
  CMAKE_ARGS="${CMAKE_ARGS} -DMPI_HOME=${PREFIX}"
fi

cmake -B build -S . \
  ${CMAKE_ARGS} \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=ON \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DUSE_MPI=ON \
  -DUSE_MPI_F08=ON \
  -DWITH_EXAMPLES=OFF

cmake --build build --target install -j"${CPU_COUNT}" -v

# Run the upstream unit tests (not possible when cross-compiling)
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  export OMPI_ALLOW_RUN_AS_ROOT=1 OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1
  export OMPI_MCA_plm_ssh_agent=false OMPI_MCA_btl_sm_single_copy_mechanism=none
  export PRTE_MCA_rmaps_default_mapping_policy=:oversubscribe
  export HYDRA_LAUNCHER=fork
  if [[ "${target_platform}" == osx-* ]]; then
    # Avoid shared-memory transport issues of Open MPI on macOS CI runners
    export OMPI_MCA_btl=self,tcp
  fi
  ctest --test-dir build --output-on-failure
fi
