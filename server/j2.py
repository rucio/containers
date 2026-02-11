#!/usr/bin/env python3

import os
import sys

import jinja2


def main(args):
    with open(args[0], 'r') as fhandle:
        contents = fhandle.read()
    j2_tpl = jinja2.Environment().from_string(contents)

    print(j2_tpl.render(**os.environ))


if __name__ == "__main__":
    main(sys.argv[1:])
