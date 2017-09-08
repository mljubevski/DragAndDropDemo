//
//  ViewController.swift
//  DragAndDropDemo
//
//  Created by Milos Ljubevski on 9/8/17.
//  Copyright © 2017 Milos Ljubevski. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.initializeUI()
    }
    
    private func initializeUI()
    {
        let leftView = LeftContainerView()
        self.view.addSubview(leftView)
        leftView.pinEdgesToParent([.left, .top, .bottom]).activate()
        leftView.setWidthRelatedToParent(percent: 0.5).activate()
        
        let rightView = RightContainerView()
        self.view.addSubview(rightView)
        rightView.pinEdgesToParent([.right, .top, .bottom]).activate()
        rightView.setWidthRelatedToParent(percent: 0.5).activate()
    }
    

}


















