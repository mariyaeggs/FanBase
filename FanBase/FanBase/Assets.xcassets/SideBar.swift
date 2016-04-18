//
//  SideBar.swift
//  FanBase
//
//  Created by Mariya Eggensperger on 4/13/16.
//  Copyright © 2016 Angelica Bato. All rights reserved.
//

import UIKit

// Objective c optional delegate method 
@objc protocol SideBarDelegate {
    
    func didSelectButtonAtIndex (index:Int)
    
    // Boolean sets receiver as optional
    optional func sideBarWillClose()
    optional func sideBarWillOpen()
}

class SideBar: NSObject, SideBarTableViewControllerDelegate {
    
    // Bar width
    let barWidth:CGFloat = 150.0// px
    
    // Top inset
    let sideBarTableViewTopInset:CGFloat = 64.0// px
    
    // Container view for the tableViewController
    let sideBarContainerView:UIView = UIView()
    
    // Adds custom table view controller
    let sideBarTableViewController:SideBarTableViewController = SideBarTableViewController()
    
    // Adds origin view 
    var originView:UIView! = nil
    
    // Adds an animator for side bar bouncing
    var animator:UIDynamicAnimator!
    // Optional delegate for side bar
    var delegate:SideBarDelegate?
    
    // Booleans to check if side bar is open/closed
    var isSideBarOpen:Bool = false
    
    
    // Initializer allocates memory
    override init() {
        super.init()
    }
    // Custom initializer passes source view
    init(sourceView:UIView, sideBarItems:Array<String>) {
        super.init()
        //origin view is the source view 
        originView = sourceView
        sideBarTableViewController.tableData = sideBarItems
        
        // Sets up side bar manu before adding gestures
        setUpSideBarMenu()
        
        // Origin view is where animation occurs
        animator = UIDynamicAnimator(referenceView: originView)
        
        // Right swipe gesture displays menu
        let displayGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(manageSwipe))
        originView.addGestureRecognizer(displayGestureRecognizer)
        
