//
//  ContainerView.swift
//  DragAndDropDemo
//
//  Created by Milos Ljubevski on 9/8/17.
//  Copyright © 2017 Milos Ljubevski. All rights reserved.
//

import UIKit

class ContainerView: UIView, UITableViewDelegate, UITableViewDataSource
{
    var items: [Item] = []
    
    var cellColor: UIColor {
        return .clear
    }
    
    private(set) var tableView: UITableView?

    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        for index in 0..<10
        {
            let item = Item()
            item.color = cellColor
            item.initialIndex = index
            
            items.append(item)
        }
        
        self.initializeUI()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
 
    // MARK: UITableViewDelegate, UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        let item = items[indexPath.row]
        
        
        if cell == nil
        {
            cell = Cell()
        }

        cell?.backgroundColor = item.color
        cell?.textLabel?.text = "cell number: \(item.initialIndex + 1)"

        
        return cell!
    }
    
    // MARK: Private
    
    private func initializeUI()
    {
        self.initializeTableView()
    }
    
    func initializeTableView()
    {
        self.tableView = UITableView()
        self.tableView?.backgroundView?.backgroundColor = .clear
        self.tableView?.backgroundColor = .clear
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.addSubview(self.tableView!)
        
        self.tableView?.pinAllEdgesToSuperview().activate()
        
        self.tableView?.reloadData()
    }
}


































