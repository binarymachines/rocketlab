#!/usr/bin/env python


'''
Usage:
    prompt_for_restore_file -o <outfile> [-w <working_directory>] [-x <extension>] 

Options:
    -w --working-dir    search for dumpfiles in this directory
    -x --extension      filter by this extension (default is ".dump")
    -o --outfile        write selected value to this file
'''

import os,sys
import json
import docopt
from snap import cli_tools as cli
from cmd import Cmd
from mercury.uisequences import *
from mercury.configtargets import *
from mercury.utils import tab, clear


class SinglePromptCLI(Cmd):
    def __init__(self,                 
                 **kwargs):

        Cmd.__init__(self)        
        self.params = kwargs
        self.prompt = '> '
        self.do_dumpfile_prompt()


    def do_dumpfile_prompt(self, *cmd_args):
        
        dumpfile_options = []
        extn = self.params['extension']

        working_directory = os.path.join(os.getcwd(), self.params['working_dir'])
        
        for fname in os.listdir(working_directory):
            fullname = os.path.join(working_directory, fname)
            if os.path.isfile(fullname) and fname.endswith(extn):
                dumpfile_options.append({
                    'value': fname,
                    'label': fname
                }                
                )
        
        mp = cli.MenuPrompt('select a dumpfile', dumpfile_options)
        self.value = mp.show()
        

def main(args):

    extension = '.dump'
    working_dir = os.getcwd()

    if args['--working-dir']:
        working_dir = args['<working_directory>']

    if args['--extension']:
        extension = args['<extension>']

    file_extension = extension.lstrip('.')

    clear()
    prompt_cli = SinglePromptCLI(extension=file_extension, working_dir=working_dir)    
    
    selected_file = prompt_cli.value
    if not selected_file:
        print('You must select an existing MongoDB dump file.')
        exit(1)


    output_filename = os.path.join(os.getcwd(), args['<outfile>'])
    
    with open(output_filename, 'x') as f:
        record = os.path.join(working_dir, selected_file)
        f.write(record)
        f.write('\n')


if __name__ == '__main__':
    args = docopt.docopt(__doc__)
    main(args)
