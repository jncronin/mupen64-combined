#!/usr/bin/env python3

# SPDX-License-Identifier: MIT

import argparse
import subprocess
import re

parser = argparse.ArgumentParser("gen_static_link")
parser.add_argument("-o", "--objdump", type=str, help="objdump filename", required=True)
parser.add_argument("-i", type=str, help="input file", required=True)
parser.add_argument("-r", type=str, help="output file", required=True)
parser.add_argument("-b", "--base-name", type=str, help="base name of library", required=True)
args = parser.parse_args()

result = subprocess.run([ args.objdump, '-t', args.i ], stdout=subprocess.PIPE)

func_re = re.compile(r'''g     F \.text[ \t]+[0-9a-fA-F]+\s(\S+)\n''')
funcs = func_re.findall(result.stdout.decode('utf-8'))

objs_re = re.compile(r'''g     O (?:\.bss|\.data)[ \t]+[0-9a-fA-F]+\s(\S+)\n''')
objs = objs_re.findall(result.stdout.decode('utf-8'))

with open(args.r, "w") as f:
    for func in [ *funcs, *objs ]:
        f.write(func + " " + args.base_name + func + "\n")
    f.close()
