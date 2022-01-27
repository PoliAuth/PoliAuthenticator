import ctypes
import shelve
import traceback
import sys
from PoliAuthenticator.Controller import Controller
from PyQt5.QtWidgets import *

if __name__ == '__main__':
    try:
        arguments = sys.argv
        if "-init" in arguments:
            r = shelve.open("appStatus.db")
            r["configured"] = "true"
        else:
            mainApp = QApplication(arguments)
            controller = Controller(arguments)
            controller.startApplication()
            sys.exit(mainApp.exec_())
    except Exception as e:
        ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)
