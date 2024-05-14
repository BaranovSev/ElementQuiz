//
//  CustomProgressView.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 03.01.2024.



import UIKit

final class CircleProgressBar: UIView {
    private var dataSource: UserStatisticDataSource?
    private var progress: CGFloat = 0.0 {
        didSet {
            refresh()
        }
    }
    
    private var displayItem: DisplayItem? {
        didSet {
            refresh()
        }
    }
    
    init(displayItem: DisplayItem) {
        super.init(frame: .zero)
        self.displayItem = displayItem
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2 - 10
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * progress
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        UIColor.blue.setStroke()
        path.lineWidth = 10
        path.stroke()
        guard let innerProgress = displayItem?.array else { return }
        
//        var innerProgress = [
//            [CustomColors.actinide : 0.9],
//            [CustomColors.alkaliMetal: 0.8],
//            [CustomColors.alkalineEarthMetal : 0.7],
//            [CustomColors.diatomicNonmetal : 0.6],
//            [CustomColors.lanthanide : 0.5],
//            [CustomColors.metalloid : 0.6],
//            [CustomColors.nobleGas : 0.5],
//            [CustomColors.polyatomicNonmetal : 0.6],
//            [CustomColors.postTransitionMetal : 0.6],
//            [CustomColors.transitionMetal : 0.8],
//            [CustomColors.unknownElement : 0.4]
//        ]
        
        if !innerProgress.isEmpty {
            for i in 0..<innerProgress.count {
                let innerRadius = radius * CGFloat(1.0 - CGFloat(i+1) * 0.08) // уменьшаем радиус для вложенных индикаторов 0.08
                drawInnerProgressBar(center: center, radius: innerRadius, progress: innerProgress[i].values.first!, color: innerProgress[i].keys.first!)
            }
        }
    }
    
    func drawInnerProgressBar(center: CGPoint, radius: CGFloat, progress: CGFloat, color: UIColor) {
        let startAngle = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * progress
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        color.setStroke()
        path.lineWidth = 5
        path.stroke()
    }
}

private extension CircleProgressBar {
    func refresh() {
        setNeedsDisplay()
    }
    
    func setup() {
        backgroundColor = .clear
    }
}

extension CircleProgressBar {
    var sizeIncrement: Float {
        var markers: [Bool] = []
        guard let array = displayItem?.array else { return 0 }
        
        for element in array {
            if element.values.first == 0 {
                markers.append(false)
            } else {
                markers.append(true)
            }
        }
        
        let result = markers.filter{ $0 == true }.count
        
        var increment: Float = 0
        if result == 0 {
            increment = 0
        }
        else if result < 3 {
            increment = 0.3
        }
        else if result < 7 {
            increment = 0.7
        }
        else if result >= 7 {
            increment = 1.0
        }
        
        return increment
    }
}


