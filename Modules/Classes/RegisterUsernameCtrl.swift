import UIKit

class RegisterUsernameCtrl: CTBaseCtrl {
    private var mainView = RegisterUsernameView()
    public var mobileStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        title = "快速注册"
        navigationItem.leftBarButtonItem = CTBackBtn
        
        mainView = RegisterUsernameView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] (username) in
            let vCtrl = RegisterPasswordCtrl()
            vCtrl.mobileStr = self!.mobileStr
            vCtrl.usernameStr = username
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class RegisterUsernameView: UIView {
    private var usernameTF = XHTextField(frame: .zero)
    public var clickAction: ((_ username: String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        usernameTF.placeholder = "请设置您的用户名"
        usernameTF.delegate = self
        addSubview(usernameTF)
        usernameTF.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(90)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(30)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "E2E2E2")
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(usernameTF.snp.bottom)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
        let nextBtn = UIButton()
        nextBtn.layer.cornerRadius = 24
        nextBtn.clipsToBounds = true
        nextBtn.backgroundColor = UIColor(hexString: "FF6E23")
        nextBtn.setTitle("下一步", for: .normal)
        nextBtn.setTitleColor(UIColor.white, for: .normal)
        nextBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        nextBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(nextBtn)
        nextBtn.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    
    @objc private func clickMethod(_ sender: UIButton) {
        guard let username = usernameTF.text, username.count >= 6 else {
            MBProgressHUD.showMessage(nil, with: "请输入6位以上的用户名", complete: nil)
            return
        }
        let reg = "^[a-zA-Z0-9]+$"
        let pre = NSPredicate(format: "SELF MATCHES %@", reg)
        if !pre.evaluate(with: username) {
            MBProgressHUD.showMessage(nil, with: "用户名只能使用数字和字母", complete: nil)
            return
        }
        clickAction?(username)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RegisterUsernameView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
