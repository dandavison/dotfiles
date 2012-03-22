c = get_config()

# Why doesn't this work?
# c.TerminalIPythonApp.classic = True

c.PromptManager.in_template =  '>>> '
c.PromptManager.in2_template = '... '
c.PromptManager.out_template = '    '

c.TerminalInteractiveShell.banner1 = ''

# (NoColor, Linux, LightBG)
c.TerminalInteractiveShell.colors = 'NoColor'
# c.PromptManager.color_scheme = 'LightBG'
