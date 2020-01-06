//
//  OrientationViewController.swift
//  Timesheets
//
//  Created by Paul Kirvan on 2015-01-05.
//
//

import Foundation
import UIKit

final class OrientationViewController: UITabBarController, UITabBarControllerDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        delegate = self
    }
    
    override func encodeRestorableState(with coder: NSCoder)
    {
        coder.encode(selectedIndex, forKey: "SelectedTab")
    }
    
    override func decodeRestorableState(with coder: NSCoder)
    {
        let index = coder.decodeInteger(forKey: "SelectedTab")
        selectedIndex = index
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        regularFormat = (view.frame.width * view.frame.height) >= 500000 ? true : false

        let oldControllers = viewControllers ?? [UIViewController]()
        var newControllers = [UIViewController]()

        if regularFormat
        {
            for controller in oldControllers
            {
                if controller is iPadRootViewController
                {
                    newControllers.append(controller)
                }
            }
            
            tabBar.isHidden = true
        }

        else
        {
            for controller in oldControllers
            {
                if !(controller is iPadRootViewController)
                {
                    newControllers.append(controller)
                }
            }
        }
        
        viewControllers = newControllers
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator)
    {
        regularFormat = (size.width * size.height) >= 500000 ? true : false
        
        if regularFormat
        {
            if viewControllers?.count != 1
            {
                tabBar.isHidden = true
                var newControllers = [UIViewController]()
                newControllers.append(storyboard!.instantiateViewController(withIdentifier: "LandscapeRootViewController"))
                setViewControllers(newControllers, animated: true)
            }
        }
        
        else
        {
            if viewControllers?.count != 4
            {
                tabBar.isHidden = false
                var newControllers = [UIViewController]()
                newControllers.append(getViewController(from: "ChangeUnit", withIdentifier: "Change Unit"))
                newControllers.append(storyboard!.instantiateViewController(withIdentifier: "PilotsTab"))
                newControllers.append(storyboard!.instantiateViewController(withIdentifier: "RecordsTab"))
                newControllers.append(getViewController(from: "Aircraft", withIdentifier: "AircraftTab"))
                setViewControllers(newControllers, animated: true)
            }
        }
        
        for controller in viewControllers!
        {
            controller.viewWillTransition(to: size, with: coordinator)
        }
    }
}
