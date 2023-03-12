#!/usr/bin/env python


'''
Usage:
    singlejrec --key <key> -s

'''

import json
import docopt
from mercury.utils import open_in_place, read_stdin, parse_cli_params


def main(args):

    value = None
    for line in read_stdin():
        value = line.strip()
        break

    keyname = args['<key>']
    
    record = {
        keyname: value
    }

    print(json.dumps(record))


if __name__ == '__main__':
    args = docopt.docopt(__doc__)
    main(args)