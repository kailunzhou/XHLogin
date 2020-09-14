import Foundation
import UIKit
@_exported import ZCommonTool
@_exported import XHNetTool
@_exported import MBProgressHUD
@_exported import SnapKit

private let LoginConfigShareInstance = LoginConfig()

open class LoginConfig {
    public class var share : LoginConfig {
        return LoginConfigShareInstance
    }
    
    public var device_token: String = "1111111111111111111111111111111111111111111111111111111111111111"//设备deviceToken,推送要
    public var loginHandle: ((_ info: [String: Any])->())?//登录成功后的处理
    public var fullAcount: (String?, String?) = (nil, nil)//账号填充
    
    ///账号密码登录
    public func usernameLogin(_ username: String, _ password: String) {
        let imei = UIDevice.current.identifierForVendor?.uuidString ?? "iosDeviceSetupIMEIError"
        let param: [String: Any] = [
            "data": ["userName": username, "password": password, "imei": imei],
            "deviceTokens": LoginConfig.share.device_token
        ]
        BaseNet.default.BaseNetParamRequest("/admin/login", param, nil, true, endAction: {}) { (data) in
            if let dic = data as? [String: Any] {
                LoginConfig.share.loginHandle?(dic)
            }
        }
    }
    ///手机验证码登录
    public func smscodeLogin(_ mobile: String, _ smscode: String) {
        let imei = UIDevice.current.identifierForVendor?.uuidString ?? "iosDeviceSetupIMEIError"
        let param: [String: Any] = [
            "data": ["mobile": mobile, "loginSmsCode": smscode, "imei": imei],
            "deviceTokens": LoginConfig.share.device_token
        ]
        BaseNet.default.BaseNetParamRequest("/admin/login", param, nil, true, endAction: {}) { (data) in
            if let dic = data as? [String: Any] {
                LoginConfig.share.loginHandle?(dic)
            }
        }
    }
    ///发送验证码
    public func sendSmscode(_ mobile: String, _ type: SmscodeTypeEnum, _ action: @escaping ()->()) {
        let param: [String: Any] = [
            "data": [
                "mobile": mobile,
                "smsType": type.rawValue
            ]
        ]
        BaseNet.default.BaseNetParamRequest("/smsCode/fetch", param, nil, true, endAction: {}) { (_) in
            action()
        }
    }
    ///校验验证码
    public func checkSmscode(_ mobile: String, _ smscode: String, _ type: SmscodeTypeEnum, _ action: @escaping ()->()) {
        let param: [String: Any] = [
            "data": [
                "mobile": mobile,
                "code": smscode,
                "smsType": type.rawValue
            ]
        ]
        BaseNet.default.BaseNetParamRequest("/smsCode/check", param, nil, true, endAction: {}) { (_) in
            action()
        }
    }
    ///重置密码
    public func resetPassword(_ mobile: String, _ smscode: String, _ password: String, _ action: @escaping ()->()) {
        let param: [String: Any] = [
            "data": [
                "mobile": mobile,
                "smsCode": smscode,
                "newPswd": password
            ]
        ]
        BaseNet.default.BaseNetParamRequest("/admin/resetPswd", param, nil, true, endAction: {}) { (_) in
            MBProgressHUD.showMessage(nil, with: "修改密码成功", complete: nil)
            action()
        }
    }
    ///注册账号
    public func registerAccount(_ mobile: String, _ username: String, _ password: String, _ action: @escaping ()->()) {
        let param: [String: Any] = [
            "data": [
                "mobile": mobile,
                "userName": username,
                "password": password
            ],
            "deviceTokens": LoginConfig.share.device_token
        ]
        BaseNet.default.BaseNetParamRequest("/admin/register", param, nil, true, endAction: {}) { (_) in
            MBProgressHUD.showMessage(nil, with: "快速注册成功", complete: nil)
            action()
        }
    }
    ///获取H5链接，隐私政策：privacyPolicy  ，用户注册协议：agreement
    public func getH5URL(_ key: String, _ action: @escaping (_ url: String)->()) {
        let param: [String: Any] = [
            "data": [
                "pageAlias": key
            ]
        ]
        BaseNet.default.BaseNetParamRequest("/page", param, nil, true, endAction: {}) { (data) in
            if let dic = data as? [String: Any], let path = dic["path"] as? String {
                action(path)
            }
        }
    }
}

public enum SmscodeTypeEnum: Int {
    case forgotPassword = 1
    case register = 2
    case approve = 3
    case login = 4
}

public extension String {
    ///密码
    func regularPassword() -> Bool {
        if self.count > 20 || self.count < 6 {
            return false
        }
        let pattern = "^[\\x00-\\xff]{6,20}$"
        do {
            let count = try NSRegularExpression(pattern: pattern, options: .caseInsensitive).numberOfMatches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count))
            if count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            print(error)
            return false
        }
    }
}
