import ctypes
import sys
import traceback

from PyQt5 import QtWidgets
from PyQt5.QtCore import QDir
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import *
from enum import Enum

class AppStatus(Enum):
    UNLOGGED = 0
    TOKEN_NOT_VALID = -1
    TOKEN_VALID = 1


class MainView(QMainWindow):
    button_style = "background-color: blue; color: white; "

    def __init__(self, controller):
        """View initializer."""
        super().__init__()
        self.controller = controller
        self.logout_action = controller.logout_action
        self.setWindowTitle('Poli Authenticator')
        self.setWindowIcon(QIcon('PoliAuthenticator.png'))
        self.resize(500, 235)
        self.generalLayout = QGridLayout()
        self._centralWidget = QWidget(self)
        self.setCentralWidget(self._centralWidget)
        self._centralWidget.setLayout(self.generalLayout)
        self._create_layout()

    def _create_layout(self):
        self.status_label = QLabel('')
        self.message_label = QLabel('<h2>Welcome in Poli Authenticator</h2>')
        self.pin_label = QLabel('Pin (suggested at least 8 characters and 1 special character):')
        self.login_button = QPushButton('Login')
        self.pin_field = QLineEdit()
        self.logout_button = QPushButton('Logout')
        self.url_button = QPushButton('Open browser')
        self.generalLayout.addWidget(self.message_label, 0, 0, 1, 2)
        self.generalLayout.addWidget(self.login_button, 0, 3, 1, 1)
        self.generalLayout.addWidget(self.logout_button, 0, 3, 1, 1)
        self.generalLayout.addWidget(self.status_label, 1, 0, 1, 4)
        self.generalLayout.addWidget(self.url_button, 2, 0, 3, 4)
        self.generalLayout.addWidget(self.pin_field, 2, 1, 1, 3)
        self.generalLayout.addWidget(self.pin_label, 2, 0, 1, 1)

        # self.login_button.setStyleSheet(self.button_style)

        self.login_button.clicked.connect(lambda: self.login_action(self.pin_field.text()))
        self.logout_button.clicked.connect(self.logout_action)
        self.url_button.clicked.connect(lambda: self.url_action(self.pin_field.text()))

    def login_action(self, pin):
        try:
            self.controller.login_action(pin)
            self.status_label.setText("<h2>Authenticating...</h2>")
            self.status_label.setStyleSheet('color: green')
        except TypeError as e:
            self.status_label.setText("<h2>" + str(e) + "</h2>")
            self.status_label.setStyleSheet('color: red')
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def url_action(self, pin):
        self.controller.url_action(pin)

    def updateStatus(self, appStatus):
        try:
            if appStatus == AppStatus.TOKEN_VALID:
                self.status_label.setText("<h2>Authenticated</h2>")
                self.status_label.setStyleSheet('color: green')
                self.login_button.hide()
                self.logout_button.show()
                self.url_button.show()
                self.pin_field.show()
                self.pin_label.show()
                self.pin_field.setEchoMode(QtWidgets.QLineEdit.Password)
            elif appStatus == AppStatus.TOKEN_NOT_VALID:
                self.status_label.setText("<h2>Invalid token... it will be refreshed automatically</h2>")
                self.status_label.setStyleSheet('color: orange')
                self.login_button.hide()
                self.logout_button.show()
                self.url_button.show()
                self.pin_field.show()
                self.pin_label.show()
                self.pin_field.setEchoMode(QLineEdit.Password)
            else:
                self.status_label.setText("<h2>Not Authenticated</h2>")
                self.status_label.setStyleSheet('color: red')
                self.login_button.show()
                self.logout_button.hide()
                self.url_button.hide()
                self.pin_field.show()
                self.pin_label.show()
                self.pin_field.setEchoMode(QLineEdit.Normal)
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)
