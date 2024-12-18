//
//  UserAPI.swift
//  ArchitecturalPattern
//
//  Created by 王浩 on 2024/12/18.
//
import Foundation

class UserAPI {
    func login(userName:String, password:String, completion: @escaping (UserInfo, Error?) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            completion(UserInfo(), nil)
        }
    }
}
