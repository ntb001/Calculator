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

    override func drawRect(rect: CGRect) {
        if !isOriginSet {
            plotOrigin = CGPoint(x: rect.midX, y: rect.midY)
        }
        axesHelper.contentScaleFactor = contentScaleFactor
        axesHelper.drawAxesInRect(rect, origin: plotOrigin, pointsPerUnit: scale)
    }

}
