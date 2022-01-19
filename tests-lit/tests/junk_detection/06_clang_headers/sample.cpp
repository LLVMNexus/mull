#include <stdarg.h>

int sum(int a, int b) {
  return a + b;
}

int main() {
  return sum(-2, 2);
}

// clang-format off

/**
RUN: %clang_cxx %sysroot -O0 %pass_mull_ir_frontend -g %s -o %s.exe 2>&1 | %filecheck %s --dump-input=fail --strict-whitespace --match-full-lines
CHECK-NOT:fatal error: 'stdarg.h' file not found
**/
