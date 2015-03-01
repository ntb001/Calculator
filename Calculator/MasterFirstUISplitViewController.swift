//
//  MasterFirstUISplitViewController.swift
//  Calculator
//

import UIKit

class MasterFirstUISplitViewController: UISplitViewController, UISplitViewControllerDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.delegate = self
    }
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return true;
    }
}
