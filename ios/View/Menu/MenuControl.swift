//
//  MenuControl.swift
//  MenuTest
//
//  Created by Konrad Fischer on 13.01.18.
//  Copyright © 2018 Konrad Fischer. All rights reserved.
//

import UIKit

class MenuControl: UIStackView {
    
    private var menuButtons = [UIButton]()
    private let numberOfButtons = 5
    
    private var vc:UIViewController
    
    override init(frame: CGRect) {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "Home")
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "Home")
        super.init(coder: coder)
        
        setupButtons()
    }
    
    private func setupButtons() {
        let bundle = Bundle(for: type(of: self))
        
        let emptyStar = UIImage(named:"emptyStar", in: bundle, compatibleWith: self.traitCollection)
        
        for index in 0..<numberOfButtons {
            // Create the button
            let button = UIButton()
            //button.backgroundColor = UIColor.red
            
            switch index {
            case 0:
                //button.setTitle("Home" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.firstButtonTapped(button:)), for: .touchUpInside)
            case 1:
                //button.setTitle("just" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.secondButtonTapped(button:)), for: .touchUpInside)
            case 2:
                //button.setTitle("a" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.thirdButtonTapped(button:)), for: .touchUpInside)
            case 3:
                //button.setTitle("button" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.fourthButtonTapped(button:)), for: .touchUpInside)
            case 4:
                //button.setTitle("button" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.fifthButtonTapped(button:)), for: .touchUpInside)
            default:
                //button.setTitle("default" + String(index), for: .normal)
                button.addTarget(self, action: #selector(MenuControl.firstButtonTapped(button:)), for: .touchUpInside)
            }
            
            button.setImage(emptyStar, for: .normal)

            
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            //button.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
            //button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            // Add the button to the stack
            addArrangedSubview(button)
            
            menuButtons.append(button)
        }
    }
    
    @objc func firstButtonTapped(button: UIButton) {
        if let topController = getTopmostViewController() {
            let storyboard = UIStoryboard(name: "HomePage", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Home")
            topController.present(vc, animated: true, completion: nil)
        }

    }
    
    @objc func secondButtonTapped(button: UIButton) {
        if let topController = getTopmostViewController() {
            let storyboard = UIStoryboard(name: "Search", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SearchNavigation")
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func thirdButtonTapped(button: UIButton) {
        if let topController = getTopmostViewController() {
            let storyboard = UIStoryboard(name: "ChatStoryboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ChatNavigation")
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func fourthButtonTapped(button: UIButton) {
        if let topController = getTopmostViewController() {
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Profile")
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    @objc func fifthButtonTapped(button: UIButton) {
        if let topController = getTopmostViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "chatbot")
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    private func getTopmostViewController() -> UIViewController? {
        // adapted from https://stackoverflow.com/a/26667122/1501019
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
    
    
    
}

