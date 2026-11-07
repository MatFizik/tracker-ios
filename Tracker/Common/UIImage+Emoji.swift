//
//  UIImage+Emoji.swift
//  Tracker
//
//  Created by Adilkhan on 07/11/26.
//

import UIKit
import CoreImage.CIFilterBuiltins

extension UIImage {
    static func emoji(_ emoji: String, fontSize: CGFloat) -> UIImage {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: fontSize)]
        let text = emoji as NSString
        let size = text.size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            text.draw(at: .zero, withAttributes: attributes)
        }
    }

    func grayscaled() -> UIImage {
        guard let input = CIImage(image: self) else { return self }
        let filter = CIFilter.colorControls()
        filter.inputImage = input
        filter.saturation = 0
        guard
            let output = filter.outputImage,
            let cgImage = CIContext().createCGImage(output, from: output.extent)
        else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
