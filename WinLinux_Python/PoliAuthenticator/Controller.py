import base64
import ctypes
import os
import shelve
import sys
import traceback
import webbrowser
from base64 import b64encode
from base64 import b64decode
from sys import exit

import certifi
import cryptography.fernet
import requests as req
import re
import hashlib
from datetime import datetime, timedelta
from PyQt5.QtWidgets import QMessageBox
from cryptography.hazmat.backends.openssl import backend
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes

from PoliAuthenticator.MainView import AppStatus, MainView
from PoliAuthenticator.WebView import WebWindow
from cryptography.fernet import Fernet


class Controller:
    def __init__(self, arguments):
        super().__init__()
        self.pin = ""
        self.isDeepLink = False
        if "-deeplink" in arguments:
            self.isDeepLink = True
        self.mainView = MainView(self)
        self.webView = WebWindow(self.on_weblogin_finish, self.on_weblogin_error, self.mainView)

    def startApplication(self):
        try:
            self.updateMainView(self.getAppStatus())
            self.mainView.show()
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def getAppStatus(self):
        r = shelve.open('appStatus.db')
        if 'access_token' in r:
            expire = r['expire']
            r.close()
            date = datetime.strptime(expire, '%m-%d-%Y %H:%M:%S')
            now = datetime.now()
            if date > now:
                return AppStatus.TOKEN_VALID
            else:
                return AppStatus.TOKEN_NOT_VALID
        else:
            r.close()
            return AppStatus.UNLOGGED

    def refresh_token(self, refresh_token):
        post_data = {'grant_type': 'refresh_token', 'refresh_token': refresh_token,
                     'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob', 'client_id': '9978142015', 'client_secret': '61760'}
        result = req.post('https://oauthidp.polimi.it/oauthidp/oauth2/token', data=post_data)
        json_result = result.json()
        return json_result

    def get_access_token(self, access_token):
        try:
            post_data = {'grant_type': 'authorization_code', 'code': access_token,
                         'redirect_uri': 'urn:ietf:wg:oauth:2.0:oob', 'client_id': '9978142015',
                         'client_secret': '61760'}
            result = req.post('https://oauthidp.polimi.it/oauthidp/oauth2/token', data=post_data)
            json_result = result.json()
            return json_result
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def parseJsonResponse(self, json, newSalt):
        try:
            r = shelve.open('appStatus.db')
            if 'access_token' not in json:
                self.on_weblogin_error("Bad response")
                return
            access_token = json['access_token']
            if newSalt:
                salt = os.urandom(16)
            else:
                salt = base64.b64decode(str(r['salt']).encode('utf-8'))
            self.saveAccessToken(access_token, salt)
            self.saveExpiration(self.getNow23h())
            if 'refresh_token' in json:
                refresh_token = json['refresh_token']
                self.saveRefreshToken(refresh_token, salt)
            self.updateMainView(AppStatus.TOKEN_VALID)
            r.close()
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def saveAccessToken(self, access_token, salt):
        self.saveEncTokenInDb('access_token', access_token, salt)

    def saveRefreshToken(self, refresh_token, salt):
        self.saveEncTokenInDb('refresh_token', refresh_token, salt)


    def saveEncTokenInDb(self, query, token, salt):
        try:
            r = shelve.open('appStatus.db')
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=100000,
                backend=backend
            )
            key = base64.urlsafe_b64encode(kdf.derive(self.pin.encode()))
            fernet = Fernet(key)
            enc_token = fernet.encrypt(token.encode())
            r['salt'] = b64encode(salt).decode('utf-8')
            r[query] = b64encode(enc_token).decode('utf-8')
            r.close()
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def saveExpiration(self, expiration):
        r = shelve.open('appStatus.db')
        r['expire'] = expiration
        r.close()

    def readEncTokenFromDb(self, query):
        try:
            r = shelve.open('appStatus.db')
            salt = base64.b64decode(str(r['salt']).encode('utf-8'))
            kdf = PBKDF2HMAC(
                algorithm=hashes.SHA256(),
                length=32,
                salt=salt,
                iterations=100000,
                backend=backend
            )
            enc_token = base64.b64decode(str(r[query]).encode('utf-8'))
            key = base64.urlsafe_b64encode(kdf.derive(self.pin.encode()))
            fernet = Fernet(key)
            token = fernet.decrypt(enc_token)
            r.close()
            return token
        except cryptography.fernet.InvalidToken:
            ctypes.windll.user32.MessageBoxW(None, "Seems like the token is corrupted, try to logout and log back in", "Error", 1)
        except cryptography.fernet.InvalidSignature:
            ctypes.windll.user32.MessageBoxW(None, "Seems like the signature is currupted, try to logout and log back "
                                                   "in", "Error", 1)
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)

    def getAccessToken(self):
        token = self.readEncTokenFromDb('access_token')
        self.mainView.status_label.setText("<h2>Authenticated</h2>")
        self.mainView.status_label.setStyleSheet('color: green')
        return str(token.decode())

    def getRefreshToken(self):
        r_token = self.readEncTokenFromDb('refresh_token')
        return r_token

    def handle_refresh(self):
        self.parseJsonResponse(self.refresh_token(self.getRefreshToken()), newSalt= False)
        pass

    def clear(self, callback):
        r = shelve.open('appStatus.db')
        r.pop('access_token')
        r.pop('refresh_token')
        r.pop('expire')
        r.pop('pin')
        r.pop('salt')
        r.close()
        callback()

    def getNow23h(self):
        date = datetime.now() + timedelta(hours=23)
        return date.strftime("%m-%d-%Y %H:%M:%S")

    def updateMainView(self, appStatus):
        self.mainView.updateStatus(appStatus)

    def on_weblogin_error(self, message):
        msg = QMessageBox()
        msg.setIcon(QMessageBox.Critical)
        msg.setText("Error")
        msg.setInformativeText(message)
        msg.setWindowTitle("Error")
        msg.exec_()

    def on_weblogin_finish(self, result):
        result = self.get_access_token(result)
        self.parseJsonResponse(result, newSalt = True)

    def login_action(self, pin):
        if not re.fullmatch("^(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$", pin):
            qm = QMessageBox()
            resp = qm.question(self.mainView, 'Pin Input',
                               '<h2 style=color:red>CAUTION!</h2>'
                               "Your PIN appears to be very weak, you might "
                               "not be able to logout from remote if your PC is stolen "
                               "or if someone has access to it. Consider "
                               "using a PIN at least 8 char long and with at least "
                               "1 special character. <br>Do you want to continue anyway?"
                               , qm.Yes, qm.Cancel)
            if resp == qm.Cancel:
                raise TypeError("Type a new PIN")
        r = shelve.open('appStatus.db')
        encodedPin = pin.encode()
        r["pin"] = hashlib.sha224(encodedPin).hexdigest()
        self.pin = pin
        self.webView.show()

    def logout_action(self):
        qm = QMessageBox()
        resp = qm.question(self.mainView, 'Logout', "Are you sure to logout?", qm.Yes | qm.No)
        if resp == qm.Yes:
            self.clear(lambda: self.mainView.updateStatus(AppStatus.UNLOGGED))

    def url_action(self, pin):
        try:
            r = shelve.open('appStatus.db')
            if hashlib.sha224(str(pin).encode()).hexdigest() != r['pin']:
                self.mainView.status_label.setText("<h2>" + "Pin appears to be incorrect" + "</h2>")
                self.mainView.status_label.setStyleSheet('color: red')
                return
            self.pin = pin
            if self.getAppStatus() == AppStatus.TOKEN_NOT_VALID:
                self.handle_refresh()
            token = self.getAccessToken()
            webbrowser.open(
                "https://aunicalogin.polimi.it/aunicalogin/getservizioOAuth.xml"
                "?id_servizio=2270&lang=it&access_token=" + token)
            if self.isDeepLink:
                exit(0)
        except Exception:
            ctypes.windll.user32.MessageBoxW(None, traceback.format_exc(), "Error", 1)
