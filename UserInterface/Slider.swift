//
//  Slider.swift
//  UserInterface
//
//  Created by Christian Otkjær on 26/01/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import Arithmetic

public protocol Slider
{
    var delegate : SliderDelegate? { set get }
    
    var minValue: Float { set get }
    
    var maxValue: Float { set get }
    
    var value: Float { set get }
    
    /// The progress represented by value in the  min- and max-value span
    var progress: Float { set get }
    
    var thumbLabel: UILabel? { get }
    var thumbView: UIView? { get }
    var trackView: UIView? { get }
    var barView: UIView? { get }
}

public protocol SliderDelegate
{
    func slider(_ slider: Slider, willBeginSlidingWithInitialValue initialValue: Float)
    
    func slider(_ slider: Slider, willEndSlidingWithProposedValue proposedValue: Float) -> Float?

    func slider(_ slider: Slider, didEndSlidingWithFinalValue finalValue: Float)
    
    func slider(_ slider: Slider, willAnimateWithAnimator animator: SliderAnimator)
}

public class SliderAnimator
{
    public let fromValue: Float
    public let toValue: Float
    public internal(set) var duration: Double
    private var animations: [()->()]
    private var completions: [(Bool)->()] = []
    
    init(fromValue: Float, toValue: Float, duration: Double, animation: @escaping ()->(), completion: ((Bool)->())?)
    {
        self.toValue = toValue
        self.fromValue = fromValue
        self.duration = duration
        self.animations = [animation]
        completions.append(completion)
    }
    
    public func animatedAlongside(animation: @escaping ()->(), completion: ((Bool)->())?)
    {
        animations.append(animation)
        completions.append(completion)
    }
    
    internal func animate()
    {
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.beginFromCurrentState, .allowAnimatedContent, .allowUserInteraction],
            animations: {
                self.animations.forEach { $0() }
        }) { (completed) in
            self.completions.forEach { $0(completed) }
        }
    }
}

@IBDesignable
open class RoundedSlider: UIView, Slider
{
    open var delegate: SliderDelegate?
    {
        didSet { animateSlide(to: value) }
    }
    
    @IBInspectable
    open var minValue: Float = 0
    
    @IBInspectable
    open var maxValue: Float = 1
    
    private var _value: Float = 0.5
    
    @IBInspectable
    open var value: Float
        {
        set
        {
            guard newValue != _value else { return }
            
            animateSlide(to: newValue)
        }
        get
        {
            return _value
        }
    }
    
    open var progress: Float
        {
        get { return factor() }
        set { value = (minValue, maxValue) ◊ min(1, max(0, newValue)) }
    }
    
    private func factor(minValue: Float? = nil, maxValue: Float? = nil, value: Float? = nil) -> Float
    {
        let minValue = minValue ?? self.minValue
        let maxValue = maxValue ?? self.maxValue
        let value = value ?? self.value
        
        return (value - minValue) / (maxValue - minValue)
    }
    
    // MARK: - Views
    
    public let trackView: UIView? = UIView(frame: .zero)
    public let barView: UIView? = UIView(frame: .zero)
    public let thumbView: UIView? = UIView(frame: .zero)
    public let thumbLabel: UILabel? = UILabel(frame: .zero)
    
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
        trackView?.backgroundColor = UIColor(white: 0, alpha: 0.02)
        barView?.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        thumbView?.backgroundColor = UIColor(white: 1, alpha: 0.9)
        
        thumbLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        thumbLabel?.textColor = UIColor.darkText
        thumbLabel?.textAlignment = .center
        
        layoutSubviews()
        
        addSubview(trackView!)
        addSubview(barView!)
        addSubview(thumbView!)
        addSubview(thumbLabel!)
        
