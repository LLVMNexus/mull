#include "sum.h"

extern "C" {
extern int printf(const char *, ...);
}

int sum(int a, int b) {
  return SUM(a, b);
}

int main() {
  if (sum(2, 3) == 5) {
    printf("NORMAL\n");
    return 0;
  } else {
    printf("MUTATED\n");
    return 1;
  }
}

// clang-format off

/**
RUN: %CLANG_EXEC -fplugin=%mull_frontend_cxx -Xclang -plugin-arg-mull-cxx-frontend -Xclang mutators=cxx_add_to_sub %s -o %s.exe | %FILECHECK_EXEC %s --dump-input=fail --strict-whitespace --match-full-lines --check-prefix=FRONTEND
FRONTEND:Recording mutation point: cxx_add_to_sub:{{.*}}/sum.h:1:21 (end: 1:22)

RUN: %s.exe | %FILECHECK_EXEC %s --dump-input=fail --strict-whitespace --match-full-lines --check-prefix=STANDALONE_WITHOUT_MUTATION
RUN: (env "cxx_add_to_sub:%S/sum.h:1:21"=1 %s.exe || true) | %FILECHECK_EXEC %s --dump-input=fail --strict-whitespace --match-full-lines --check-prefix=STANDALONE_WITH_MUTATION

STANDALONE_WITHOUT_MUTATION:NORMAL
STANDALONE_WITH_MUTATION:MUTATED

RUN: %mull_runner %s.exe -ide-reporter-show-killed | %FILECHECK_EXEC %s --dump-input=fail --strict-whitespace --match-full-lines --check-prefix=MULL_RUNNER

MULL_RUNNER:[info] Killed mutants (1/1):
MULL_RUNNER:{{.*}}sum.h:1:21: warning: Killed: Replaced + with - [cxx_add_to_sub]
*/
