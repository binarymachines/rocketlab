#!/usr/bin/env python

import datetime
import uuid

def generate_dumpfile_name(**macro_args):

    base_name = macro_args['base_name']
    timestamp = datetime.datetime.now().isoformat()
    return f'{base_name}_{timestamp}'
    

def current_timestamp(**macro_args):
    return f'{datetime.date.today().isoformat()}_{uuid.uuid4()}'
    