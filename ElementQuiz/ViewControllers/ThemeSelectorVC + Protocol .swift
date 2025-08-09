//
//  MenuButtonVC + Protocol.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.04.2024.
//
import UIKit
import SnapKit

//MARK: - ThemeSelectorViewController
final class ThemeSelectorViewController: UIViewController {
    private let themes: [Theme] = Theme.allCases
    private var locallySelectedTheme: Theme?
    private lazy var checkboxView = ExclusiveCheckboxView()
    private lazy var exampleView: ThemeExampleView = {
        var view = ThemeExampleView()
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: CellThemeName.reusableIdentifier)
        tableView.backgroundColor = CustomColors.generalAppFont
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init() {        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Lifecycle methods
    override func viewDidLoad() {
        setupNavBar()
        setup()
        addSubViews()
        layout()
        
        exampleView.onInfoTap = { [weak self] in
            guard let self = self, let theme = self.locallySelectedTheme else { return }
            self.saveInfo(theme)
        }
    }
    
    func setupNavBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.barTintColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.generalTextColor]
        backButton.tintColor = CustomColors.generalTextColor
        navigationItem.title = "Customize 🎨"
    }
    
    private func addSubViews() {
        view.addSubview(checkboxView)
        view.addSubview(exampleView)
        view.addSubview(tableView)
    }
    
    private func layout() {
        checkboxView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        exampleView.snp.makeConstraints { make in
            make.top.equalTo(checkboxView.snp.bottom).offset(10)
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.width).offset(-32)
            make.height.equalTo(exampleView.snp.width) // квадрат
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(exampleView.snp.bottom).offset(10)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func setup() {
        view.backgroundColor = CustomColors.generalAppFont
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func saveInfo(_ theme: Theme) {
        CustomColors.setTheme(theme)
    }

    @objc func backAction() {
        self.dismiss(animated: true)
    }
    
    @objc func bigButtonAction() {
        guard let locallySelectedTheme = locallySelectedTheme else { return }
        CustomColors.setTheme(locallySelectedTheme)
    }
}

// MARK: - Delegates
extension ThemeSelectorViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CellThemeName(style: .default, reuseIdentifier: CellThemeName.reusableIdentifier)
        cell.configure(theme: themes[indexPath.row])
        let view: UIView = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = CustomColors.secondaryTextColor
        cell.selectedBackgroundView = view
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameter = themes[indexPath.row]
        locallySelectedTheme = parameter

        let text = CustomColors.getCurrentTheme() == locallySelectedTheme ? "This is your current theme:" : "Set a new theme?"
        exampleView.configure(firstLable: text, themeName: parameter.rawValue)
    }
}

//MARK: - cell for parameter table view menu controller
final private class CellThemeName: UITableViewCell {
    private let parentView: UIView = UIView()
    private let infoLabel: UILabel = UILabel()
    static let reusableIdentifier = "CellThemeName"
    
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
        parentView.layer.cornerRadius = 4
        parentView.backgroundColor = CustomColors.backgroundForCell
    }
    
    private func addSubViews() {
        addSubview(parentView)
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
    
    func configure(theme: Theme) {
        infoLabel.text = theme.rawValue
    }
}

final private class ThemeExampleView: UIView {
    private let parentView: UIView = UIView()
    private let infoLabelOne: UILabel = UILabel()
    private let infoLabelTwo: UILabel = UILabel()
    private let imageView: UIImageView = UIImageView()
    private let infoButton: UIButton = UIButton()
    var onInfoTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addSubViews()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        infoLabelOne.font = UIFont(name: "Hoefler Text", size: 30)
        infoLabelOne.minimumScaleFactor = 0.35
        infoLabelOne.adjustsFontSizeToFitWidth = true
        infoLabelOne.textAlignment = .center
        infoLabelOne.textColor = CustomColors.secondaryTextColor
        infoLabelOne.numberOfLines = 2
        infoLabelOne.text = "This is your current theme:"
        
        infoLabelTwo.font = UIFont(name: "Avenir", size: 25)
        infoLabelTwo.minimumScaleFactor = 0.35
        infoLabelTwo.adjustsFontSizeToFitWidth = true
        infoLabelTwo.textAlignment = .justified
        infoLabelTwo.textColor = CustomColors.generalTextColor
        infoLabelTwo.backgroundColor = CustomColors.backgroundForCell
        infoLabelTwo.numberOfLines = 1
        infoLabelTwo.layer.masksToBounds = true
        infoLabelTwo.layer.cornerRadius = 10
        infoLabelTwo.text = "  " + CustomColors.getCurrentTheme().rawValue + "  "
        
