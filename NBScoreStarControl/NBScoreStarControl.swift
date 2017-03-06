//
//  NBScoreStarControl.swift
//  NBScoreStarControl
//
//  Created by NapoleonBai on 2017/3/6.
//  Copyright © 2017年 白志强. All rights reserved.
//

import UIKit

/// 评分条控制器
@IBDesignable
class NBScoreStarControl: UIControl {
    
    private var previousValue : Float = 0
    
    /// 评分最大值,亦是星星个数 默认为5
    @IBInspectable var maximumValue : Int = 5
    /// 允许评分最小值, 默认为1
    @IBInspectable var minimumValue : Float = 1 {
        didSet{
            minimumValue = max(minimumValue, 0)
            self.setNeedsDisplay()
        }
    }
    
    /// 未选中状态颜色, 默认为groupTableViewBackgroundColor
    @IBInspectable var normalColor : UIColor = .groupTableViewBackground
    /// 当前值
    @IBInspectable var value : Float = 0.0 {
        didSet{
            /// 当前值不允许小于0
            value = max(value, 0.0)
            
            if value != oldValue {
                if !self.readOnly {
                    self.sendActions(for: .valueChanged)
                }
            }
            self.valueLabel.text = String(format:"%.1f",value)
            self.setNeedsDisplay()
        }
    }
    /// 间距
    @IBInspectable var spacing : Float = 5.0 {
        didSet{
            spacing = max(spacing, 0.0)
            self.setNeedsDisplay()
        }
    }
    
    
    /// 是否允许半颗星星, 默认不允许
    @IBInspectable var allowsHalfStars : Bool = false
    /// 是否为只读,默认可操作
    @IBInspectable var readOnly : Bool = false
    /// 是否显示评分值(右侧),默认不显示
    @IBInspectable var showValue : Bool = false {
        didSet{
            if showValue {
                self.valueLabel.text = String(format:"%.1f",value)
            }else{
                self.valueLabel.text = ""
            }
            self.valueLabel.isHidden = !showValue
            self.setNeedsDisplay()
        }
    }
    
    
    /// 评分数字显示,懒加载
    private let valueLabel : UILabel = {
        let valueLabel = UILabel()
        valueLabel.text = "5.0"
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.sizeToFit()
        return valueLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initView()
    }
    
