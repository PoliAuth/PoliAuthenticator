//
//  AppConst.swift
//  PoliBrowser
//
//  
//

import Foundation
import UIKit

enum AppStatus: String {
    case UNLOGGED = "Non autenticato"
    case TOKEN_VALID = "Token valido"
    case TOKEN_NOT_VALID = "Token scaduto"
    case LOCKED = "App bloccata"
}

class AppConst {
    public static let AUTH_SERVER = "https://oauthidp.polimi.it/oauthidp/oauth2/auth?response_type=token&client_id=9978142015&client_secret=61760&redirect_uri=urn:ietf:wg:oauth:2.0:oob&scope=openid+865+aule+orario+rubrica+webmail+beep+guasti+appelli+prenotazione+code+notifiche+esami+carriera+chat+webeep&access_type=offline"
    public static let AUTH_TOKEN_WEB = "https://oauthidp.polimi.it/oauthidp/oauth2/postLogin"
    public static let TOKEN_SERVER = "https://oauthidp.polimi.it/oauthidp/oauth2/token"
    public static let REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
    public static let CLIENT_ID = "9978142015"
    public static let CLIENT_SECRET = "61760"
    public static let WEBEEP_URL = "https://aunicalogin.polimi.it/aunicalogin/getservizioOAuth.xml?id_servizio=2270&lang=it&access_token="

}
