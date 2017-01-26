//
//  SliderViewController.swift
//  UserInterface
//
//  Created by Christian Otkjær on 26/01/17.
//  Copyright © 2017 Christian Otkjær. All rights reserved.
//

import UIKit
import UserInterface

class SliderViewController: UIViewController {

    @IBOutlet weak var topSlider: RoundedSlider?
        {
        didSet { topSlider?.delegate = self }
    }
    
    @IBOutlet weak var slider: RoundedSlider?
    {
        didSet { slider?.delegate = self }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - SliderDelegate

extension SliderViewController : SliderDelegate
{
    public func slider(_ slider: Slider, willBeginSlidingWithInitialValue initialValue: Float)
    {
        slider.thumbView?.layer.shadowColor = CGColor.black
        slider.thumbView?.layer.shadowOffset = CGSize(width: 2, height: 2)
        slider.thumbView?.layer.shadowRadius = 3
        slider.thumbView?.layer.shadowOpacity = 0.5
    }

    func slider(_ slider: Slider, willEndSlidingWithProposedValue proposedValue: Float) -> Float?
    {
        if slider as? RoundedSlider == topSlider
        {
            return round(proposedValue)
        }
        
        return round(proposedValue * 10) / 10
    }
    
    func slider(_ slider: Slider, didEndSlidingWithFinalValue finalValue: Float)
    {
        slider.thumbView?.layer.shadowColor = CGColor.clear
        slider.thumbView?.layer.shadowOffset = .zero
        slider.thumbView?.layer.shadowRadius = 0
        slider.thumbView?.layer.shadowOpacity = 0

    }
    
    public func slider(_ slider: Slider, willAnimateWithAnimator animator: SliderAnimator)
    {
        if slider as? RoundedSlider == topSlider
        {
            let toText = String(format: "%0.0f", round(animator.toValue))

            return animator.animatedAlongside(animation:
                {
                slider.thumbLabel?.text = toText
                
            }, completion: nil)

        }
        
        
        let toText = String(format: "%0.2f", animator.toValue)
        
        let fromText = slider.thumbLabel?.text ?? ""// String(format: "%0.2f", animator.fromValue)
    
        if fromText != toText
        {
        
            animator.animatedAlongside(animation: { 
                slider.thumbLabel?.text = toText
                slider.barView?.backgroundColor = UIColor(hue: CGFloat(slider.progress), saturation: 0.8, brightness: 0.8, alpha: 1)
                
            }, completion: nil)
        }
        
    }
}
