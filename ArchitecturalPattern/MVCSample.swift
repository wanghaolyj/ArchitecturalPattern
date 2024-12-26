//
//  MVCSample.swift
//  ArchitecturalPattern
//
//  Created by 王浩 on 2024/12/19.
//
import UIKit
import SnapKit
import Then
import Foundation
import Toast_Swift

class MVCSample {
    class UserAPI {
        func login(userName:String, password:String, completion: @escaping (UserInfo) -> Void, fail: @escaping (String) -> Void) {
            // 模拟网络请求
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async{
                    completion(UserInfo(name: userName, avatar: "avatar"))
                }
            }
        }
    }
    
    struct UserInfo {
        let name:String
        let avatar:String
    }
    
    class LoginViewController: UIViewController {

        private let userApi = UserAPI()
        
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
            self.title = "MVC"
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
            
            guard let userName = userNameTextField.text, !userName.isEmpty else {
                self.view.makeToast("请输入用户名")
                return
            }
            
            guard let password = passwordTextField.text, !password.isEmpty else {
                self.view.makeToast("请输入密码")
                return
            }
            
            userApi.login(userName: userName, password: password) { [weak self]  userInfo in
                //
            } fail: { [weak self]  msg in
                self?.view.makeToast(msg)
            }
            
        }
    }
}
