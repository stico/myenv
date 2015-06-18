# Run command file for percol

# import settings
from percol.finder import FinderMultiQueryRegex, FinderMultiQueryPinyin, FinderMultiQueryString

# prompt, RPROMPT is on the right side
percol.view.prompt_replacees["F"] = lambda self, **args: self.model.finder.get_name()
percol.view.PROMPT  = ur"<blue>(%F) [%i/%I]</blue> %q"
percol.view.RPROMPT = ur"(%F) [%i/%I]"

# keymap
percol.import_keymap({
    # edit
    "C-h" : lambda percol: percol.command.delete_backward_char(),
    "C-d" : lambda percol: percol.command.delete_forward_char(),
    "C-k" : lambda percol: percol.command.kill_end_of_line(),
    "C-y" : lambda percol: percol.command.yank(),
    "C-t" : lambda percol: percol.command.transpose_chars(),
    "C-a" : lambda percol: percol.command.beginning_of_line(),
    "C-e" : lambda percol: percol.command.end_of_line(),
    "C-b" : lambda percol: percol.command.backward_char(),
    "C-f" : lambda percol: percol.command.forward_char(),
    "M-f" : lambda percol: percol.command.forward_word(),
    "M-b" : lambda percol: percol.command.backward_word(),
    "M-d" : lambda percol: percol.command.delete_forward_word(),
    "M-h" : lambda percol: percol.command.delete_backward_word(),

    # select
    "C-n" : lambda percol: percol.command.select_next(),
    "C-p" : lambda percol: percol.command.select_previous(),
    "C-v" : lambda percol: percol.command.select_next_page(),
    "M-v" : lambda percol: percol.command.select_previous_page(),
    "M-<" : lambda percol: percol.command.select_top(),
    "M->" : lambda percol: percol.command.select_bottom(),

    # switch
    #"M-c" : lambda percol: percol.command.toggle_case_sensitive(),
    #"M-m" : lambda percol: percol.command.toggle_finder(FinderMultiQueryMigemo),
    #"M-r" : lambda percol: percol.command.toggle_finder(FinderMultiQueryRegex),
    "C-r" : lambda percol: SticoCustomization.toggle_finder(),

    # misc
    #"C-m" : lambda percol: percol.finish(),
    "C-j" : lambda percol: percol.finish(),
    "C-g" : lambda percol: percol.cancel(),
})

# Since there is NO looping toggle method, write one here
class SticoCustomization(object):
    index = 0
    list = [FinderMultiQueryString, FinderMultiQueryRegex, FinderMultiQueryPinyin]

    @classmethod
    def toggle_finder(cls):
        percol.command.toggle_finder(cls.list[cls.index%3])
        cls.index += 1
