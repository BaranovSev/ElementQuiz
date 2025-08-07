//
//  MenuButtonVC + Protocol.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.04.2024.
//
import UIKit
import SnapKit

//MARK: - ParametersButtonDelegate
protocol ParametersButtonDelegate: AnyObject {
    func didChangeParameter(parameter: ElementParameters)
}

//MARK: - ParametersButtonViewController
final class ParametersButtonViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private let parameters: [String]
    private let delegate: ParametersButtonDelegate
    private lazy var label: UILabel = {
        var label = UILabel()
        label.font = UIFont(name: "Impact", size: 40)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = CustomColors.generalTextColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellWithLabel.reusableIdentifier)
        tableView.backgroundColor = CustomColors.generalAppFont
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(delegate: ParametersButtonDelegate, parameters: [String]) {
        self.delegate = delegate
        self.parameters = parameters
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        setup()
        addSubViews()
        layout()
    }
    
    private func addSubViews() {
        view.addSubview(label)
        view.addSubview(tableView)
    }
    
    private func layout() {
        label.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).offset(15)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-15)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(10)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setup() {
        view.backgroundColor = CustomColors.generalAppFont
        
        tableView.delegate = self
        tableView.dataSource = self
        
        label.text = "Select parameter to show:"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parameters.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellWithLabel(style: .default, reuseIdentifier: CellWithLabel.reusableIdentifier)
        if let parameter = ElementParameters(rawValue: parameters[indexPath.row])?.descriptionHumanReadable() {
            cell.configure(info: parameter)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameter = parameters[indexPath.row]
        delegate.didChangeParameter(parameter: ElementParameters(rawValue: parameter) ?? .category)
//        delegate.userSelectedOptionalParameter = ElementParameters(rawValue: parameter) ?? .category
        self.dismiss(animated: true)
    }
}

//MARK: - cell for parameter table view menu controller
final private class CellWithLabel: UITableViewCell {
    private let parentView: UIView = UIView()
    private let infoLabel: UILabel = UILabel()
    static let reusableIdentifier = "CellWithLabel"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        infoLabel.font = UIFont(name: "Avenir", size: 25)
        infoLabel.minimumScaleFactor = 0.35
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.textAlignment = .justified
        infoLabel.textColor = CustomColors.generalTextColor
        infoLabel.numberOfLines = 2
        backgroundColor = CustomColors.generalAppFont
//        parentView.layer.borderWidth = 2
        parentView.layer.cornerRadius = 4
        parentView.backgroundColor = CustomColors.backgroundForCell
//        parentView.layer.borderColor = CustomColors.generalTextColor.cgColor
    }
    
    private func addSubViews() {
        contentView.addSubview(parentView)
        parentView.addSubview(infoLabel)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-10)
        }
        
        infoLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(info: String) {
        infoLabel.text = info
    }
}
