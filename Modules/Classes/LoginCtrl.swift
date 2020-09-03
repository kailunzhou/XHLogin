import UIKit

open class LoginCtrl: CTBaseCtrl {
    private var mainView = LoginView()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private func buildUI() {
        mainView = LoginView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] (type) in
            switch type {
            case .register:
                let vCtrl = RegisterMobileCtrl()
                self?.navigationController?.pushViewController(vCtrl, animated: true)
            case .forgotPassword:
                let vCtrl = ForgotPasswordMobileCtrl()
                self?.navigationController?.pushViewController(vCtrl, animated: true)
            case .privacy:
                self?.skipH5()
            }
        }
        mainView.loginAction = { (username, password) in
            LoginConfig.share.usernameLogin(username, password)
        }
        mainView.smscodeAction = { [weak self] (mobile) in
            self?.sendSmscode(mobile)
        }
    }
    
    private func sendSmscode(_ mobile: String) {
        LoginConfig.share.sendSmscode(mobile, .login) { [weak self] in
            let vCtrl = LoginSmscodeCtrl()
            vCtrl.mobileStr = mobile
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
    
    private func skipH5() {
        LoginConfig.share.getH5URL("privacyPolicy") { [weak self] (url) in
            let vCtrl = CTPureH5Ctrl()
            vCtrl.titletext = "隐私政策"
            vCtrl.geturl = url
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class LoginView: UIView {
    private var usernameTF = XHTextField(frame: .zero)
    private var passwordTF = XHTextField(frame: .zero)
    private var mobileTF = XHTextField(frame: .zero)
    
    private let usernameBgView = UIView()
    private var showBtn = UIButton()
    private let smscodeBgView = UIView()
    
    private var nextBtn = UIButton()
    private var registerBtn = UIButton()
    private var forgotPasswordBtn = UIButton()
    private var typeBtn = UIButton()
    private var privacyBtn = UIButton()
    
    private var isUserLogin = true {
        didSet {
            usernameBgView.isHidden = !isUserLogin
            smscodeBgView.isHidden = isUserLogin
            if isUserLogin {
                nextBtn.setTitle("登录", for: .normal)
                typeBtn.setTitle("短信验证码登录", for: .normal)
            } else {
                nextBtn.setTitle("获取验证码", for: .normal)
                typeBtn.setTitle("账号密码登录", for: .normal)
            }
        }
    }
    public var clickAction: ((_ type: LoginViewClickTypeEnum)->())?
    public var loginAction: ((_ username: String, _ password: String)->())?
    public var smscodeAction: ((_ mobile: String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        #if DEBUG
        usernameTF.text = LoginConfig.share.fullAcount.0
        passwordTF.text = LoginConfig.share.fullAcount.1
        #endif
        
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.attributedText = NSAttributedString(string: "您好，\n欢迎来到星和联盟OS", attributes: [.foregroundColor: UIColor(hexString: "333333"), .font: UIFont.systemFont(ofSize: 25, weight: .medium)])
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32.0 + NaviH)
            make.left.equalToSuperview().offset(24)
        }
        
        addSubview(usernameBgView)
        usernameBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.height.equalTo(116)
        }
        
        usernameTF.placeholder = "请输入账号"
        usernameTF.returnKeyType = .next
        usernameTF.delegate = self
        usernameBgView.addSubview(usernameTF)
        usernameTF.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let usernameLine = UIView()
        usernameLine.backgroundColor = UIColor(hexString: "E2E2E2")
        usernameBgView.addSubview(usernameLine)
        usernameLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(usernameTF.snp.bottom)
            make.height.equalTo(1)
        }
        
        showBtn.setImage(UIImage(named: "login_closeeye", LoginView.self), for: .normal)
        showBtn.setImage(UIImage(named: "login_openeye", LoginView.self), for: .selected)
        showBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        usernameBgView.addSubview(showBtn)
        showBtn.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLine.snp.bottom).offset(26)
            make.right.equalToSuperview()
            make.width.height.equalTo(24)
        }
        
        passwordTF.isSecureTextEntry = true
        passwordTF.placeholder = "请输入密码"
        passwordTF.delegate = self
        usernameBgView.addSubview(passwordTF)
        passwordTF.snp.makeConstraints { (make) in
            make.top.equalTo(usernameLine.snp.bottom).offset(16)
            make.left.equalToSuperview()
            make.right.equalTo(showBtn.snp.left).offset(-16)
            make.height.equalTo(44)
        }
        
        let passwordLine = UIView()
        passwordLine.backgroundColor = UIColor(hexString: "E2E2E2")
        usernameBgView.addSubview(passwordLine)
        passwordLine.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(passwordTF.snp.bottom)
            make.height.equalTo(1)
        }
        
        addSubview(smscodeBgView)
        smscodeBgView.isHidden = true
        smscodeBgView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.height.equalTo(116)
        }
        
        let mobileLine = UIView()
        mobileLine.backgroundColor = UIColor(hexString: "E2E2E2")
        smscodeBgView.addSubview(mobileLine)
        mobileLine.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
        
        mobileTF.keyboardType = .numberPad
        mobileTF.placeholder = "请输入手机号"
        mobileTF.delegate = self
        smscodeBgView.addSubview(mobileTF)
        mobileTF.snp.makeConstraints { (make) in
            make.bottom.equalTo(mobileLine.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        let mobileTitleLabel = UILabel()
        mobileTitleLabel.attributedText = NSAttributedString(string: "(+86)", attributes: [.foregroundColor: UIColor(hexString: "353535"), .font: UIFont.systemFont(ofSize: 15, weight: .medium)])
        smscodeBgView.addSubview(mobileTitleLabel)
        mobileTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(mobileTF.snp.top).offset(-10)
            make.left.equalToSuperview()
            make.height.equalTo(32)
        }
        
        nextBtn.layer.cornerRadius = 24
        nextBtn.clipsToBounds = true
        nextBtn.backgroundColor = UIColor(hexString: "FF6E23")
        nextBtn.setTitle("登录", for: .normal)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nextBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(196)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        
        registerBtn.setAttributedTitle(NSAttributedString(string: "快速注册", attributes: [.foregroundColor: UIColor(hexString: "646464"), .font: UIFont.systemFont(ofSize: 14)]), for: .normal)
        registerBtn.contentHorizontalAlignment = .right
        registerBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(registerBtn)
        registerBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(nextBtn.snp.bottom).offset(12)
            make.width.equalTo(62)
            make.height.equalTo(40)
        }
        
        let vSepLine = UIView()
        vSepLine.backgroundColor = UIColor(hexString: "ECECEC")
        addSubview(vSepLine)
        vSepLine.snp.makeConstraints { (make) in
            make.right.equalTo(registerBtn.snp.left).offset(-5)
            make.centerY.equalTo(registerBtn.snp.centerY)
            make.height.equalTo(20)
            make.width.equalTo(1)
        }
        
        forgotPasswordBtn.setAttributedTitle(NSAttributedString(string: "忘记密码", attributes: [.foregroundColor: UIColor(hexString: "646464"), .font: UIFont.systemFont(ofSize: 14)]), for: .normal)
        forgotPasswordBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(forgotPasswordBtn)
        forgotPasswordBtn.snp.makeConstraints { (make) in
            make.right.equalTo(vSepLine.snp.left).offset(-5)
            make.top.equalTo(nextBtn.snp.bottom).offset(12)
            make.width.equalTo(62)
            make.height.equalTo(40)
        }
        
        typeBtn.setTitle("短信验证码登录", for: .normal)
        typeBtn.setTitleColor(UIColor(hexString: "646464"), for: .normal)
        typeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        typeBtn.contentHorizontalAlignment = .left
        typeBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(typeBtn)
        typeBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(nextBtn.snp.bottom).offset(12)
            make.width.equalTo(110)
            make.height.equalTo(40)
        }
        
        let tipDetailLabel = UILabel()
        tipDetailLabel.attributedText = NSAttributedString(string: "使用星和联盟OS将获取您的企业名称头像等公开信息", attributes: [.foregroundColor: UIColor(hexString: "9E9E9E"), .font: UIFont.systemFont(ofSize: 12)])
        addSubview(tipDetailLabel)
        tipDetailLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20 - BottomSafeH)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }
        
        let tipLabel = UILabel()
        tipLabel.font = UIFont.systemFont(ofSize: 12)
        let mutableAttribute = NSMutableAttributedString(string: "登录即代表您已经同意", attributes: [.foregroundColor: UIColor(hexString: "9E9E9E")])
        mutableAttribute.append(NSAttributedString(string: "《星和联盟OS隐私政策》", attributes: [.foregroundColor: UIColor(hexString: "494E59")]))
        tipLabel.attributedText = mutableAttribute
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(tipDetailLabel.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }
        
        let privacyLabel = UILabel()
        privacyLabel.attributedText = NSAttributedString(string: "《星和联盟OS隐私政策》", attributes: [.foregroundColor: UIColor.clear, .font: UIFont.systemFont(ofSize: 12)])
        addSubview(privacyLabel)
        privacyLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tipLabel.snp.centerY)
            make.right.equalTo(tipLabel.snp.right)
            make.height.equalTo(16)
        }
        privacyBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints { (make) in
            make.top.equalTo(privacyLabel.snp.top)
            make.bottom.equalTo(privacyLabel.snp.bottom)
            make.left.equalTo(privacyLabel.snp.left)
            make.right.equalTo(privacyLabel.snp.right)
        }
    }
    
    @objc private func clickMethod(_ sender: UIButton) {
        switch sender {
        case showBtn:
            sender.isSelected = !sender.isSelected
            passwordTF.isSecureTextEntry = !sender.isSelected
            let text = passwordTF.text
            passwordTF.text = " "
            passwordTF.text = text
            if passwordTF.isSecureTextEntry {
                passwordTF.insertText(passwordTF.text ?? "")
            }
        case nextBtn:
            self.endEditing(true)
            if isUserLogin {
                guard let username = usernameTF.text, username.count > 0 else {
                    MBProgressHUD.showMessage(nil, with: "请输入账号", complete: nil)
                    break
                }
                guard let password = passwordTF.text, password.count > 0 else {
                    MBProgressHUD.showMessage(nil, with: "请输入密码", complete: nil)
                    break
                }
                loginAction?(username, password)
            } else {
                guard let mobile = mobileTF.text, mobile.count == 11 else {
                    MBProgressHUD.showMessage(nil, with: "请输入11位手机号", complete: nil)
                    break
                }
                smscodeAction?(mobile)
            }
        case registerBtn:
            self.endEditing(true)
            clickAction?(.register)
        case forgotPasswordBtn:
            self.endEditing(true)
            clickAction?(.forgotPassword)
        case typeBtn:
            self.endEditing(true)
            isUserLogin = !isUserLogin
        case privacyBtn:
            self.endEditing(true)
            clickAction?(.privacy)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoginView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == mobileTF {
            let str = (textField.text ?? "") + string
            if str.count > 11 {
                textField.text = (textField.text ?? "").substring(to: 11)
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == usernameTF {
            passwordTF.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == passwordTF {
            if textField.isSecureTextEntry {
                textField.insertText(passwordTF.text ?? "")
            }
        }
    }
}

enum LoginViewClickTypeEnum {
    case register
    case forgotPassword
    case privacy
}
