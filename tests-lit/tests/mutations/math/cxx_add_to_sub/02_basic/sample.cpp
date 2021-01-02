// clang-format off

/**
RUN: cd / && %CLANG_EXEC -fembed-bitcode -g -O0 %s -o %s.exe
RUN: cd %CURRENT_DIR
RUN: unset TERM; %MULL_EXEC -linker=%clang_cxx -mutators=cxx_add_to_sub -reporters=IDE %s.exe | %FILECHECK_EXEC %s --dump-input=fail
CHECK:[info] Running mutants (threads: 1)
CHECK:{{^       \[################################\] 1/1\. Finished .*}}
CHECK:[info] All mutations have been killed
CHECK:[info] Mutation score: 100%
CHECK:[info] Total execution time: {{.*}}
CHECK-EMPTY:
**/

int sum(int a, int b) {
  return a + b;
}

int main() {
  return sum(-2, 2);
}
