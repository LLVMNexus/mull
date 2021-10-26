if (MULL_STATIC_BUILD)
set(PATH_TO_LLVM "" CACHE PATH "Path to installed LLVM or LLVM source tree")

if (PRECOMPILED_LLVM_DIR)
  message(WARNING "PRECOMPILED_LLVM_DIR is deprecated. Please, use PATH_TO_LLVM instead")
  set(PATH_TO_LLVM ${PRECOMPILED_LLVM_DIR})
endif()

if (SOURCE_LLVM_DIR)
  message(WARNING "SOURCE_LLVM_DIR is deprecated. Please, use PATH_TO_LLVM instead")
  set(PATH_TO_LLVM ${SOURCE_LLVM_DIR})
endif()

if (NOT PATH_TO_LLVM)
  message(FATAL_ERROR " 
  The cmake is supposed to be called with PATH_TO_LLVM pointing to
 a precompiled version of LLVM or to to the source code of LLVM
 Examples:
 cmake -G \"${CMAKE_GENERATOR}\" -DPATH_TO_LLVM=/opt/llvm-3.9.0 ${CMAKE_SOURCE_DIR}
 cmake -G \"${CMAKE_GENERATOR}\" -DPATH_TO_LLVM=/opt/llvm/source ${CMAKE_SOURCE_DIR}
")
endif()

if (NOT IS_ABSOLUTE ${PATH_TO_LLVM})
  # Convert relative path to absolute path
  get_filename_component(PATH_TO_LLVM
    "${PATH_TO_LLVM}" REALPATH BASE_DIR "${CMAKE_BINARY_DIR}")
endif()

set (BUILD_AGAINST_PRECOMPILED_LLVM TRUE)
if (EXISTS ${PATH_TO_LLVM}/CMakeLists.txt)
  set (BUILD_AGAINST_PRECOMPILED_LLVM FALSE)
endif()

# This enables assertions for Release builds.
# https://stackoverflow.com/questions/22140520/how-to-enable-assert-in-cmake-release-mode
string(REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

option(MULL_BUILD_32_BITS "Enable 32 bits build" OFF)

if (${BUILD_AGAINST_PRECOMPILED_LLVM})
  set (search_paths
    ${PATH_TO_LLVM}
    ${PATH_TO_LLVM}/lib/cmake
    ${PATH_TO_LLVM}/lib/cmake/llvm
    ${PATH_TO_LLVM}/lib/cmake/clang
    ${PATH_TO_LLVM}/share/clang/cmake/
    ${PATH_TO_LLVM}/share/llvm/cmake/
  )

  find_package(LLVM REQUIRED CONFIG PATHS ${search_paths} NO_DEFAULT_PATH)
  find_package(Clang REQUIRED CONFIG PATHS ${search_paths} NO_DEFAULT_PATH)

  if (APPLE)
    if (LLVM_VERSION_MAJOR GREATER_EQUAL 12)
      # Precompiled LLVM 12 and 13 for macOS contains a hardcoded dependency on a very
      # specific version of libcurses:
      #
      #   set_target_properties(LLVMSupport PROPERTIES
      #     INTERFACE_LINK_LIBRARIES "m;ZLIB::ZLIB;/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.1.sdk/usr/lib/libcurses.tbd;LLVMDemangle"
      #   )
      #
      # So we are monkey-patching it here
      set_target_properties(LLVMSupport PROPERTIES
        INTERFACE_LINK_LIBRARIES "z;curses;m;LLVMDemangle")
    endif()
  endif()

  if (TARGET clang)
    get_target_property(MULL_CC clang LOCATION)
  else()
    set(MULL_CC ${PATH_TO_LLVM}/bin/clang)
  endif()
else()
  macro(get_llvm_version_component input component)
    string(REGEX MATCH "${component} ([0-9]+)" match ${input})
    if (NOT match)
      message(FATAL_ERROR "Cannot find LLVM version component '${component}'")
    endif()
    set (${component} ${CMAKE_MATCH_1})
  endmacro()

  file(READ ${PATH_TO_LLVM}/CMakeLists.txt LLVM_CMAKELISTS)
  get_llvm_version_component("${LLVM_CMAKELISTS}" LLVM_VERSION_MAJOR)
  get_llvm_version_component("${LLVM_CMAKELISTS}" LLVM_VERSION_MINOR)
  get_llvm_version_component("${LLVM_CMAKELISTS}" LLVM_VERSION_PATCH)
  set (LLVM_VERSION ${LLVM_VERSION_MAJOR}.${LLVM_VERSION_MINOR}.${LLVM_VERSION_PATCH})

  if (MULL_BUILD_32_BITS)
    set (LLVM_BUILD_32_BITS ON CACHE BOOL "Forcing LLVM to be built for 32 bits as well" FORCE)
  endif()
  set (LLVM_ENABLE_PROJECTS "clang" CACHE BOOL "Build only Clang when building against monorepo" FORCE)
  set (LLVM_TARGETS_TO_BUILD "host" CACHE STRING "Do not build targets we cannot JIT" FORCE)

  add_subdirectory(${PATH_TO_LLVM} llvm-build-dir)

  if (NOT TARGET clangTooling)
    message(FATAL_ERROR " 
 Cannot find clangTooling target. Did you forget to clone clang sources?
 Clean CMake cache and make sure they are available at:
 ${PATH_TO_LLVM}/tools/clang")
  endif()

  # Normally, include paths provided by LLVMConfig.cmake
  # In this case we can 'steal' them from real targets
  get_target_property(llvm_support_includes LLVMSupport INCLUDE_DIRECTORIES)
  get_target_property(clang_tooling_includes clangTooling INCLUDE_DIRECTORIES)
  set(LLVM_INCLUDE_DIRS ${llvm_support_includes} ${clang_tooling_includes})
  list(REMOVE_DUPLICATES LLVM_INCLUDE_DIRS)

  get_target_property(clang_bin_directory clang RUNTIME_OUTPUT_DIRECTORY)
  set (MULL_CC ${clang_bin_directory}/clang)
endif()

else()

find_package(Clang CONFIG REQUIRED)
message(${LLVM_VERSION_MAJOR})
endif()
