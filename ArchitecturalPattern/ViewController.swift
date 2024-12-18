//
//  ViewController.swift
//  ArchitecturalPattern
//
//  Created by 王浩 on 2024/12/18.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private let viewList = [ViewType.mvc, .mvvm, .mvi, .mvp, .viper]
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "架构模式"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        cell.textLabel?.text = viewList[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewList[indexPath.row] {
        case .mvc:
            self.navigationController?.pushViewController(LoginViewController(), animated: true)
        case .mvvm:
            break
        case .mvi:
            break
        case .mvp:
            break
        case .viper:
            break
        }
    }
    
    
}

enum ViewType {
    case mvc
    case mvvm
    case mvi
    case mvp
    case viper
    
    var name: String {
        switch self {
        case .mvc:
            return "MVC"
        case .mvvm:
            return "MVVM"
        case .mvi:
            return "MVI"
        case .mvp:
            return "MVP"
        case .viper:
            return "Viper"
        }
    }

}

