#!/usr/bin/env python3

# SPDX-License-Identifier: MIT

import argparse
import subprocess
import re

parser = argparse.ArgumentParser("gen_static_link")
parser.add_argument("-o", "--objdump", type=str, help="objdump filename", required=True)
parser.add_argument("-i", type=str, help="input file", required=True)
parser.add_argument("-c", type=str, help="output c file", required=True)
parser.add_argument("-H", type=str, help="output header file")
parser.add_argument("-b", "--base-name", type=str, help="base name of library", required=True)
args = parser.parse_args()

result = subprocess.run([ args.objdump, '-t', args.i ], stdout=subprocess.PIPE)

func_re = re.compile(r'''g     F \.text[ \t]+[0-9a-fA-F]+\s''' + args.base_name + r'''(\S+)\n''')
funcs = func_re.findall(result.stdout.decode('utf-8'))

if args.H is not None:
    with open(args.H, "w") as f:
        for func in funcs:
            f.write("extern \"C\" void " + args.base_name + func + "();\n")
        f.close()

with open(args.c, "w") as f:
    f.write("#include <string.h>\n")
    f.write("\n")
    for func in funcs:
        f.write("extern \"C\" void " + args.base_name + func + "();\n")
    f.write("\n")
    f.write("extern \"C\" void *" + args.base_name + "getproc(const char *name)\n")
    f.write("{\n")
    for func in funcs:
        f.write("\tif(!strcmp(\"" + func + "\", name))\n")
        f.write("\t\treturn (void *)" + args.base_name + func + ";\n")
        f.write("\telse\n")
    f.write("\t\treturn NULL;\n")
    f.write("}\n")
    f.write("\n")
        