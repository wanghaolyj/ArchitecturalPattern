//
//  MVPSample.swift
//  ArchitecturalPattern
//
//  Created by 王浩 on 2024/12/19.
//

import UIKit
import SnapKit
import Then
import Foundation
import Toast_Swift
import SVProgressHUD

class MVPSample {
    
    struct UserInfo {
        let name:String
        let avatar:String
    }
    
    protocol userService {
        func login(userName:String, password:String, completion: @escaping (UserInfo) -> Void, fail: @escaping (String) -> Void)
    }
    
    class UserAPI: userService {
        func login(userName:String, password:String, completion: @escaping (UserInfo) -> Void, fail: @escaping (String) -> Void) {
            // 模拟网络请求
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async{
                    completion(UserInfo(name: userName, avatar: "avatar"))
                }
            }
        }
    }
    
    // View：视图层，界面与用户交互
    protocol LoginView: AnyObject {
        func showLoading()
        func hideLoading()
        func showError(message: String)
        func navigateToHome()
    }
    
    class LoginViewController: UIViewController, LoginView {
        
        private var presenter:LoginPresenter!
        
        func showLoading() {
            SVProgressHUD.show()
        }
        
        func hideLoading() {
            SVProgressHUD.dismiss()
        }
        
        func showError(message: String) {
            self.view.makeToast(message)
        }
        
        func navigateToHome() {
            
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
            self.title = "MVP"
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
        
            
            presenter = LoginPresenterImpl(view: self, userService: UserAPI())
        }
        
        @objc func login(_ sender: UIButton) {
            presenter.login(username: userNameTextField.text ?? "", password: passwordTextField.text ?? "")
        }
    }
    
    protocol LoginPresenter {
        func login(username: String, password: String)
    }
    
    class LoginPresenterImpl: LoginPresenter {
        private let userService: userService
        private weak var view: LoginView?
        
        init(view: LoginView, userService: userService) {
            self.view = view
            self.userService = userService
        }
        
        func login(username: String, password: String) {
            
            guard !username.isEmpty else {

                view?.showError(message: "请输入用户名")
                return
            }
            
            guard !password.isEmpty else {
                view?.showError(message: "请输入密码")
                return
            }
            
            view?.showLoading()
            userService.login(userName: username, password: password) { [weak self] result in
                self?.view?.hideLoading()
                self?.view?.navigateToHome()
            
            } fail: { [weak self] message in
                self?.view?.hideLoading()
                self?.view?.showError(message: message)
            }
        }
    }
}
