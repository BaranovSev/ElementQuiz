//
//  LessonViewController.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 30.10.2024.
//

import UIKit
import SnapKit


final class LessonViewController: UIViewController {
    private let lesson: Lesson = Lesson.getMockLessonFromJSON()!
    private var currentIndex = 0
    
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
        button.backgroundColor = CustomColors.purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(Self.bigButtonTapped), for: .touchUpInside)
        return button
    }()
    
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
        navigationItem.title = "Lesson #\(lesson.number)"
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.backward"),
            style: .plain,
            target: self,
            action: #selector(backAction)
        )
        backButton.tintColor = CustomColors.generalTextColor
        navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.backgroundColor = CustomColors.generalAppPhont
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
        let vc = CongratulationViewController(delegate: self, describeOfSense: lesson.name, imageName: "coin")
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    func selfDismiss() {
        self.dismiss(animated: false)
    }
}