    /// 初始化界面,添加布局约束等
    func initView() {
        self.backgroundColor = .clear
        self.isExclusiveTouch = true
        
        self.addSubview(self.valueLabel)
        self.valueLabel.isHidden = !self.showValue
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 50))
    }
    
    /// 根据条件进行布置星星灯
    ///
    /// - Parameter rect:
    override func draw(_ rect: CGRect) {
        var newRect : CGRect = rect
        
        if self.showValue {
            // 得到新的绘图空间
            newRect = CGRect(origin: rect.origin, size: CGSize(width: rect.size.width - (valueLabel.bounds.size.width + 5), height: rect.size.height))
        }
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor((self.backgroundColor?.cgColor)!)
        context?.fill(newRect)
        
        let availableWidth = newRect.size.width - CGFloat(spacing * Float(maximumValue + 1))
        
        let cellWidth = availableWidth / CGFloat(maximumValue)
        let starSide = cellWidth <= newRect.size.height ? cellWidth : newRect.size.height
        for index in 0 ..< maximumValue  {
            let center = CGPoint(x: cellWidth*CGFloat(index) + cellWidth / 2.0 + CGFloat(spacing) * CGFloat(index + 1), y: newRect.size.height / 2)
            let frame = CGRect(x : center.x - starSide/2, y : center.y - starSide/2, width : starSide, height :starSide)
            let highlighted = Float(index+1) <= ceilf(value)
            let halfStar = highlighted ? (Float(index+1) > value) : false
            
            if halfStar && allowsHalfStars {
                self.drawStarWith(frame, normalColor: self.normalColor, tintColor: self.tintColor, highlighted: false)
                self.drawHalfStarWith(frame, normalColor: self.normalColor, tintColor: self.tintColor, highlighted: highlighted)
            }else{
                self.drawStarWith(frame, normalColor: self.normalColor, tintColor: self.tintColor, highlighted: highlighted)
            }
        }
    }
    
    override func setNeedsLayout() {
        super.setNeedsLayout()
        self.setNeedsDisplay()
    }
    
    
    func drawStarWith(_ frame : CGRect , normalColor:UIColor ,tintColor:UIColor ,highlighted:Bool) -> () {
        let starShapePath = UIBezierPath()
        
        starShapePath.move(to: CGPoint(x : frame.minX + 0.5 * frame.width,y :frame.minY + 0 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.66 * frame.width,y : frame.minY + 0.28 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.98 * frame.width,y : frame.minY + 0.35 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.76 * frame.width,y : frame.minY + 0.58 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.79 * frame.width,y : frame.minY + 0.9 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.5 * frame.width,y : frame.minY + 0.78 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.21 * frame.width,y : frame.minY + 0.9 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.24 * frame.width,y : frame.minY + 0.58 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.02 * frame.width,y : frame.minY + 0.35 * frame.height))
        starShapePath.addLine(to: CGPoint(x : frame.minX + 0.34 * frame.width,y : frame.minY + 0.28 * frame.height))
        starShapePath.close()
        starShapePath.lineJoinStyle = .round
        if highlighted {
            tintColor.setFill()
            starShapePath.fill()
        }else{
            normalColor.setFill()
            starShapePath.fill()
        }
    }
    
    
    func drawHalfStarWith(_ frame : CGRect ,normalColor:UIColor ,tintColor:UIColor ,highlighted:Bool) -> () {
        let starShapePath = UIBezierPath()
        
        
        starShapePath.move(to: CGPoint(x : frame.minX + 0.5 * frame.width,y :frame.minY + 0 * frame.height))
        
        starShapePath.addLine(to: CGPoint(x :frame.minX + 0.34 * frame.width,y :frame.minY + 0.28 * frame.height))
        starShapePath.addLine(to: CGPoint(x :frame.minX + 0.02 * frame.width,y :frame.minY + 0.35 * frame.height))
        starShapePath.addLine(to: CGPoint(x :frame.minX + 0.24 * frame.width,y :frame.minY + 0.58 * frame.height))
        starShapePath.addLine(to: CGPoint(x :frame.minX + 0.21 * frame.width,y :frame.minY + 0.9 * frame.height))
        starShapePath.addLine(to: CGPoint(x :frame.minX + 0.5 * frame.width,y :frame.minY + 0.78 * frame.height))
        
        starShapePath.close()
        starShapePath.lineJoinStyle = .round
        if highlighted {
            tintColor.setFill()
            starShapePath.fill()
        }else{
            normalColor.setFill()
            starShapePath.fill()
        }
    }
    
    
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        
        if !self.isFirstResponder {
            self.becomeFirstResponder()
        }
        
        guard !self.readOnly else {
            return true
        }
        
        previousValue = value
        self.handle(touch)
        
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        if !self.readOnly {
            self.handle(touch)
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        if self.isFirstResponder {
            self.resignFirstResponder()
        }
        if !self.readOnly {
            self.handle(touch)
            if value != previousValue {
                self.sendActions(for: .valueChanged)
            }
        }
        
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        if self.isFirstResponder {
            self.resignFirstResponder()
        }
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !self.isUserInteractionEnabled
    }
    
    
    
    func handle(_ touch : UITouch?) {
        let location : CGPoint = (touch?.location(in: self))!
        var rect = self.bounds
        if self.showValue {
            rect.size.width -= valueLabel.bounds.size.width + 5
            if !rect.contains(location) {
                return
            }
        }
        
        let cellWidht = rect.size.width / CGFloat(maximumValue)
        let value = location.x / cellWidht
        
        if  allowsHalfStars && Float(value+0.5) < ceilf(Float(value)) {
            let tmpValue = floorf(Float(value)) + 0.5
            self.value = min(max(tmpValue, Float(self.minimumValue)) , Float(maximumValue))
            
        }else{
            let tmpValue = ceilf(Float(value))
            /// 不允许小于最小值或超过最大值
            self.value = min(max(tmpValue, Float(self.minimumValue)) , Float(maximumValue))
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    override var intrinsicContentSize: CGSize{
        let height : CGFloat = 44.0
        return CGSize(width: CGFloat(maximumValue)*height + CGFloat(maximumValue+1)*CGFloat(spacing), height: height)
    }
}