        // Left swipe hides gesture side menu
        let hideGestureRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(manageSwipe))
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        originView.addGestureRecognizer(hideGestureRecognizer)
    }
    
    // Sets up side bar menu function with no parameters
    func setUpSideBarMenu() {
        // Adds frame to side bar menu
        sideBarContainerView.frame = CGRectMake(-barWidth-1, originView.frame.origin.y, barWidth, originView.frame.size.height)
       // sideBarContainerView.frame = CGRectMake(400, originView.frame.origin.y, barWidth, originView.frame.size.height)

        // Background color of side bar menu
        sideBarContainerView.backgroundColor = UIColor.grayColor()
       
        // Confines subviews to bounds of the view
        sideBarContainerView.clipsToBounds = false
        
        originView.addSubview(sideBarContainerView)
        
        // Adds blur to the side bar menu
        let blurSideBarView:UIVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.Light))
        
        // Adds frame to blue view 
        blurSideBarView.frame = sideBarContainerView.bounds
        sideBarContainerView.addSubview(blurSideBarView)
        
        sideBarTableViewController.delegate = self
        sideBarTableViewController.tableView.frame = sideBarContainerView.bounds
        sideBarTableViewController.tableView.clipsToBounds = false

        // The style for cells used as separators. None in our side bar menu
        sideBarTableViewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        sideBarTableViewController.tableView.backgroundColor = UIColor.clearColor()
        
        // Deactivates scroll-to-top gesture
        sideBarTableViewController.tableView.scrollsToTop = false
        // Sets edge insets from scroll view
        sideBarTableViewController.tableView.contentInset = UIEdgeInsetsMake(sideBarTableViewTopInset, 0, 0, 0)
        
        // Reloads side bar menu
        sideBarTableViewController.tableView.reloadData()
        sideBarContainerView.addSubview(sideBarTableViewController.tableView)
        
        // Initialize button
        let logoutButton = UIButton()
        
        // Set up button properties and size
        logoutButton.setTitle("Logout", forState: .Normal)
        logoutButton.setTitleColor(UIColor.blueColor(), forState: .Normal)
        let size:CGSize = logoutButton.intrinsicContentSize()
        logoutButton.frame = CGRectMake(0, 0, size.width, size.height)
        
        // Add target function for button
        logoutButton.addTarget(self, action: #selector(SideBar.pressed(_:)), forControlEvents: .TouchUpInside)
        
        // Add button to container view
        sideBarContainerView.addSubview(logoutButton)
        
        // Add constraints to button with padding
        let padding:CGFloat = 10
        logoutButton.translatesAutoresizingMaskIntoConstraints = false;
        logoutButton.leftAnchor.constraintEqualToAnchor(sideBarContainerView.leftAnchor, constant: padding).active = true
        logoutButton.bottomAnchor.constraintEqualToAnchor(sideBarContainerView.bottomAnchor, constant: -(sideBarTableViewTopInset + padding)).active = true
        self.sideBarContainerView.layoutIfNeeded()
    
    }
    
    func pressed(sender: UIButton!) {
        print("Logout successful")
        
        // Add logout functionality here
        
    }
    
    // Function manages swipe gesture 
    func manageSwipe(recognizer:UISwipeGestureRecognizer) {
        
        // Checks which direction swipe occurs 
        if recognizer.direction == UISwipeGestureRecognizerDirection.Left {
        //if recognizer.direction == UISwipeGestureRecognizerDirection.Right {
             // Hide side bar menu
            showSideBarMenu(false)
            
            // Call on optional delegate to show side bar menu
            delegate?.sideBarWillClose?()
            
        } else {
            // Show side bar menu
            showSideBarMenu(true)
            
            // Call on optinoal delegate to hide side bar menu
            delegate?.sideBarWillOpen?()
        }
    }
    
    // Bool function checks to see if side bar should be open
    func showSideBarMenu(shouldOpen:Bool) {
        
        // First remove all animators from dynamic animators
        animator.removeAllBehaviors()
        
        // Logic defines direction of animation
        isSideBarOpen = shouldOpen
        
        // If menu should open, gravity of animation --> float = 0.5 else float = -0.5
        let gravityOfXCoordinate:CGFloat = (shouldOpen) ? 0.5 : -0.5
        //let gravityOfXCoordinate:CGFloat = (shouldOpen) ? -0.5 : 0.5

        
        // If menu should open, magnitude of animation --> flaot = 20.0 else flaot = -20.0
        let magnitudeOfTheGavityOnPull:CGFloat = (shouldOpen) ? 20.0  : -20.0
        //let magnitudeOfTheGavityOnPull:CGFloat = (shouldOpen) ? -20.0  : 20.0

        // Defines boundaries of the side bar menu and its collision with the main view
        let boundaryX:CGFloat = (shouldOpen) ? barWidth : -barWidth-1 
        //let boundaryX:CGFloat = (shouldOpen) ? 250 : -barWidth-1


        
        // Initializes gravity behavior with an array of dynamic items
        let gravityBehavior:UIGravityBehavior = UIGravityBehavior (items:[sideBarContainerView])
        
        // Direction of gravity behavior on items 
        gravityBehavior.gravityDirection = CGVectorMake(gravityOfXCoordinate, 0)
        animator.addBehavior(gravityBehavior) // right/left bouncing
        
        // Handles collision with main view
        let collisionBehavior: UICollisionBehavior = UICollisionBehavior (items: [sideBarContainerView])
        collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake( boundaryX, 20), toPoint: CGPointMake(boundaryX, originView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        // Instantaneous push behavior on magnitude
        let pushBehavior:UIPushBehavior = UIPushBehavior(items:[sideBarContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = magnitudeOfTheGavityOnPull
        animator.addBehavior(pushBehavior)
        
        // Adds dynamic behavior to side bar menu
        let sideBarBehavior:UIDynamicItemBehavior = UIDynamicItemBehavior(items:[sideBarContainerView])
        sideBarBehavior.elasticity = 0.3
        animator.addBehavior(sideBarBehavior)

    }
    
    func sideBarControlDidSelectRow(indexPath: NSIndexPath) {
        // When user selects button at indexPath.row
        delegate?.didSelectButtonAtIndex(indexPath.row)
    }
}