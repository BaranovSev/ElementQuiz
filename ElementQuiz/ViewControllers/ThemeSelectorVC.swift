//
//  MenuButtonVC + Protocol.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 10.04.2024.
//
import UIKit
import SnapKit
import Combine


//MARK: - ThemeSelectorViewController
final class ThemeSelectorViewController: UIViewController {
    private var cancellables = Set<AnyCancellable>()
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
        tableView.rowHeight = 45
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
        setupThemeBinding()
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
    private func setupThemeBinding() {
        CustomColors.themePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyTheme()
            }
            .store(in: &cancellables)
    }
    
    private func applyTheme() {
        view.backgroundColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.barTintColor = CustomColors.generalAppFont
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.generalTextColor]
        self.navigationItem.leftBarButtonItem?.tintColor = CustomColors.generalTextColor
        checkboxView.applyTheme()
        tableView.backgroundColor = CustomColors.generalAppFont
        tableView.reloadData()
    }
    
    private func addSubViews() {
        view.addSubview(checkboxView)
        view.addSubview(exampleView)
        view.addSubview(tableView)
    }
    
    private func layout() {
        checkboxView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.height.equalTo(75)
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
        
        exampleView.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(checkboxView.snp.bottom).offset(10)
            make.leading.greaterThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
            make.trailing.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(16)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(view.safeAreaLayoutGuide.snp.width).offset(-32)
            make.height.equalTo(exampleView.snp.width) // квадрат
        }
        
        tableView.snp.makeConstraints { make in
            make.top.lessThanOrEqualTo(exampleView.snp.bottom).offset(20)
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let parameter = themes[indexPath.row]
        locallySelectedTheme = parameter

        let text = CustomColors.getCurrentTheme() == locallySelectedTheme ? "This is your current theme:" : "Set a new theme?"
        exampleView.configure(firstLable: text, themeName: parameter.rawValue)
        exampleView.refreshColors(theme: parameter)
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
        parentView.layer.cornerRadius = 10
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
        infoButton.setTitle("Saved!", for: .highlighted)
        infoButton.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        infoButton.backgroundColor = CustomColors.bigButtonColor
        infoButton.setTitleColor(.white, for: .normal)
        infoButton.layer.cornerRadius = 15
        infoButton.addTarget(self, action: #selector(infoTapped), for: .touchUpInside)

        parentView.layer.cornerRadius = 15
        parentView.layer.borderWidth = 2
        parentView.layer.borderColor = CustomColors.softAppColor.cgColor
        parentView.backgroundColor = CustomColors.generalAppFont
    }
    
    func refreshColors(theme: Theme) {
        let colors = CustomColors.colors(forPreview: theme)
        infoLabelOne.textColor = colors.secondaryTextColor
        infoLabelTwo.textColor = colors.generalTextColor
        infoLabelTwo.backgroundColor = colors.backgroundForCell
        infoButton.backgroundColor = colors.bigButtonColor
        parentView.layer.borderColor = colors.softAppColor.cgColor
        parentView.backgroundColor = colors.generalAppFont
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
        infoLabelOne.text = "This is your current theme:"
        onInfoTap?()
    }
}

final class ExclusiveCheckboxView: UIView {
    private let label = UILabel()
    private let stackView: UIStackView = .init()
    private var selectionButtons: [UIButton] = []
    private let allStyles: [SelectionBoxType] = [.round, .seal, .hexagon, .diamond, .square]
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
        
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        
        for caseType in allStyles {
            let button = createButton(type: caseType)
            selectionButtons.append(button)
        }
    }
    
    func applyTheme() {
        label.textColor = CustomColors.generalTextColor
    }

    private func addViews() {
        addSubview(label)
        addSubview(stackView)
        
        for eachButton in selectionButtons {
            stackView.addArrangedSubview(eachButton)
        }
    }

    private func layout() {
        label.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
        }
        
        stackView.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom)
            make.height.equalTo(45)
            make.leading.trailing.equalToSuperview()
        }
    }
    
    private func createButton(type: SelectionBoxType) -> UIButton {
        let button = UIButton(type: .custom)
        button.addAction(UIAction { [weak self] _ in
            self?.checkBoxTapped(type: type)
        }, for: .touchUpInside)
        button.imageView?.tintColor = CustomColors.getRandomElementColor()
        
        choseIconForButton(with: type, button)
        
        button.imageView?.snp.makeConstraints { make in
            make.width.equalTo(35)
            make.height.equalTo(35)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        return button
    }
    
    func refreshButtons() {
        for (index, button) in selectionButtons.enumerated() {
            let type = allStyles[index]
            choseIconForButton(with: type, button)
        }
    }
    
    private func choseIconForButton(with type: SelectionBoxType, _ button: UIButton) {
        let (chosenImages, unchosenImages) = type.images
        let pool = UserSelectionStyle.currentType == type ? chosenImages : unchosenImages
        
        guard let imageName = pool.randomElement() else { button.setImage(nil, for: .normal); return }
        
        button.setImage(UIImage(systemName: imageName), for: .normal)
    }
        
    private func checkBoxTapped(type: SelectionBoxType) {
        selected = type
        UserSelectionStyle.setStyle(selected)
        refreshButtons()
    }
}
