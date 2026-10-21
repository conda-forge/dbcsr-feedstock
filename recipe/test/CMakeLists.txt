cmake_minimum_required(VERSION 3.22)
project(dbcsr_test LANGUAGES Fortran C CXX)

find_package(MPI REQUIRED COMPONENTS Fortran C CXX)
find_package(OpenMP REQUIRED COMPONENTS Fortran)
find_package(DBCSR CONFIG REQUIRED)

set(EXAMPLES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/examples")

# The examples are free-form Fortran despite the .F suffix
set(CMAKE_Fortran_FORMAT FREE)
if (CMAKE_Fortran_COMPILER_ID STREQUAL "GNU")
  add_compile_options($<$<COMPILE_LANGUAGE:Fortran>:-ffree-line-length-none>)
endif ()

# Fortran API
foreach (name dbcsr_example_1 dbcsr_example_2 dbcsr_example_3)
  add_executable(${name} ${EXAMPLES_DIR}/${name}.F)
  target_link_libraries(${name} DBCSR::dbcsr OpenMP::OpenMP_Fortran)
endforeach ()

# C API
add_executable(dbcsr_example_3_cpp ${EXAMPLES_DIR}/dbcsr_example_3.cpp)
target_link_libraries(dbcsr_example_3_cpp DBCSR::dbcsr_c MPI::MPI_CXX
                      OpenMP::OpenMP_Fortran)
set_target_properties(dbcsr_example_3_cpp PROPERTIES LINKER_LANGUAGE Fortran)
target_compile_features(dbcsr_example_3_cpp PRIVATE cxx_std_14)
