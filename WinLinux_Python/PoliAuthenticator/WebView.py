import ctypes
import traceback

from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import *
from PyQt5.QtCore import *
from PyQt5.QtWebEngineWidgets import QWebEngineView


class WebWindow(QMainWindow):
    def __init__(self, on_finish, on_error, parent=None):
        try:
            super(WebWindow, self).__init__(parent)
            self.on_finish = on_finish
            self.on_error = on_error
            self.__controls()
            self.setWindowTitle("PoliMi Login")
            self.setWindowIcon(QIcon('PoliAuthenticator.png'))
            self.setFixedSize(992, 500)
            self.setCentralWidget(self.browser)
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def __controls(self):
        self.browser = QWebEngineView()
        self.browser.setUrl(QUrl("https://oauthidp.polimi.it/oauthidp/oauth2/auth?response_type=token&client_id=9978142015&client_secret=61760&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=openid+865+aule+orario+rubrica+webmail+beep+guasti+appelli+prenotazione+code+notifiche+esami+carriera+chat+webeep&access_type=offline"))
        self.browser.loadFinished.connect(self.onLoadFinished)

    def onLoadFinished(self, ok):
        try:
            if ok:
                current_url = self.browser.url().toString()
                if current_url.startswith("https://oauthidp.polimi.it/oauthidp/oauth2/postLogin"):
                    self.browser.page().runJavaScript("document.getElementsByTagName('input')[0].value", self.getAuthToken)
            else:
                self.on_error("Page not loaded")
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def getAuthToken(self, returnValue):
        self.close()
        self.on_finish(returnValue)


