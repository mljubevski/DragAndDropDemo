//
//  RightContainerView.swift
//  DragAndDropDemo
//
//  Created by Milos Ljubevski on 9/8/17.
//  Copyright © 2017 Milos Ljubevski. All rights reserved.
//

import UIKit

class RightContainerView: ContainerView, UITableViewDropDelegate
{
    override var cellColor: UIColor {
        return .orange
    }
    
    // MARK: UITableViewDropDelegate
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator)
    {
        let dragItem = coordinator.items.first!.dragItem
        
        let item: Item = dragItem.localObject as! Item
        
        self.items.insert(item, at: coordinator.destinationIndexPath!.row)
        
        tableView.insertRows(at: [coordinator.destinationIndexPath!], with: .none)
        
    }
    
    override func initializeTableView()
    {
        super.initializeTableView()
        
        tableView?.dropDelegate = self
    }
}

























