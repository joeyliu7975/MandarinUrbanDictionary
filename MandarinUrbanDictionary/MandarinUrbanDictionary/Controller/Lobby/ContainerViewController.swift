//
//  ContainerViewController.swift
//  MandarinUrbanDictionary
//
//  Created by Joey Liu on 11/30/20.
//

import UIKit

class ContainerViewController: UIViewController {
    
    var centerNavigationController: UINavigationController!
    
    var centerViewController: LobbyViewController!
    
    var currentState: SlideOutState = .center
    
    var leftViewController: SidePanelViewController?
    
    var centerPanelExpandedOffset: CGFloat {
        return UIScreen.main.bounds.width * 0.217
    }
    
    lazy var maskView: UIView = {
        let maskView = UIView(frame: self.centerNavigationController.view.frame)
        
        maskView.backgroundColor = UIColor.transparentBlack
        
        maskView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCoverView))
        
        maskView.addGestureRecognizer(tapGesture)
        
        return maskView
    }()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setup()
        
    }
    
    @objc func tapCoverView() {
        
        toggleLeftPanel()
        
        currentState = .center
        
        maskView.removeFromSuperview()
    }
}

private extension ContainerViewController {
    
    func setup() {
        
        centerViewController = LobbyViewController()
        
        centerViewController.delegate = self
        
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        
        centerNavigationController.navigationBar.shadowImage = UIImage()
        
        view.addSubview(centerNavigationController.view)
        
        addChild(centerNavigationController)
        
        centerNavigationController.didMove(toParent: self)
    
        centerViewController.triggerSideMenu = {
            self.toggleLeftPanel()
        }
        
        overrideUserInterfaceStyle = .light
    }
    
    func setupNavigationController() {
        
        self.navigationItem.setBarAppearance(color: .clear)
        
    }
}

extension ContainerViewController: CenterViewControllerDelegate {
    
    func writeNewWord(_ existedWords: [Word]) {
        
        let addNewWordVC = AddNewWordViewController()
        
        addNewWordVC.viewModel.existedWordTitles = existedWords.map { $0.title }
        
        present(addNewWordVC, animated: true)
    }
    
    func toggleLeftPanel() {
        
        let notAlreadyExpanded = (currentState != .leftPanelExpanded)
        
        if notAlreadyExpanded {
            
            currentState = .leftPanelExpanded
            
            self.centerNavigationController?.view.addSubview(maskView)
            
            addLeftPanelViewController()
            
        }
        
        animateLeftPanel(shouldExpand: notAlreadyExpanded)
    }
    
    func addLeftPanelViewController() {
        
        guard leftViewController == nil else { return }
        
        let sidePanelVC = SidePanelViewController()
        
        sidePanelVC.delegate = self
        
        addChildSidePanelController(sidePanelVC)
        
        leftViewController = sidePanelVC
    }
    
    func addChildSidePanelController(_ sidePanelController: SidePanelViewController) {
        
        view.insertSubview(sidePanelController.view, at: 0)
        
        addChild(sidePanelController)
        
        sidePanelController.didMove(toParent: self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        
        switch shouldExpand {
        
        case true:
            
            currentState = .leftPanelExpanded
            
            animateCenterPanelXPosition(
                targetPosition: centerNavigationController.view.frame.width
                    - centerPanelExpandedOffset
            )
            
        case false:
            
            animateCenterPanelXPosition(targetPosition: 0) { _ in
                
                self.currentState = .center
                
                self.leftViewController?.view.removeFromSuperview()
                
                self.leftViewController = nil
            }
            
        }
    }
    
    func animateCenterPanelXPosition(
        targetPosition: CGFloat,
        completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: .curveEaseInOut,
            animations: {
                self.centerNavigationController.view.frame.origin.x = targetPosition
            },
            completion: completion
        )
    }
}

extension ContainerViewController: LeftViewControllerDelegate {
    
    func navigate(to page: SidePanel) {
        
        animateLeftPanel(shouldExpand: false)
        
        var destinationVC: UIViewController?
        
        currentState = .center
        
        maskView.removeFromSuperview()
        
        switch page {
        
        case .homePage:
            
            centerNavigationController.popToRootViewController(animated: true)
        
        case .dailySlang:
            
            destinationVC = DailyWordViewController()
            
            if let desVC = destinationVC as? DailyWordViewController {
                desVC.triggerSideMenu = {
                    self.toggleLeftPanel()
                }
            }
            
        case .top5:
            
            destinationVC = RankViewController()
            
            if let desVC = destinationVC as? RankViewController {
                desVC.triggerSideMenu = {
                    self.toggleLeftPanel()
                }
            }
            
        case .favorite:
            
            destinationVC = FavoriteViewController()
            
            if let desVC = destinationVC as? FavoriteViewController {
                
                desVC.triggerSideMenu = {
                    self.toggleLeftPanel()
                }
                
                desVC.setNavigationBarTitle(title: "我的最愛")
            }
            
        case .recents:
            
            destinationVC = FavoriteViewController()
            
            if let desVC = destinationVC as? FavoriteViewController {
                
                desVC.triggerSideMenu = {
                    self.toggleLeftPanel()
                }
                
                desVC.setNavigationBarTitle(title: "歷史紀錄")
            }
        case .achievement:
            
            destinationVC = AchievementViewController()
            
            if let desVC = destinationVC as? AchievementViewController {
                
                desVC.triggerSideMenu = {
                    self.toggleLeftPanel()
                }
            }
        }
        
        guard let desVC = destinationVC else { return }
        
        centerNavigationController.pushViewController(desVC, animated: true)
    }
}

enum SlideOutState: Equatable {
    
    case center
    
    case leftPanelExpanded
}
