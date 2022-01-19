# Generate headers

set (header_root "${CLANG_INSTALL_PREFIX}/lib/clang/${LLVM_VERSION}/include")
#message(${header_root})
file(GLOB_RECURSE headers ${header_root}/*)

list(GET headers 0 header)
message("${header}")

foreach(header ${headers})
  string(REPLACE ${header_root}/ "" header_relative_path ${header})
#  message(${header_relative_path})
endforeach()

set (SOURCES
  ClangHeaders.cpp
)

add_library(mull-clang-headers ${SOURCES})
target_include_directories(mull-clang-headers PRIVATE ${MULL_INCLUDE_DIRS})
target_include_directories(mull-clang-headers SYSTEM PRIVATE ${THIRD_PARTY_INCLUDE_DIRS})

# TODO: replace with target_compile_options and target_link_options
set_target_properties(mull-clang-headers PROPERTIES
  COMPILE_FLAGS ${MULL_CXX_FLAGS}
  )