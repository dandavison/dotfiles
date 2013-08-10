c = get_config()

# Why doesn't this work?
# c.TerminalIPythonApp.classic = True

c.PromptManager.in_template =  '>>> '
c.PromptManager.in2_template = '... '
c.PromptManager.out_template = '    '

c.TerminalInteractiveShell.banner1 = ''

# (NoColor, Linux, LightBG)
c.TerminalInteractiveShell.colors = 'NoColor'
# c.PromptManager.color_scheme = 'Linux'  # 'LightBG'

c.InteractiveShellApp.extensions = [
    'autoreload',
]

c.InteractiveShellApp.exec_lines = [
    'import sys',
    'import os',
    'sys.path.append(os.path.expanduser("~"))',
]

c.InteractiveShellApp.pylab_import_all = False
