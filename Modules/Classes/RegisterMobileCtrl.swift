import UIKit

class RegisterMobileCtrl: CTBaseCtrl {
    private var mainView = RegisterMobileView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        title = "快速注册"
        navigationItem.leftBarButtonItem = CTBackBtn
        
        mainView = RegisterMobileView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] (type) in
            switch type {
            case .registerProtocol:
                self?.skipH5("用户注册协议")
            case .privacy:
                self?.skipH5("隐私政策")
            }
        }
        mainView.nextAction = { [weak self] (mobile) in
            self?.sendSmscode(mobile)
        }
    }
    
    private func sendSmscode(_ mobile: String) {
        LoginConfig.share.sendSmscode(mobile, .register) { [weak self] in
            let vCtrl = RegisterSmscodeCtrl()
            vCtrl.mobileStr = mobile
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
    
    private func skipH5(_ key: String) {
        var keyvalue = ""
        if key == "隐私政策" {
            keyvalue = "privacyPolicy"
        } else if key == "用户注册协议" {
            keyvalue = "agreement"
        }
        LoginConfig.share.getH5URL(keyvalue) { [weak self] (url) in
            let vCtrl = CTPureH5Ctrl()
            vCtrl.titletext = key
            vCtrl.geturl = url
            self?.navigationController?.pushViewController(vCtrl, animated: true)
        }
    }
}

class RegisterMobileView: UIView {
    private var mobileTF = XHTextField(frame: .zero)
    private var checkboxBtn = UIButton()
    private var btnTV = UITextView()
    private var nextBtn = UIButton()
    
    public var clickAction: ((_ type: RegisterMobileViewClickTypeEnum)->())?
    public var nextAction: ((_ mobile: String)->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        mobileTF.keyboardType = .numberPad
        mobileTF.placeholder = "请输入手机号码"
        mobileTF.delegate = self
        addSubview(mobileTF)
        mobileTF.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(90)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(30)
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hexString: "E2E2E2")
        addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(mobileTF.snp.bottom)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(1)
        }
        
        checkboxBtn.setImage(UIImage(named: "login_checkbox_unselect", RegisterMobileView.self), for: .normal)
        checkboxBtn.setImage(UIImage(named: "login_checkbox_select", RegisterMobileView.self), for: .selected)
        checkboxBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(checkboxBtn)
        checkboxBtn.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(12)
            make.left.equalToSuperview().offset(24)
            make.width.height.equalTo(30)
        }
        
        btnTV.isEditable = false
        btnTV.bounces = false
        btnTV.isUserInteractionEnabled = true
        btnTV.delegate = self
        let mutableAttributed = NSMutableAttributedString(string: "已阅读并同意", attributes: [.foregroundColor: UIColor(hexString: "333333"), .font: UIFont.systemFont(ofSize: 13)])
        mutableAttributed.append(NSAttributedString(string: "《星和联盟OS用户注册协议》", attributes: [.foregroundColor: UIColor(hexString: "FF6E23"), .font: UIFont.systemFont(ofSize: 13), .link: URL(string: "protocol://") as Any]))
        mutableAttributed.append(NSAttributedString(string: "《星和联盟OS隐私政策》", attributes: [.foregroundColor: UIColor(hexString: "FF6E23"), .font: UIFont.systemFont(ofSize: 13), .link: URL(string: "privacy://") as Any]))
        btnTV.linkTextAttributes = [:]//先设置空才能更改链接颜色
        btnTV.attributedText = mutableAttributed
        addSubview(btnTV)
        btnTV.snp.makeConstraints { (make) in
            make.left.equalTo(checkboxBtn.snp.right).offset(0)
            make.top.equalTo(line.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-24)
            make.height.equalTo(50)
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
            make.top.equalTo(btnTV.snp.bottom).offset(40)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    
    @objc private func clickMethod(_ sender: UIButton) {
        switch sender {
        case checkboxBtn:
            checkboxBtn.isSelected = !checkboxBtn.isSelected
        case nextBtn:
            guard let mobile = mobileTF.text, mobile.count == 11 else {
                MBProgressHUD.showMessage(nil, with: "请输入11位手机号", complete: nil)
                break
            }
            if !checkboxBtn.isSelected {
                MBProgressHUD.showMessage(nil, with: "请阅读用户注册协议和隐私政策并同意", complete: nil)
                break
            }
            nextAction?(mobile)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension RegisterMobileView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "protocol" {
            clickAction?(.registerProtocol)
        } else if URL.scheme == "privacy" {
            clickAction?(.privacy)
        }
        return true
    }
}

extension RegisterMobileView: UITextFieldDelegate {
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

enum RegisterMobileViewClickTypeEnum {
    case registerProtocol
    case privacy
}
