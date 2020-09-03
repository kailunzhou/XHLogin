import UIKit

class ForgotPasswordMobileCtrl: CTBaseCtrl {
    private var mainView = ForgotPasswordMobileView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        title = "忘记密码"
        navigationItem.leftBarButtonItem = CTBackBtn
        
        mainView = ForgotPasswordMobileView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] (mobile) in
            self?.sendSmscode(mobile)
        }
    }
    
    private func sendSmscode(_ mobile: String) {
        LoginConfig.share.sendSmscode(mobile, .forgotPassword) { [weak self] in
            let vCtrl = ForgotPasswordSmscodeCtrl()
            vCtrl.mobileStr = mobile
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class ForgotPasswordMobileView: UIView {
    private var mobileTF = XHTextField(frame: .zero)
    public var clickAction: ((_ mobile: String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: "账号", attributes: [.foregroundColor: UIColor(hexString: "333333"), .font: UIFont.systemFont(ofSize: 17)])
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(24)
            make.width.equalTo(40)
        }
        
        mobileTF.placeholder = "请输入绑定账号的手机号码"
        mobileTF.keyboardType = .numberPad
        mobileTF.delegate = self
        addSubview(mobileTF)
        mobileTF.snp.makeConstraints { (make) in
            make.left.equalTo(titleLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-24)
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.height.equalTo(30)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "E2E2E2")
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(13)
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
        guard let mobile = mobileTF.text, mobile.count == 11 else {
            MBProgressHUD.showMessage(nil, with: "请输入11位手机号", complete: nil)
            return
        }
        clickAction?(mobile)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ForgotPasswordMobileView: UITextFieldDelegate {
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
        return true
    }
}
