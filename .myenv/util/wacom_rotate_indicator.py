#!/usr/bin/env python

# https://wiki.ubuntu.com/DesktopExperienceTeam/ApplicationIndicators

import pygtk
pygtk.require('2.0')
import gtk
import appindicator
from subprocess import call

class RotationIndicator:
    def __init__(self):
        self.ind = appindicator.Indicator("Rotation Indicator", "indicator-messages", appindicator.CATEGORY_APPLICATION_STATUS)
        self.ind.set_status(appindicator.STATUS_ACTIVE)
        self.ind.set_attention_icon("indicator-messages-new")
        self.ind.set_icon("distributor-logo")

        self.menu = gtk.Menu()
        
        item = gtk.MenuItem("------")
        item.show()
        self.menu.append(item)

        item = gtk.MenuItem("Rotate")
        item.connect("activate", self.rotate)
        item.show()
        self.menu.append(item)

        item = gtk.MenuItem("------")
        item.show()
        self.menu.append(item)

        image = gtk.ImageMenuItem(gtk.STOCK_QUIT)
        image.connect("activate", self.quit)
        image.show()
        self.menu.append(image)
                    
        self.menu.show()
        self.ind.set_menu(self.menu)

    def rotate(self, widget, data=None):
        call(["sh", "/home/ouyangzhu/.myenv/util/wacom_rotate.sh"])

    def quit(self, widget, data=None):
        gtk.main_quit()


def main():
    gtk.main()
    return 0

if __name__ == "__main__":
    indicator = RotationIndicator()
    main()
