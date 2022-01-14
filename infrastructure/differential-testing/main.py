#!/usr/bin/env python3

import sys
import subprocess
import datetime

csmith_header_search_path = "/usr/local/opt/csmith/include/csmith-2.3.0"
mull_ir_frontend = "/opt/mull/mull/cmake-build-debug-13-0-0/tools/mull-cxx-ir-frontend/mull-ir-frontend-13"
clang = '/usr/local/opt/llvm@13/bin/clang'
iterations = 10000

for i in range(iterations):
    print(str(datetime.datetime.now()) + " " + "Run " + str(i + 1) + "/" + str(iterations), flush=True)
    out = "main.c"
    original = "./original.exe"
    mutated = "./mutated.exe"

    print(str(datetime.datetime.now()) + " " + "Generate sample", flush=True)
    subprocess.run(["csmith", "-o", out], capture_output=True, check=True)
    seed = ""
    with open(out, "r") as f:
        seed = f.readlines(500)[6].rstrip()

    print(str(datetime.datetime.now()) + " " + "Compile original", flush=True)
    subprocess.run([clang, out, "-I"+csmith_header_search_path, "-o", original], capture_output=True, check=True)
    print(str(datetime.datetime.now()) + " " + "Compile mutated", flush=True)
    subprocess.run([clang, out, "-I"+csmith_header_search_path, "-fexperimental-new-pass-manager", "-fpass-plugin=" + mull_ir_frontend, "-g", "-grecord-command-line", "-o", mutated], capture_output=True, check=True)

    try:
        print(str(datetime.datetime.now()) + " " + "Run original", flush=True)
        o = subprocess.check_output([original], timeout=10)
        print(str(datetime.datetime.now()) + " " + "Run mutated", flush=True)
        m = subprocess.check_output([mutated], timeout=50)
        if o != m:
            print(str(datetime.datetime.now()) + " " + "Failed: " + seed, flush=True)
            print(o, m)
        else:
            print(str(datetime.datetime.now()) + " " + "Success", flush=True)
    except Exception as e:
        print("Error " + str(e), flush=True)
        print(seed, flush=True)
    print(flush=True)

