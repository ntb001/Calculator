//
//  PlotView.swift
//  Calculator
//

import UIKit

@IBDesignable
class PlotView: UIView {

    private var axesHelper = AxesDrawer()
    
    @IBInspectable
    var scale: CGFloat = CGFloat(50) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isOriginSet = false
    
    var plotOrigin: CGPoint = CGPoint() {
        didSet {
            setNeedsDisplay()
            isOriginSet = true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let recognizer = UIPanGestureRecognizer(target: self, action: "pan:")
        addGestureRecognizer(recognizer)
    }

    override func drawRect(rect: CGRect) {
        if !isOriginSet {
            plotOrigin = CGPoint(x: rect.midX, y: rect.midY)
        }
        axesHelper.contentScaleFactor = contentScaleFactor
        axesHelper.drawAxesInRect(rect, origin: plotOrigin, pointsPerUnit: scale)
    }
    
    func pan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Changed: fallthrough
        case .Ended:
            let translation = gesture.translationInView(self)
            plotOrigin = CGPoint(x: plotOrigin.x + translation.x, y: plotOrigin.y + translation.y)
            gesture.setTranslation(CGPointZero, inView: self)
        default: break
        }
    }

}
