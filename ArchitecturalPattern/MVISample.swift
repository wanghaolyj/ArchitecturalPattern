//
//  MVISample.swift
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

class MVISample {
    // MARK: Model
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
    
    // MARK: state
    struct LoginState {
        var username: String = ""
        var password: String = ""
        var isLoading: Bool = false
        var errorMessage: String?
        var isLoginSuccessful: Bool = false
    }
    
    // MARK: Intent
    enum LoginIntent {
        case updateUsername(String)
        case updatePassword(String)
        case login
    }
    
    // MARK: ViewModel
    class LoginViewModel {
        
        private let bag = DisposeBag()
        
        private let userApi = UserAPI()
        
        // Input: 接受 View 的意图
        let intent = PublishRelay<LoginIntent>()
        
        // Output: 暴露给 View 的状态
        private let stateRelay = BehaviorRelay<LoginState>(value: LoginState())
        var state: Observable<LoginState> { stateRelay.asObservable() }
        
        private let disposeBag = DisposeBag()
        
        init() {
            intent.subscribe(onNext: { [weak self] intent in
                        guard let self = self else { return }
                        var newState = self.stateRelay.value
                        switch intent {
                        case .updateUsername(let username):
                            newState.username = username
                        case .updatePassword(let password):
                            newState.password = password
                        case .login:
                            self.login(currentState: newState)
                            return
                        }
                        self.stateRelay.accept(newState)
                    }).disposed(by: disposeBag)
        }
        
        func login(currentState: LoginState) {
            
            var newState = currentState
            
            guard !newState.username.isEmpty else {
                newState.errorMessage = "请输入用户名"
                stateRelay.accept(newState)
                return
            }
            
            guard !newState.password.isEmpty else {
                newState.errorMessage = "请输入密码"
                stateRelay.accept(newState)
                return
            }
            
            newState.isLoading = true
            stateRelay.accept(newState)
            
            // 模拟网络请求
            let resultState = currentState
            userApi.login(userName: currentState.username, password: currentState.password) { [weak self]  info, error in
                var state = resultState
                if error == nil {
                    
                    state.isLoading = false
                    state.isLoginSuccessful = true
                    
                } else {
                    state.isLoading = false
                    state.errorMessage = "登录失败"
                }
                self?.stateRelay.accept(state)
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
            self.title = "MVI"
            self.view.backgroundColor = .systemBackground
            
            self.view.addSubview(userNameTextField)
            userNameTextField.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(100)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            userNameTextField.rx.text.orEmpty
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance).map { LoginIntent.updateUsername($0)}.bind(to: viewModel.intent)
                .disposed(by: bag)
            
            self.view.addSubview(passwordTextField)
            passwordTextField.snp.makeConstraints { make in
                make.top.equalTo(userNameTextField.snp.bottom).offset(30)
                make.left.right.equalToSuperview().inset(50)
                make.height.equalTo(44)
            }
            passwordTextField.rx.text.orEmpty
                .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
                .map { LoginIntent.updatePassword($0) }
                .bind(to: viewModel.intent)
                .disposed(by: bag)
            
            let loginButton = UIButton(type: .system).then {
                $0.setTitle("登录", for: .normal)
            }
            loginButton.rx.tap
                .throttle(RxTimeInterval.milliseconds(300), scheduler: MainScheduler.instance)
                .map {LoginIntent.login}
                .bind(to: viewModel.intent)
                .disposed(by: bag)
            self.view.addSubview(loginButton)
            loginButton.snp.makeConstraints { make in
                make.top.equalTo(passwordTextField.snp.bottom).offset(16)
                make.left.right.equalToSuperview().inset(80)
                make.height.equalTo(44)
            }
            
            viewModel.state.observe(on: MainScheduler.instance)
                .subscribe(onNext:{ [weak self] state in
                    self?.updateUI(state)
                })
                .disposed(by: bag)
        }
        
        private func updateUI(_ state:LoginState) {
            // 更新UI
            if let msg = state.errorMessage, !msg.isEmpty {
                self.view.makeToast(msg)
            }
            
            if state.isLoading {
                SVProgressHUD.show()
            } else {
                SVProgressHUD.dismiss()
            }
            
            if state.isLoginSuccessful {
                self.view.makeToast("登录成功")
            }
        }
    }
}
