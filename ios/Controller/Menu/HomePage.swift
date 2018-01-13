//
//  HomePage.swift
//  ios
//
//  Created by Konrad Fischer on 13.01.18.
//  Copyright © 2018 Hila Safi. All rights reserved.
//

import UIKit
import InteractiveSideMenu

class HomePage: MenuContainerViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.transitionOptions = TransitionOptions(duration: 0.4, visibleContentWidth: screenSize.width / 6)
        
        // Instantiate menu view controller by identifier
        let tmptoryboard = UIStoryboard(name: "Main", bundle: nil)
        self.menuViewController = tmptoryboard.instantiateViewController(withIdentifier: "NavigationMenu") as! NavigationMenuViewController

        
        // Gather content items controllers
        self.contentViewControllers = contentControllers()
        
        // Select initial content controller. It's needed even if the first view controller should be selected.
        self.selectContentViewController(contentViewControllers.first!)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        /*
         Options to customize menu transition animation.
         */
        var options = TransitionOptions()
        
        // Animation duration
        options.duration = size.width < size.height ? 0.4 : 0.6
        
        // Part of item content remaining visible on right when menu is shown
        options.visibleContentWidth = size.width / 6
        self.transitionOptions = options
    }
    
    private func contentControllers() -> [UIViewController] {
        let controllersIdentifiers = ["Profile","Search"]
        var contentList = [UIViewController]()
        
        /*
         Instantiate items controllers from storyboard.
         */
        
        let profileStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileViewController = profileStoryboard.instantiateViewController(withIdentifier: "Home")
        contentList.append(profileViewController)
        
        let searchStoryboard = UIStoryboard(name: "Search", bundle: nil)
        let searchViewController = searchStoryboard.instantiateViewController(withIdentifier: "SearchNavigation")
        contentList.append(searchViewController)

        /* for identifier in controllersIdentifiers {
            if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier) {
                contentList.append(viewController)
            }
        } */
        
        return contentList
    }
}
