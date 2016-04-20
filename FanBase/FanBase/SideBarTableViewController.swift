//
//  SideBarTableViewController.swift
//  FanBase
//
//  Created by Mariya Eggensperger on 4/13/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

import UIKit

// Add delegate to recognize tapped buttons on sidebar
protocol SideBarTableViewControllerDelegate {
    // Method for did select row when tapped
    func sideBarControlDidSelectRow(indexPath:NSIndexPath)
}
class SideBarTableViewController: UITableViewController {

    
    // Set properties
    var delegate:SideBarTableViewControllerDelegate? //optional property
    // Items in the side bar to tap
    var tableData:Array<String> = []
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
    }
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count;
    }

    // Customize table view
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cell")

        // Check if cell is empty
        if (cell == nil) {
            // Initialize empty cell
            cell = UITableViewCell(style:UITableViewCellStyle.Default,reuseIdentifier: "cell")
            // Configure the cell
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel!.textColor = UIColor.darkTextColor()
            
            // Select to background view
            let selectedView:UIView = UIView(frame: CGRect(x: 0, y: 0, width: cell!.frame.size.width, height: cell!.frame.size.height))
            
            // Adjust view
            selectedView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3)
            
            // Add selectedView to cell 
            cell!.selectedBackgroundView = selectedView
            
        }
        
        // Access the text label (array) in side bar
        cell!.textLabel?.text = tableData[indexPath.row]
        
        return cell!
    }
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        // Asks delegate for height at row in index path
        // Specifies what height in points the row should be
        return 45.0
        
    }
    
    // Tells delegate that the specified row is now selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.sideBarControlDidSelectRow(indexPath)  
    }
}