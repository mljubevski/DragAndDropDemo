//
//  LeftContainerView.swift
//  DragAndDropDemo
//
//  Created by Milos Ljubevski on 9/8/17.
//  Copyright © 2017 Milos Ljubevski. All rights reserved.
//

import UIKit

class LeftContainerView: ContainerView, UITableViewDragDelegate
{
    override var cellColor: UIColor {
        return .purple
    }
    
    // MARK: UITableViewDragDelegate
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let item = items[indexPath.row]
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        dragItem.localObject = item
        
        return [dragItem]
    }
    
    override func initializeTableView()
    {
        super.initializeTableView()
        self.tableView?.dragDelegate = self
        self.tableView?.dragInteractionEnabled = true
    }
}

























