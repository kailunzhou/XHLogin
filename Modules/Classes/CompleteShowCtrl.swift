import UIKit

class CompleteShowCtrl: CTBaseCtrl {
    private var mainView = CompleteShowView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
    }
    
    private func buildUI() {
        navigationItem.leftBarButtonItem = CTBackBtn
        mainView = CompleteShowView(frame: view.bounds)
        view.addSubview(mainView)
        mainView.clickAction = { [weak self] in
            self?.CTBackClick(UIButton())
        }
    }
    
    override func CTBackClick(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
}

class CompleteShowView: UIView {
    public var clickAction: (()->())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        let completeImageView = UIImageView()
        completeImageView.image = UIImage(named: "completeshow", CompleteShowView.self)
        addSubview(completeImageView)
        completeImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(120)
            make.width.height.equalTo(60)
        }
        
        let loginBtn = UIButton()
        loginBtn.layer.cornerRadius = 24
        loginBtn.clipsToBounds = true
        loginBtn.backgroundColor = UIColor(hexString: "FF6E23")
        loginBtn.setTitle("登录账号", for: .normal)
        loginBtn.setTitleColor(UIColor.white, for: .normal)
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        loginBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(completeImageView.snp.bottom).offset(80)
            make.left.right.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
    }
    
    @objc private func clickMethod(_ sender: UIButton) {
        clickAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
