//
//  UIImage+extension.swift
//  ElementQuiz
//
//  Created by Stepan Baranov on 08.04.2024.
//

import UIKit

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))
    
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    // fixed radius
    func withRoundedCorners(radius: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        path.addClip()
        
        draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    // radius in % from smaller side
    func withRoundedCorners(inPercentageFromSmallestSide percents: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let smallestSide: CGFloat = min(size.width, size.height)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: smallestSide / 100 * percents)
        path.addClip()
        
        draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }
    
    func withRoundedCorners(inPercentageFromBiggestSide percents: CGFloat) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        let biggestSide: CGFloat = max(size.width, size.height)
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: biggestSide / 100 * percents)
        path.addClip()
        
        draw(in: rect)
        
        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return roundedImage
    }

}

//let newImage = image.rotate(radians: .pi/2) // Rotate 90 degrees