        addGestureRecognizers()
    }
    
    // MARK: - Layout
    
    open override func layoutSubviews()
    {
        super.layoutSubviews()
        
        layoutSubviews(forValue: value)
    }
    
    private func layoutSubviews(forValue value: Float)
    {
        trackView?.frame = trackFrame()
        trackView?.roundCorners()
        
        barView?.frame = barFrame(trackRect: trackView?.frame, value: value)
        barView?.roundCorners()
        
        let tFrame = thumbFrame(barRect: barView?.frame)
        thumbView?.frame = tFrame
        thumbView?.roundCorners()
        
        thumbLabel?.frame = tFrame
    }
    
    // MARK: Frames
    
    func trackFrame(forBounds bounds: CGRect? = nil) -> CGRect
    {
        let bounds = bounds ?? self.bounds
        
        return bounds
    }
    
    func barFrame(forBounds bounds: CGRect? = nil, trackRect: CGRect? = nil, value: Float? = nil) -> CGRect
    {
        let bounds = bounds ?? self.bounds
        let trackRect = trackRect ?? trackFrame(forBounds: bounds)
        let value = value ?? self.value
        
        let height = trackRect.height
        let width = (trackRect.width - height) * CGFloat(factor(value: value))
        
        return CGRect(x: trackRect.minX, y: trackRect.minY, width: height + width, height: height)
    }
    
    func thumbFrame(forBounds bounds: CGRect? = nil, trackRect: CGRect? = nil, barRect: CGRect? = nil, value: Float? = nil) -> CGRect
    {
        let bounds = bounds ?? self.bounds
        let trackRect = trackRect ?? trackFrame(forBounds: bounds)
        let value = value ?? self.value
        let barRect = barRect ?? barFrame(forBounds: bounds, trackRect: trackRect, value: value)
        
        let r = barRect.insetBy(dx: 2, dy: 2)
        
        return CGRect(x: r.maxX - r.height, y: r.minY, width: r.height, height: r.height)
    }

    // MARK: - Slide Animation
    
    func animateSlide(to: Float, completion: ((Bool)->())? = nil)
    {
        let animator = SliderAnimator(fromValue: value, toValue: to, duration: 0.1, animation: {
            self._value = to
            self.layoutSubviews(forValue: to)
        }, completion: completion)
        
        delegate?.slider(self, willAnimateWithAnimator: animator)
        
        animator.animate()
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
    
    func value(for gesture: UIGestureRecognizer) -> Float
    {
        var location = gesture.location(in: self)
        
        let f = trackFrame().insetBy(dx: thumbFrame().width / 2, dy: 0)
        
        location.x = min(f.maxX, max(f.minX, location.x))
        
        let t = Float((location.x - f.minX) / f.width)
        
        let v = (minValue, maxValue) ◊ t
        
        return v
    }

    func snap(gesture: UIGestureRecognizer)
    {
        var v = value(for: gesture)
        
        if let adjustedV = delegate?.slider(self, willEndSlidingWithProposedValue: v)
        {
            v = adjustedV
        }
        
        animateSlide(to: v) { _ in
        self.delegate?.slider(self, didEndSlidingWithFinalValue: self.value)
        }
    }
    
    func handleTap(_ tap: UITapGestureRecognizer)
    {
        delegate?.slider(self, willBeginSlidingWithInitialValue: value)
        snap(gesture: tap)
    }
    
    var trackingPan: Bool = false
    
    func handlePan(_ pan: UIPanGestureRecognizer)
    {
        switch pan.state
        {
        case .began:
            
            trackingPan = true

            delegate?.slider(self, willBeginSlidingWithInitialValue: value)
            
            fallthrough
            
        case .changed:
            
            guard trackingPan else { return }
            
            animateSlide(to: value(for: pan))
            
        default:
            
            guard trackingPan else { return }
            
            snap(gesture: pan)
            
            trackingPan = false
        }
    }
}

public protocol DiscreteSliderDelegate
{
    func sliderDidSlide(_ slider: DiscreteSlider)
    
    func sliderDidEndSliding(_ slider: DiscreteSlider)
}

/**
 Class for discrete-value slider with a thumb label showing the current value
 */
open class DiscreteSlider: UISlider
{
    open var delegate : DiscreteSliderDelegate?
    
    public let thumbLabel = UILabel()
    
    override open var value: Float
        {
        didSet
        {
            updateThumbLabelText()
        }
    }
    
    override open func setValue(_ value: Float, animated: Bool)
    {
        super.setValue(value, animated: animated)
        
        updateThumbLabelText()
    }
    
    public var progress: Float = 0
    
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
    
    override open func layoutSubviews()
    {
        super.layoutSubviews()
        updateThumbLabelFrame()
    }
    
    func initialSetup()
    {
        thumbLabel.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        
        thumbLabel.textColor = UIColor.darkText
        
        thumbLabel.textAlignment = .center
        
        updateThumbLabelText()
        
        addSubview(thumbLabel)
        
        addTarget(self, action: #selector(DiscreteSlider.sliderDidSlide), for: UIControlEvents.valueChanged)
        
        let touchUpEvents : UIControlEvents = [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside]
        
        addTarget(self, action: #selector(DiscreteSlider.sliderDidEndSliding), for: touchUpEvents)
    }
    
    var intValue : Int { return Int(value.round) }
    
    func updateThumbLabelText()
    {
        let text = String(intValue)
        
        if text != thumbLabel.text
        {
            thumbLabel.text = text
        }
    }
    
    func updateThumbLabelFrame()
    {
        bringSubview(toFront: thumbLabel)
        frameViewOnThumb(thumbLabel)
    }
    
    func sliderDidSlide()
    {
        delegate?.sliderDidSlide(self)
    }
    
    func sliderDidEndSliding()
    {
        setValue(value.round, animated: true)
        
        delegate?.sliderDidEndSliding(self)
    }
}
