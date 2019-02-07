cmake_minimum_required (VERSION 2.8)
project (CustomCheckerPlugin CXX)

include (CMakeSourceLists.txt)

#===------------------------------------------------------------------------===#
# Obtain LLVM include paths, binaries, etc. with llvm-config.
#===------------------------------------------------------------------------===#

if (NOT LLVM_CONFIG_DIR)
  execute_process (
    COMMAND which llvm-config
    OUTPUT_VARIABLE LLVM_CONFIG_BIN
    RESULT_VARIABLE LLVM_ERR)
  get_filename_component(LLVM_CONFIG_DIR ${LLVM_CONFIG_BIN} DIRECTORY)

  if (LLVM_ERR)
    message(FATAL_ERROR "llvm-config not found in the PATH!")
  endif()
endif()

message(STATUS "LLVM config dir: ${LLVM_CONFIG_DIR}")

# use llvm-config to get the Clang and LLVM include dirs
if (NOT LLVM_CONFIG_DIR)
  execute_process (
    COMMAND llvm-config --src-root
    OUTPUT_VARIABLE LLVM_SRC_ROOT)
else()
  execute_process (
    COMMAND ${LLVM_CONFIG_DIR}/llvm-config --src-root
    OUTPUT_VARIABLE LLVM_SRC_ROOT)
endif()
STRING(REGEX REPLACE "(\r?\n)+$" "" LLVM_SRC_ROOT "${LLVM_SRC_ROOT}")

message(STATUS "LLVM src root: ${LLVM_SRC_ROOT}")

# ... and the object dir
if (NOT LLVM_CONFIG_DIR)
  execute_process (
    COMMAND llvm-config --obj-root
    OUTPUT_VARIABLE LLVM_OBJ_ROOT)
else()
  execute_process (
    COMMAND ${LLVM_CONFIG_DIR}/llvm-config --obj-root
    OUTPUT_VARIABLE LLVM_OBJ_ROOT)
endif()
STRING(REGEX REPLACE "(\r?\n)+$" "" LLVM_OBJ_ROOT "${LLVM_OBJ_ROOT}")
message(STATUS "LLVM obj root: ${LLVM_OBJ_ROOT}")

if (NOT LLVM_LIB_DIR)
  if (NOT LLVM_CONFIG_DIR)
    execute_process (
      COMMAND llvm-config --libdir
      OUTPUT_VARIABLE LLVM_LIB_DIR)
  else()
    execute_process (
      COMMAND ${LLVM_CONFIG_DIR}/llvm-config --libdir
      OUTPUT_VARIABLE LLVM_LIB_DIR)
  endif()
  STRING(REGEX REPLACE "(\r?\n)+$" "" LLVM_LIB_DIR "${LLVM_LIB_DIR}")
endif ()
message(STATUS "LLVM lib dir: ${LLVM_LIB_DIR}")

if (NOT LLVM_INCLUDE_DIR)
  if (NOT LLVM_CONFIG_DIR)
    execute_process (
      COMMAND llvm-config --includedir
      OUTPUT_VARIABLE LLVM_INCLUDE_DIR)
  else()
    execute_process (
      COMMAND ${LLVM_CONFIG_DIR}/llvm-config --includedir
      OUTPUT_VARIABLE LLVM_INCLUDE_DIR)
  endif()
endif ()
message(STATUS "LLVM include dir: ${LLVM_INCLUDE_DIR}")

if (NOT CLANG_INCLUDE_DIR)
  # = `llvm-config --src-root`/tools/clang/include
  set (CLANG_INCLUDE_DIR "${LLVM_SRC_ROOT}/tools/clang/include")
endif ()
message(STATUS "Clang include dir: ${CLANG_INCLUDE_DIR}")

if (NOT CLANG_GENERATED_INCLUDE_DIR)
  set (CLANG_GENERATED_INCLUDE_DIR "${LLVM_OBJ_ROOT}/tools/clang/include")
endif ()
message(STATUS "Clang generated include dir: ${CLANG_GENERATED_INCLUDE_DIR}")

if (NOT LLVM_CXX_FLAGS)
  # use llvm-config to get all flags we need to co-operate with LLVM and Clang
  if (NOT LLVM_CONFIG_DIR)
    execute_process (
      COMMAND llvm-config --cxxflags
      OUTPUT_VARIABLE LLVM_CXX_FLAGS)
  else()
    execute_process (
      COMMAND ${LLVM_CONFIG_DIR}/llvm-config --cxxflags
      OUTPUT_VARIABLE LLVM_CXX_FLAGS)
  endif()
  STRING(REGEX REPLACE "(\r?\n)+$" "" LLVM_CXX_FLAGS "${LLVM_CXX_FLAGS}")
endif ()
message(STATUS "LLVM CXX flags: ${LLVM_CXX_FLAGS}")

#===------------------------------------------------------------------------===#
# Set up how the compiler will be invoked when compiling this plugin.
#===------------------------------------------------------------------------===#

set (CUSTOM_CXX_FLAGS
  "${LLVM_CXX_FLAGS} -fno-rtti -Wall -Wextra -Wno-strict-aliasing \
  -Wno-unused-parameter -Wno-unknown-warning-option -pedantic -fPIC \
  -Wno-unused-local-typedefs"
)
message(STATUS "Plugin build flags: ${CUSTOM_CXX_FLAGS}")

set (CUSTOM_LD_FLAGS "")

# since these symbols will be available when Clang loads the plugin, we don't
# need to link with them here, but we have to suppress the linker's error
# reporting we only have to link against the libs that Clang itself doesn't load
# e.g. since we're calling Clang with --analyze, and the Static Analyzer does
# not use libASTMatchers, that means we have to load that ourself
set (LIBS
  clangTooling
  clangFrontend
  clangASTMatchers
  clangIndex)

include_directories(
  "${LLVM_INCLUDE_DIR}"
  "${CLANG_INCLUDE_DIR}"
  "${CLANG_GENERATED_INCLUDE_DIR}"
)

link_directories("${LLVM_LIB_DIR}")

set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${CUSTOM_CXX_FLAGS}")
set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${CUSTOM_LD_FLAGS}")
set (CMAKE_SHARED_LINKER_FLAGS
  "${CMAKE_SHARED_LINKER_FLAGS} ${CUSTOM_LD_FLAGS}"
)

set(PLUGIN_NAME "custom-checker-plugin")

add_library(${PLUGIN_NAME} SHARED ${SOURCES})

set_property(TARGET ${PLUGIN_NAME} PROPERTY CXX_STANDARD 14)

target_link_libraries(${PLUGIN_NAME} ${LIBS})
