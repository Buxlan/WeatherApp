//
//  UIImageExtension.swift
//  Places
//
//  Created by  Buxlan on 6/23/21.
//

import Foundation
import UIKit

extension UIImage {
             
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func resizeImage(to height: CGFloat,
                     aspectRatio: AspectRatio,
                     with color: UIColor = .clear) -> UIImage {
        
        let imageSize = self.size
        var width: CGFloat = 0
        
        switch aspectRatio {
        case .current:
            let ratio = imageSize.height / height
            width = imageSize.width / ratio
        case .square:
            width = height
        }
        
        let size = CGSize(width: width, height: height)        
        let rect = CGRect(origin: CGPoint(x: 0, y: 0),
                          size: size)
        let rend = UIGraphicsImageRenderer(size: size,
                                           format: self.imageRendererFormat)
        let resizedImage = rend.image { con in
            color.setFill()
            con.cgContext.setFillColor(color.cgColor)
            con.cgContext.setStrokeColor(Asset.accent0.color.cgColor)
            self.draw(in: rect)
        }
        return resizedImage
    }

    func maskWithColor(color: UIColor) -> UIImage {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        guard let context = CGContext(data: nil,
                                      width: Int(width),
                                      height: Int(height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
        else {
            fatalError()
//            return UIImage()
        }
                
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            fatalError()
//            return UIImage()
        }
    }
    
}

enum AspectRatio {
    case square
    case current
}
