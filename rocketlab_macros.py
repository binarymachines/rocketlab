#!/usr/bin/env python

import datetime

def generate_dumpfile_name(**macro_args):

    base_name = macro_args['base_name']
    timestamp = datetime.datetime.now().isoformat()
    return f'{base_name}_{timestamp}'
    
