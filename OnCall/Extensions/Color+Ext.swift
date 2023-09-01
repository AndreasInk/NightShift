//
//  Color+Ext.swift
//  OnCall
//
//  Created by Andreas Ink on 8/25/23.
//

import UIKit
import SwiftUI

#if os(iOS)
extension UIImage {
    func getDominantColor() -> UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage])
        guard let outputImage = filter?.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: NSNull()])
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
#endif
extension UIImage {
    func jpegData(compressedTo maxSize: Double) -> Data? {
        var compression: CGFloat = 1.0
        let maxByte = maxSize * 1024
        
        guard var imageData = self.jpegData(compressionQuality: compression) else { return nil }
        
        while Double(imageData.count) > maxByte && compression > 0 {
            compression -= 0.1
            guard let newImageData = self.jpegData(compressionQuality: compression) else { return nil }
            imageData = newImageData
        }
        
        return imageData
    }
}
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
}

struct CodableColor: Codable, Hashable {
    var color: Color {
        return Color(red: red, green: green, blue: blue)
    }
    init(red: Double, blue: Double, green: Double) {
        self.red = red
        self.blue = blue
        self.green = green
    }
    static func toCodable(color: UIColor) -> CodableColor {
        guard let components = color.cgColor.components else {
            fatalError("Failed to get color components from UIColor.")
        }
        let red = components[0]
        let green = components[1]
        if components.indices.contains(2) {
            let blue = components[2]
            
            return CodableColor(red: red, blue: blue, green: green)
        } else {
            return CodableColor(red: 0, blue: 0, green: 0)
        }
    }
    var red: Double
    var blue: Double
    var green: Double
    
}
extension Color {
    func toUIColor() -> UIColor {
        let components = self.cgColor!.components!
        return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}
