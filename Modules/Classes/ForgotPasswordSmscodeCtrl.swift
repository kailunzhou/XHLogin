import UIKit

class ForgotPasswordSmscodeCtrl: CTBaseCtrl {
    private var mainView = ForgotPasswordSmscodeView()
    public var mobileStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        mainView.smscodeCoolDown()
    }
    
    private func buildUI() {
        title = "忘记密码"
        navigationItem.leftBarButtonItem = CTBackBtn
        mainView = ForgotPasswordSmscodeView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.setMobile(mobileStr)
        mainView.smscodeAction = { [weak self] in
            self?.sendSmscode()
        }
        mainView.clickAction = { [weak self] (smscode) in
            self?.checkSmscode(smscode)
        }
    }
    
    private func sendSmscode() {
        LoginConfig.share.sendSmscode(mobileStr, .forgotPassword) { [weak self] in
            self?.mainView.smscodeCoolDown()
        }
    }
    
    private func checkSmscode(_ smscode: String) {
        LoginConfig.share.checkSmscode(mobileStr, smscode, .forgotPassword) { [weak self] in
            let vCtrl = ForgotPasswordSetCtrl()
            vCtrl.mobileStr = self!.mobileStr
            vCtrl.smscodeStr = smscode
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class ForgotPasswordSmscodeView: UIView {
    private var mobileLabel = UILabel()
    private var smscodeTF = XHTextField(frame: .zero)
    private var smscodeBtn = UIButton()
    private var nextBtn = UIButton()
    
    public var smscodeAction: (()->())?
    public var clickAction: ((_ smscode: String)->())?
    
    ///界面显示手机号码
    public func setMobile(_ mobile: String) {
        mobileLabel.text = mobile
    }
    ///验证码获取按钮进入冷却
    public func smscodeCoolDown() {
        smscodeBtn.startTime(withDuration: 60)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: "验证码将发送到绑定手机号", attributes: [.foregroundColor: UIColor(hexString: "333333"), .font: UIFont.systemFont(ofSize: 16)])
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }
        
        mobileLabel.font = UIFont.systemFont(ofSize: 16)
        mobileLabel.textColor = UIColor(hexString: "333333")
        addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalTo(22)
        }
        
        smscodeBtn.layer.cornerRadius = 17
        smscodeBtn.clipsToBounds = true
        smscodeBtn.backgroundColor = UIColor(hexString: "FFEDE3")
        smscodeBtn.setTitle("获取验证码", for: .normal)
        smscodeBtn.setTitleColor(UIColor(hexString: "FF6E23"), for: .normal)
        smscodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        smscodeBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(smscodeBtn)
        smscodeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(mobileLabel.snp.bottom).offset(48)
            make.right.equalToSuperview().offset(-24)
            make.width.equalTo(114)
            make.height.equalTo(34)
        }
        
        smscodeTF.placeholder = "请输入短信验证码"
        smscodeTF.keyboardType = .numberPad
        smscodeTF.delegate = self
        addSubview(smscodeTF)
        smscodeTF.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.right.equalTo(smscodeBtn.snp.left).offset(-16)
            make.centerY.equalTo(smscodeBtn.snp.centerY)
            make.height.equalTo(30)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "E2E2E2")
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(smscodeBtn.snp.bottom).offset(7)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
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
        switch sender {
        case smscodeBtn:
            smscodeAction?()
        case nextBtn:
            guard let smscode = smscodeTF.text, smscode.count == 6 else {
                MBProgressHUD.showMessage(nil, with: "请输入6位短信验证码", complete: nil)
                return
            }
            clickAction?(smscode)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ForgotPasswordSmscodeView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == smscodeTF {
            let str = (textField.text ?? "") + string
            if str.count > 6 {
                textField.text = (textField.text ?? "").substring(to: 6)
                return false
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
