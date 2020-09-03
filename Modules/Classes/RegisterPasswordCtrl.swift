import UIKit

class RegisterPasswordCtrl: CTBaseCtrl {
    private var mainView = RegisterPasswordView()
    public var mobileStr = ""
    public var usernameStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        title = "快速注册"
        navigationItem.leftBarButtonItem = CTBackBtn
        
        mainView = RegisterPasswordView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] (password) in
            self?.registerAccount(password)
        }
    }
    
    private func registerAccount(_ password: String) {
        LoginConfig.share.registerAccount(mobileStr, usernameStr, password) { [weak self] in
            let vCtrl = CompleteShowCtrl()
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class RegisterPasswordView: UIView {
    private var passwordTF = XHTextField(frame: .zero)
    private var showBtn = UIButton()
    private var nextBtn = UIButton()
    
    public var clickAction: ((_ password: String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: "请设置登录密码", attributes: [.foregroundColor: UIColor(hexString: "353535"), .font: UIFont.systemFont(ofSize: 16)])
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(21)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(22)
        }
        
        showBtn.setImage(UIImage(named: "login_closeeye", RegisterPasswordView.self), for: .normal)
        showBtn.setImage(UIImage(named: "login_openeye", RegisterPasswordView.self), for: .selected)
        showBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(showBtn)
        showBtn.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.right.equalToSuperview().offset(-24)
            make.width.height.equalTo(24)
        }
        
        passwordTF.isSecureTextEntry = true
        passwordTF.placeholder = "请输入登录密码"
        passwordTF.delegate = self
        addSubview(passwordTF)
        passwordTF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(showBtn.snp.left).offset(-16)
            make.centerY.equalTo(showBtn.snp.centerY)
            make.height.equalTo(30)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "E2E2E2")
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(passwordTF.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
        let tipLabel = UILabel()
        tipLabel.numberOfLines = 0
        tipLabel.attributedText = NSAttributedString(string: "备注：请将密码设置为6-20位，并且由字母、数字两种以上组合。", attributes: [.foregroundColor: UIColor(hexString: "9E9E9E"), .font: UIFont.systemFont(ofSize: 13)])
        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(24)
        }
        
        nextBtn.layer.cornerRadius = 24
        nextBtn.clipsToBounds = true
        nextBtn.backgroundColor = UIColor(hexString: "FF6E23")
        nextBtn.setTitle("完成", for: .normal)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nextBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
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
            guard let password = passwordTF.text, password.count > 0 else {
                MBProgressHUD.showMessage(nil, with: "请输入登录密码", complete: nil)
                break
            }
            if !password.regularPassword() {
                MBProgressHUD.showMessage(nil, with: "请输入符合条件的登录密码", complete: nil)
                break
            }
            clickAction?(password)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RegisterPasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
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
