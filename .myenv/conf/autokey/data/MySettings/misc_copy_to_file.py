import time

#contents = clipboard.get_selection()

keyboard.send_keys("<ctrl>+c")
time.sleep(0.5)
contents = clipboard.get_clipboard()

with open("/home/ouyangzhu/Documents/FCZ/record/A_NOTE_Copy.txt", "a") as myfile:
    if len(contents) > 0:
        myfile.write(contents + "\n")
    else:
        myfile.write("--- nothing selected" + "\n")
        
    myfile.close()