//
//  LayerSlider.swift
//  UserInterface
//
//  Created by Christian Otkjær on 26/01/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Arithmetic

/*
class LayerSlider: UIView, Slider
{
    open var delegate: SliderDelegate?
    
    open var minValue: Float = 0
    
    open var maxValue: Float = 1
    
    open var value: Float
        {
        set
        {
            updateStrokeStop(newValue)
            updateThumbLabelText()
        }
        get
        {
            return minValue + span * Float(barLayer.strokeEnd)
        }
    }
    
    //TODO: fix
    open var progress: Float = 0
    
    private var span: Float { return abs(maxValue - minValue) }
    
    private func t(_ value: Float? = nil) -> Float
    {
        let v = min(maxValue, max(minValue, value ?? self.value))
        
        let s = span
        
        guard s != 0 else { return v - minValue }
        
        return (v - minValue) / s
    }
    
    // MARK: - Path
    
    open var path: UIBezierPath?
        {
        get
        {
            guard let p = trackLayer.path else { return nil }
            
            return UIBezierPath(cgPath: p)
        }
        set
        {
            let p = newValue?.cgPath
            
            trackLayer.path = p
            barLayer.path = p
            thumbLayer.path = p
        }
    }
    
    // MARK: - Layers
    
    private let thumbLayer = CAShapeLayer()
    open var thumbWidth: CGFloat
        {
        set { thumbLayer.lineWidth = newValue }
        get { return thumbLayer.lineWidth }
    }
    
    open var thumbTint: UIColor
        {
        set { thumbLayer.strokeColor = newValue.cgColor }
        get { return thumbLayer.strokeColor?.uiColor ?? .clear }
    }
    
    private let trackLayer = CAShapeLayer()
    open var trackWidth: CGFloat
        {
        set { trackLayer.lineWidth = newValue }
        get { return trackLayer.lineWidth }
    }
    
    open var trackTint: UIColor
        {
        set { trackLayer.strokeColor = newValue.cgColor }
        get { return trackLayer.strokeColor?.uiColor ?? .clear }
    }
    
    private let barLayer = CAShapeLayer()
    open var barWidth: CGFloat
        {
        set { barLayer.lineWidth = newValue }
        get { return barLayer.lineWidth }
    }
    
    open var barTint: UIColor
        {
        set { barLayer.strokeColor = newValue.cgColor }
        get { return barLayer.strokeColor?.uiColor ?? .clear }
    }
    
    // MARK: - Label
    
    public let thumbLabel = UILabel()
    
    
    // MARK: - Init
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        initialSetup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    override open func awakeFromNib()
    {
        super.awakeFromNib()
        initialSetup()
    }
    
    func initialSetup()
    {
        trackLayer.lineCap = kCALineCapRound
        barLayer.lineCap = kCALineCapRound
        thumbLayer.lineCap = kCALineCapRound
        
        trackLayer.lineWidth = 70
        barLayer.lineWidth = 70
        thumbLayer.lineWidth = 66
        
        if trackLayer.strokeColor == nil { trackTint = UIColor(white: 0, alpha: 0.02) }
        
        if barLayer.strokeColor == nil { barTint = UIColor(red: 0, green: 0, blue: 1, alpha: 1) }
        
        if thumbLayer.strokeColor == nil { thumbTint = UIColor(white: 1, alpha: 0.98) }
        
        thumbLayer.shadowColor = UIColor(white: 0, alpha: 1).cgColor
        thumbLayer.shadowOffset = .zero
        thumbLayer.shadowRadius = 5
        
        layer.addSublayer(trackLayer)
        layer.addSublayer(barLayer)
        layer.addSublayer(thumbLayer)
        
        updatePath()
        updateStrokeStop()
        addGestureRecognizers()
        
        // Label
        
        thumbLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        thumbLabel.textColor = UIColor.darkText
        
        thumbLabel.textAlignment = .center
        
        addSubview(thumbLabel)
    }
    
    func updatePath()
    {
        let margin = ceil(max(trackWidth, barWidth, thumbWidth) / 2)
        
        let f = bounds.insetBy(dx: margin, dy: margin)
        
        let p = UIBezierPath()
        p.move(to: f.centerLeft)
        p.addLine(to: f.centerRight)
        
        path = p
        //        let p = path.cgPath
        //
        //        trackLayer.path = p
        //        barLayer.path = p
        //        thumbLayer.path = p
    }
    
    func updateStrokeStop(_ value: Float? = nil)
    {
        let t = CGFloat(self.t(value))
        
        trackLayer.strokeStart = t
        barLayer.strokeEnd = t
        thumbLayer.strokeStart = t - 0.0001
        thumbLayer.strokeEnd = t + 0.0001
        
        updateThumbLabelFrame()
    }
    
    open override var bounds: CGRect
        {
        didSet { updatePath() }
    }
    
    // MARK: - Frames
    
    open func trackRect(forBounds bounds: CGRect? = nil) -> CGRect
    {
        let bounds = bounds ?? self.bounds
        
        let margin = ceil(max(trackWidth, barWidth, thumbWidth) / 2)
        
        let f = bounds.insetBy(dx: margin, dy: margin)
        
        return f
    }
    
    open func thumbRect(forBounds bounds: CGRect? = nil, trackRect rect: CGRect? = nil, value: Float? = nil) -> CGRect
    {
        let bounds = bounds ?? self.bounds
        let value = value ?? self.value
        
        let margin = ceil(max(trackWidth, barWidth, thumbWidth) / 2)
        
        let b = bounds.insetBy(dx: margin, dy: margin)
        
        let f = CGFloat((value - minValue) / span)
        
        let cx = b.minX + b.width * f
        
        let cy = b.midY
        
        return CGRect(center: CGPoint(x: cx, y: cy), size: CGSize(width: thumbWidth, height: thumbWidth))
        
    }
    
    func updateThumbLabelText()
    {
        let text = String(round(value))
        
        if text != thumbLabel.text
        {
            thumbLabel.text = text
        }
    }
    
    func updateThumbLabelFrame()
    {
        bringSubview(toFront: thumbLabel)
        thumbLabel.frame = thumbRect()
    }
    
    // MARK: - Gestures
    
    func addGestureRecognizers()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(type(of: self).handleTap(_:)))
        
        tap.numberOfTapsRequired = 2
        
        addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(type(of: self).handlePan(_:)))
        
        addGestureRecognizer(pan)
    }
    
    func snap(gesture: UIGestureRecognizer)
    {
        let location = gesture.location(in: self)
        
        let f = path!.bounds
        
        let t = Float((location.x - f.minX) / f.width)
        
        let v = (minValue, maxValue) ◊ t
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0,
            options: [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction],
            animations: {
                self.value = v
        }) { (completed) in
            
        }
    }
    
    func handleTap(_ tap: UITapGestureRecognizer)
    {
        snap(gesture: tap)
    }
    
    var trackingPan: Bool = false
    
    func handlePan(_ pan: UIPanGestureRecognizer)
    {
        switch pan.state
        {
        case .began:
            
            trackingPan = true
            
            fallthrough
            
        case .changed:
            
            guard trackingPan else { return }
            
            snap(gesture: pan)
            
        default:
            
            guard trackingPan else { return }
            
            snap(gesture: pan)
            
            trackingPan = false
        }
    }
}

*/
