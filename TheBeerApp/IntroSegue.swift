//
//  IntroSegue.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/30/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class IntroSegue: UIStoryboardSegue {

    override func perform() {
        scale()
    }
    
    func scale() {
        let fromViewController = self.source
        let toViewController = self.destination
        
        let logo = UIImage(named: "largeBeerIcon")
        
        let bgView = UIView(frame: toViewController.view.frame)
        bgView.backgroundColor = UIColor(hex: mainColor)
        let renderer = UIGraphicsImageRenderer(size: bgView.bounds.size)
        let frame = renderer.image { ctx in
            bgView.drawHierarchy(in: bgView.bounds, afterScreenUpdates: true)
        }
        
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: toViewController.view.frame.width,
                                 height: toViewController.view.frame.height)
        imageView.contentMode = .scaleAspectFit
        
        let size = imageView.frame.size
        let rect = CGRect(x: 0,
                          y: 0,
                          width: size.width,
                          height: size.height)
        UIGraphicsBeginImageContext(size)
        frame.draw(in: rect)
        let logoRect = CGRect(x: (toViewController.view.frame.width/2 - 50),
                              y: (toViewController.view.frame.height/2 - 50),
                              width: 100,
                              height: 100)
//
//        let logoRect = CGRect(x: 0,
//                              y: 0,
//                              width: toViewController.view.frame.height * 2,
//                              height: toViewController.view.frame.height * 2)
        
        logo?.draw(in: logoRect, blendMode: .destinationOut, alpha: 1.0)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = newImage

        let containerView = fromViewController.view.superview
        let originalCenter = fromViewController.view.center
        
        toViewController.view.center = originalCenter
        containerView?.addSubview(toViewController.view)
        fromViewController.present(toViewController, animated: false, completion: nil)
        
        containerView?.addSubview(imageView)
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            let t1 = CGAffineTransform.init(translationX: 10, y: 0)
            let t2 = CGAffineTransform.init(scaleX: 100, y: 100)

            imageView.transform = t1.concatenating(t2)

        }, completion: { success in
            imageView.removeFromSuperview()
        })
        
    }
    
}

extension UIImage {
    func masked(with image: UIImage, position: CGPoint? = nil, inverted: Bool = false) -> UIImage? {
        let position = position ??
            CGPoint(x: size.width/2 - image.size.width/2,
                    y: size.height/2 - image.size.height/2)
        defer { UIGraphicsEndImageContext() }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: .zero)
        image.draw(at: position, blendMode: inverted ? .destinationOut : .destinationIn, alpha: 1)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
