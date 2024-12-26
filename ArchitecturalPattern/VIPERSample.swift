//
//  VIPERSample.swift
//  ArchitecturalPattern
//
//  Created by 王浩 on 2024/12/19.
//
import Foundation
import SnapKit
import UIKit
import Then
import RxSwift
import RxCocoa
import Toast_Swift
import SVProgressHUD

class VIPERSample {
    
    struct UserInfo {
        let name:String
        let avatar:String
    }
    
    // Interactor 处理与登录相关的业务逻辑，比如验证用户凭据并与后端交互。
    protocol LoginInteractorProtocol {
        func login(username: String, password: String)
    }
    
    class LoginInteractor: LoginInteractorProtocol {
        var presenter: LoginPresenterProtocol?
        
        func login(username: String, password: String) {
            guard !username.isEmpty else {
                presenter?.loginDidFail(error: "请输入用户名")
                return
            }
            
            guard !password.isEmpty else {
                presenter?.loginDidFail(error: "请输入秘密")
                return
            }
            // 模拟网络请求
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                if username == "admin" && password == "1234" {
                    // 登录成功，返回用户数据
                    let user = UserInfo(name: username, avatar: "avatar")
                    self.presenter?.loginDidSucceed(user: user)
                } else {
                    // 登录失败
                    self.presenter?.loginDidFail(error: "Invalid username or password")
                }
            }
        }
    }
    
    // Presenter 负责处理从 Interactor 返回的数据，并通知 View 更新。
    protocol LoginPresenterProtocol {
        func login(username: String, password: String)
        func loginDidSucceed(user: UserInfo)
        func loginDidFail(error: String)
    }
    
    class LoginPresenter: LoginPresenterProtocol {
        var view: LoginViewProtocol?
        var interactor: LoginInteractorProtocol?
        var router: LoginRouterProtocol?
        
        func login(username: String, password: String) {
            view?.showLoading()
            interactor?.login(username: username, password: password)
        }
        
        func loginDidSucceed(user: UserInfo) {
            view?.hideLoading()
            router?.navigateToHome(user: user)
        }
        
        func loginDidFail(error: String) {
            view?.hideLoading()
            view?.showError(message: error)
        }
    }
    
    // View 负责显示 UI 和响应用户交互。
    protocol LoginViewProtocol {
        func showLoading()
        func hideLoading()
        func showError(message: String)
    }
    
    class LoginViewController: UIViewController, LoginViewProtocol {
        
        var presenter: LoginPresenterProtocol?
        
        func showLoading() {
            print("Loading...")
            SVProgressHUD.show()
        }
        
        func hideLoading() {
            print("Loading finished.")
            SVProgressHUD.dismiss()
        }
        
        func showError(message: String) {
            print("Error: \(message)")
            self.view.makeToast(message)
        }
        
        private let userNameTextField = UITextField().then {
            $0.borderStyle = .roundedRect
            $0.placeholder = "请输入用户名"
        }
        
        private let passwordTextField = UITextField().then {
            $0.borderStyle = .roundedRect
            $0.placeholder = "请输入密码"
            $0.isSecureTextEntry = true
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Do any additional setup after loading the view.
            self.title = "VIPER"
            self.view.backgroundColor = .systemBackground
            
            self.view.addSubview(userNameTextField)
            userNameTextField.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(100)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            
            self.view.addSubview(passwordTextField)
            passwordTextField.snp.makeConstraints { make in
                make.top.equalTo(userNameTextField.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            
            let loginButton = UIButton(type: .system).then {
                $0.setTitle("登录", for: .normal)
            }
            self.view.addSubview(loginButton)
            loginButton.snp.makeConstraints { make in
                make.top.equalTo(passwordTextField.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(80)
                make.height.equalTo(44)
            }
            
            loginButton.addTarget(self, action: #selector(login(_:)), for: .touchUpInside)
            
        }
        
        @objc func login(_ sender: UIButton) {
            presenter?.login(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    // Router 处理界面导航。
    protocol LoginRouterProtocol {
        func navigateToHome(user: UserInfo)
    }

    class LoginRouter: LoginRouterProtocol {
        weak var viewController: UIViewController?
        
        func navigateToHome(user: UserInfo) {
            let homeViewController = UIViewController() // 假设这是首页
            homeViewController.view.backgroundColor = .white
            homeViewController.title = "Welcome, \(user.name)"
            viewController?.navigationController?.pushViewController(homeViewController, animated: true)
        }
    }
    
    // 组装模块 将 VIPER 的各个模块连接起来
    class LoginModule {
        static func createModule() -> UIViewController {
            let view = LoginViewController()
            let presenter = LoginPresenter()
            let interactor = LoginInteractor()
            let router = LoginRouter()
            
            view.presenter = presenter
            presenter.view = view
            presenter.interactor = interactor
            presenter.router = router
            interactor.presenter = presenter
            router.viewController = view
            
            return view
        }
    }

    
}