        imageView.image = UIImage(named: "roman_painter")?.withRoundedCorners(inPercentageFromBiggestSide: 0.15)
        imageView.contentMode = .scaleAspectFit
        
        infoButton.setTitle("Apply", for: .normal)
        infoButton.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        infoButton.backgroundColor = CustomColors.bigButtonColor
        infoButton.setTitleColor(.white, for: .normal)
        infoButton.layer.cornerRadius = 15
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)

        parentView.layer.cornerRadius = 4
        parentView.layer.borderWidth = 2
        parentView.layer.borderColor = CustomColors.softAppColor.cgColor
        parentView.backgroundColor = CustomColors.generalAppFont
    }
    
    private func addSubViews() {
        addSubview(parentView)
        parentView.addSubview(infoLabelOne)
        parentView.addSubview(infoLabelTwo)
        parentView.addSubview(imageView)
        parentView.addSubview(infoButton)
    }
    
    private func layout() {
        parentView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        infoLabelOne.snp.makeConstraints { make in
            make.leading.trailing.greaterThanOrEqualToSuperview().offset(10)
            make.height.equalTo(35)
            make.top.equalTo(parentView.snp.top).offset(5)
            make.centerX.equalToSuperview()
        }
        
        infoLabelTwo.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalTo(infoLabelOne.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
                
        infoButton.snp.makeConstraints { make in
            make.bottom.lessThanOrEqualTo(parentView.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(infoLabelTwo.snp.bottom).offset(10)
            make.bottom.equalTo(infoButton.snp.top).offset(-1)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    func configure(firstLable: String, themeName: String) {
        infoLabelOne.text = firstLable
        infoLabelTwo.text = "  " + themeName + "  "
        infoLabelOne.textColor = CustomColors.secondaryTextColor
        infoLabelTwo.textColor = CustomColors.generalTextColor
        infoLabelTwo.backgroundColor = CustomColors.backgroundForCell
        infoButton.backgroundColor = CustomColors.bigButtonColor
        parentView.layer.borderColor = CustomColors.softAppColor.cgColor
        parentView.backgroundColor = CustomColors.generalAppFont
    }
    
    @objc private func infoTapped() {
        onInfoTap?()
    }
}

final class ExclusiveCheckboxView: UIView {
    private let label = UILabel()
    private let squareBox = UIButton(type: .custom)
    private let roundBox = UIButton(type: .custom)
    private var selected: SelectionBoxType = UserSelectionStyle.currentType

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        addViews()
        layout()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        label.text = "Choose an option:"
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 1
        label.font = UIFont(name: "Hoefler Text", size: 30)
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        
        squareBox.setTitle("", for: .normal)
        squareBox.addTarget(self, action: #selector(squareTapped), for: .touchUpInside)
        squareBox.imageView?.tintColor = CustomColors.secondaryTextColor

        roundBox.setTitle("", for: .normal)
        roundBox.addTarget(self, action: #selector(roundTapped), for: .touchUpInside)
        roundBox.imageView?.tintColor = CustomColors.secondaryTextColor
        
        choseIconForButton(selected)
    }

    private func addViews() {
        addSubview(label)
        addSubview(squareBox)
        addSubview(roundBox)
    }

    private func layout() {
        label.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        squareBox.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(15)
            make.centerX.equalToSuperview().offset(50)
            make.width.equalTo(45)
            make.height.equalTo(45)
            make.bottom.equalToSuperview()
        }
        
        squareBox.imageView?.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.height.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
        }
        
        roundBox.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(15)
            make.centerX.equalToSuperview().offset(-50)
            make.width.equalTo(45)
            make.height.equalTo(45)
            make.bottom.equalToSuperview()
        }
        
        roundBox.imageView?.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-15)
            make.height.equalToSuperview().offset(-15)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-5)
        }
    }
    
    private func choseIconForButton(_ forType: SelectionBoxType) {
        if forType == .square {
            squareBox.setImage(UIImage(systemName: "square.dashed.inset.filled") ?? UIImage(), for: .normal)
            roundBox.setImage(UIImage(systemName: "circle.dashed") ?? UIImage(), for: .normal)
        } else {
            roundBox.setImage(UIImage(systemName: "circle.dashed.inset.filled") ?? UIImage(), for: .normal)
            squareBox.setImage(UIImage(systemName: "square.dashed") ?? UIImage(), for: .normal)
        }
    }
    
    @objc private func squareTapped() {
        selected = .square
        UserSelectionStyle.setStyle(selected)
        choseIconForButton(.square)
    }

    @objc private func roundTapped() {
        selected = .round
        UserSelectionStyle.setStyle(selected)
        choseIconForButton(.round)
    }
}
