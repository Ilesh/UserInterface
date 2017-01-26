//
//  UIView+Cover.swift
//  UserInterface
//
//  Created by Christian Otkjær on 01/11/16.
//  Copyright © 2016 Christian Otkjær. All rights reserved.
//

public extension UIView
{
    fileprivate class CoverView : UIView
    {
        // MARK: - Init
        
        override init(frame: CGRect)
        {
            super.init(frame: frame)
            setup()
        }
        
        required init?(coder aDecoder: NSCoder)
        {
            super.init(coder: aDecoder)
            setup()
        }
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        func setup()
        {
            backgroundColor = UIColor(white: 0, alpha: 0.25)
            alpha = 0
            autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            activityView.startAnimating()
            addSubview(activityView)
        }
        
        
        fileprivate override func layoutSubviews()
        {
            super.layoutSubviews()
            
            activityView.center = bounds.center
        }
    }
    
    /// Covers this view
    func cover(duration: Double = 0.25, hideActivityView: Bool = false, completion: (() -> ())? = nil)
    {
        guard subviews(ofType: CoverView.self).isEmpty else { return }
        
        let coverView = CoverView(frame: bounds)
        
        coverView.activityView.isHidden = hideActivityView
        
        addSubview(coverView)
        
        UIView.animate(withDuration: duration,
                       animations: {
                        coverView.alpha = 1
            }, completion: { _ in completion?() })
        
    }
    
    /// Uncovers this view
    public func uncover(duration: Double = 0.25, completion: (() -> ())? = nil)
    {
        let coverViews = subviews(ofType: CoverView.self)
        
        guard !coverViews.isEmpty else { completion?(); return }
        
        UIView.animate(
            withDuration: duration,
            animations:
            {
                coverViews.forEach { $0.alpha = 0 }
            },
            completion:
            {
                (completed) -> Void in
                
                coverViews.forEach { $0.removeFromSuperview() }
                
                completion?()
        }) 
    }
}
