import os,sys
import json
import docopt
from snap import cli_tools as cli
from cmd import Cmd
from mercury.uisequences import *
from mercury.configtargets import *
from mercury.utils import tab, clear
from mercury.utils import open_in_place, read_stdin, parse_cli_params


class TestPromptCLI(Cmd):
    def __init__(self,                 
                 **kwargs):

        Cmd.__init__(self)        
        self.params = kwargs
        self.prompt = '> '

        self.options = []

        optfile = kwargs['optfile']
        with open(optfile, 'r') as f:
            for raw_line in f:
                line = raw_line.strip()
                if not line:
                    continue
                self.options.append({'value': line, 'label': line})
        
        

    def option_prompt(self, *cmd_args):
        
        mp = cli.MenuPrompt('select an option', self.options)
        return mp.show()