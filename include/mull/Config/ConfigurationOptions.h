#pragma once

namespace mull {

enum class IDEDiagnosticsKind { None, Survived, Killed, All };

struct ParallelizationConfig {
  unsigned workers;
  unsigned executionWorkers;
  ParallelizationConfig();
  static ParallelizationConfig defaultConfig();
  void normalize();
  bool exceedsHardware();
};

struct DebugConfig {
  bool printIR = false;
  bool printIRBefore = false;
  bool printIRAfter = false;
  bool traceMutants = false;
  bool coverage = false;
};

} // namespace mull
