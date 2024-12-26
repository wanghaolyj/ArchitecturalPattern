//
//  MVVMSample.swift
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

class MVVMSample {
    class UserAPI {
        func login(userName:String, password:String, completion: @escaping (UserInfo, Error?) -> Void) {
            // 模拟网络请求
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                DispatchQueue.main.async{
                    completion(UserInfo(name: userName, avatar: "avatar"), nil)
                }
            }
        }
    }
    
    struct UserInfo {
        let name:String
        let avatar:String
    }
    
    class LoginViewModel {
        
        private let bag = DisposeBag()
        
        private let userApi = UserAPI()
        
        let userNameBehavior = BehaviorRelay<String>(value: "")
        let passwordBehavior = BehaviorRelay<String>(value: "")
        let toastSubject = PublishSubject<String>()
        let loginSuccess = PublishSubject<Void>()
        
        func login() {
            
            guard !userNameBehavior.value.isEmpty else {
                toastSubject.onNext("请输入用户名")
                return
            }
            
            guard !passwordBehavior.value.isEmpty else {
                toastSubject.onNext("请输入密码")
                return
            }
            
            userApi.login(userName: userNameBehavior.value, password: passwordBehavior.value) { [weak self]  info, error in
                if error == nil {
                    self?.loginSuccess.onNext(())
                } else {
                    self?.toastSubject.onNext(error!.localizedDescription)
                }
            }
        }
    }
    
    class LoginViewController: UIViewController {

        private let bag = DisposeBag()
        
        private let viewModel = LoginViewModel()
        
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
            self.title = "MVVM"
            self.view.backgroundColor = .systemBackground
            
            self.view.addSubview(userNameTextField)
            userNameTextField.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(100)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            userNameTextField.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).bind(to: viewModel.userNameBehavior).disposed(by: bag)
            
            self.view.addSubview(passwordTextField)
            passwordTextField.snp.makeConstraints { make in
                make.top.equalTo(userNameTextField.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            passwordTextField.rx.text.orEmpty.throttle(.milliseconds(300), scheduler: MainScheduler.instance).bind(to: viewModel.passwordBehavior).disposed(by: bag)
            
            let loginButton = UIButton(type: .system).then {
                $0.setTitle("登录", for: .normal)
            }
            loginButton.rx.tap.throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance).subscribe(onNext:{ [weak self] in
                self?.viewModel.login()
            }).disposed(by: bag)
            self.view.addSubview(loginButton)
            loginButton.snp.makeConstraints { make in
                make.top.equalTo(passwordTextField.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(80)
                make.height.equalTo(44)
            }
            
            
            viewModel.loginSuccess.subscribe(onNext:{ [weak self] in
                // 成功回调
            }).disposed(by: bag)
            
            viewModel.toastSubject.observe(on: MainScheduler.instance).subscribe(onNext:{ [weak self] message in
                self?.view.makeToast(message)
            }).disposed(by: bag)
        }
        
    }
}
