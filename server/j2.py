#!/usr/bin/env python3

import os
import sys
from jinja2 import Environment, FileSystemLoader, select_autoescape


def main(args):
    j2_env = Environment()
    with open(args[0], 'r') as fhandle:
        j2_tpl = fhandle.read()
    j2_tpl = j2_env.from_string(j2_tpl)

    print(j2_tpl.render(**os.environ))


if __name__ == "__main__":
    main(sys.argv[1:])

