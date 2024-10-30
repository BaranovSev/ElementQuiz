//
//  LessonViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 30.10.2024.
//

import UIKit
import SnapKit


final class LessonViewController: UIViewController {
    private let userDataSource: UserStatisticDataSource = UserStatisticDataSource()
    private let fixedElementList: [ChemicalElementModel] = DataManager.shared.fetchElements()
    private let user: User = DataManager.shared.fetchUser()
    private var learnedElements: [ChemicalElementModel] {
        get {
            DataManager.shared.fetchLearnedElements()
        }
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backAction))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
        backButton.tintColor = CustomColors.generalTextColor
        
        setup()
        addSubViews()
        layout()
    }
    
    
    private func addSubViews() {
//        view.addSubview(scrollView)
    }
    
    private func layout() {
        
    }
    
    private func setup() {
        
    }
    
    @objc func backAction() {
        //TODO: save current progress?
        self.dismiss(animated: true)
    }
}

