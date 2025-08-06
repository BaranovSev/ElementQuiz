//
//  LessonViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 30.10.2024.
//

import UIKit
import SnapKit


final class LessonViewController: UIViewController {
    private let lesson: Lesson
    private let headerText: String
    
    // MARK: - UI Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = CustomColors.generalAppPhont
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var bigButton: UIButton = {
        let button = UIButton()
        button.setTitle("Achieve", for: .normal)
        
        button.setTitle("Lets start!", for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Hoefler Text", size: 35)
        button.backgroundColor = CustomColors.bigButtonColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.bigButtonTapped), for: .touchUpInside)
        return button
    }()
    
    init(lesson: Lesson, headerText: String) {
        self.lesson = lesson
        self.headerText = headerText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        addSubViews()
        layout()
        populateLessonContent()
    }
    
    private func setup() {
        view.backgroundColor = CustomColors.generalAppPhont
        navigationItem.title = headerText
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backAction)
        )
        backButton.tintColor = CustomColors.generalTextColor
        navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
        self.navigationController?.hidesBarsOnSwipe = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: CustomColors.generalTextColor]
    }
    
    private func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)
        scrollView.addSubview(bigButton)
    }
    
    private func layout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
            make.width.equalToSuperview().offset(-32)
        }
        
        bigButton.snp.makeConstraints { make in
            make.top.equalTo(contentStackView.snp.bottom).offset(40)
            make.bottom.lessThanOrEqualToSuperview().offset(-30)
            make.centerX.equalToSuperview()
            make.height.equalTo(60)
            make.width.equalTo(200)
        }
    }
    
    private func populateLessonContent() {
        for element in lesson.structure {
            switch element {
            case .headerText(let text):
                contentStackView.addArrangedSubview(createHeaderTextView(text: text))
                
            case .text(let text):
                contentStackView.addArrangedSubview(createTextView(text: text))
                
            case .image(let imageName):
                contentStackView.addArrangedSubview(createImageView(imageName: imageName))
                
            case .question(let question):
                contentStackView.addArrangedSubview(QuestionView(question: question))
                
            case .definition(let twoComponentText):
                contentStackView.addArrangedSubview(BoxViewWithTextView(title: twoComponentText.header, infoText: twoComponentText.body))
                
            case .addition(let twoComponentText):
                contentStackView.addArrangedSubview(HeaderWithText(title: twoComponentText.header, infoText: twoComponentText.body))
            }
        }
    }
    
    private func createHeaderTextView(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Hoefler Text", size: 40)
        label.textAlignment = .center
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
    
    private func createTextView(text: String) -> UITextView {
        let textView = UITextView()
        textView.text = text
        textView.font = UIFont(name: "Avenir", size: 20)
        textView.textColor = CustomColors.generalTextColor
        textView.textAlignment = .justified
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.isEditable = false
        return textView
    }
    
    private func createImageView(imageName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.image = UIImage(named: imageName)
        
        if let image = UIImage(named: imageName) {
            imageView.image = image.withRoundedCorners(inPercentageFromSmallestSide: 5)
            let imageSize = image.size
            let screenSize = UIScreen.main.bounds.size
            
            // Рассчитываем новый размер для ImageView
            let aspectRatio = imageSize.width / imageSize.height
            var newHeight: CGFloat
            var newWidth: CGFloat
            
            if screenSize.width / screenSize.height > aspectRatio {
                // Ширина экрана больше соотношения сторон изображения
                newHeight = screenSize.height
                newWidth = newHeight * aspectRatio
            } else {
                // Высота экрана больше соотношения сторон изображения
                newWidth = screenSize.width
                newHeight = newWidth / aspectRatio
            }
            
            imageView.heightAnchor.constraint(equalToConstant: newHeight).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: newWidth).isActive = true
        }
        
        return imageView
    }
    
    private func createQuestionView(question: Question) -> UIView {
        let label = UILabel()
        label.text = question.text
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textColor = CustomColors.generalTextColor
        label.numberOfLines = 0
        
        let stackView = UIStackView(arrangedSubviews: [label])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        
        return stackView
    }
    
    @objc private func backAction() {
        dismiss(animated: true)
    }

    @objc private func bigButtonTapped() {
        showCongratulationViewController()
    }
}


// MARK: - ShowCongratulationProtocol
extension LessonViewController: ShowCongratulationProtocol {
    func showCongratulationViewController() {
        let describeOfSense: String = headerText.contains("Lesson") ? "Passed \(headerText.lowercased()):\n\(lesson.name)" : "Studied reaction:\n\(lesson.name)"
        let vc = CongratulationViewController(delegate: self, describeOfSense: describeOfSense, imageName: lesson.lessonImageName)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func selfDismiss() {
        self.dismiss(animated: false)
    }
}
