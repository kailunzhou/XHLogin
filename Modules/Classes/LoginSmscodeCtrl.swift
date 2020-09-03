import UIKit

class LoginSmscodeCtrl: CTBaseCtrl {
    private var mainView = LoginSmscodeView()
    public var mobileStr = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        mainView.smscodeCoolDown()
    }
    
    private func buildUI() {
        navigationItem.leftBarButtonItem = CTBackBtn
        mainView = LoginSmscodeView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.setMobile(mobileStr)
        mainView.loginAction = { [weak self] (smscode) in
            LoginConfig.share.smscodeLogin(self!.mobileStr, smscode)
        }
        mainView.clickAction = { [weak self] (type) in
            switch type {
            case .smscode:
                self?.sendSmscode()
            case .privacy:
                self?.skipH5()
            }
        }
    }
    
    private func sendSmscode() {
        LoginConfig.share.sendSmscode(mobileStr, .login) { [weak self] in
            self?.mainView.smscodeCoolDown()
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

class LoginSmscodeView: UIView {
    private var mobileLabel = UILabel()
    private var privacyBtn = UIButton()
    private var vcodeView = CTVCodeView(count: 6, margin: 15)
    private var vcodeBtn = UIButton()
    public var loginAction: ((_ smscode: String)->())?
    public var clickAction: ((_ type: LoginSmscodeViewClickTypeEnum)->())?
    
    ///界面显示手机号码
    public func setMobile(_ mobile: String) {
        mobileLabel.text = mobile
    }
    ///验证码获取按钮进入冷却
    public func smscodeCoolDown() {
        vcodeBtn.startTime(withDuration: 60)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(string: "输入短信验证码", attributes: [.foregroundColor: UIColor(hexString: "333333"), .font: UIFont.systemFont(ofSize: 25, weight: .medium)])
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(32)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(36)
        }
        
        let detailLabel = UILabel()
        detailLabel.attributedText = NSAttributedString(string: "验证码已发送至", attributes: [.foregroundColor: UIColor(hexString: "9E9E9E"), .font: UIFont.systemFont(ofSize: 15)])
        addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(24)
            make.height.equalTo(21)
        }
        
        mobileLabel.font = UIFont.systemFont(ofSize: 15)
        mobileLabel.textColor = UIColor(hexString: "FF6E23")
        addSubview(mobileLabel)
        mobileLabel.snp.makeConstraints { (make) in
            make.left.equalTo(detailLabel.snp.right)
            make.centerY.equalTo(detailLabel.snp.centerY)
            make.height.equalTo(21)
        }
        
        vcodeView.numberColor = UIColor(hexString: "333333")
        vcodeView.lineColor = UIColor(hexString: "E2E2E2")
        vcodeView.selectLineColor = UIColor(hexString: "FF6E23")
        addSubview(vcodeView)
        vcodeView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(24)
            make.top.equalTo(detailLabel.snp.bottom).offset(80)
            make.height.equalTo(64)
        }
        vcodeView.inputFinishAction = { [weak self] (inputCode) in
            self?.loginAction?(inputCode)
        }
        
        vcodeBtn.setTitle("重新获取", for: .normal)
        vcodeBtn.setTitleColor(UIColor(hexString: "0073FF"), for: .normal)
        vcodeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        vcodeBtn.contentHorizontalAlignment = .left
        vcodeBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(vcodeBtn)
        vcodeBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(24)
            make.top.equalTo(vcodeView.snp.bottom).offset(24)
            make.width.equalTo(80)
            make.height.equalTo(30)
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
        case vcodeBtn:
            clickAction?(.smscode)
        case privacyBtn:
            clickAction?(.privacy)
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum LoginSmscodeViewClickTypeEnum {
    case smscode
    case privacy
}
