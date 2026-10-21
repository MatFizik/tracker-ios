//
//  NavigationBarController.swift
//  Tracker
//
//  Created by Adilkhan on 21/10/26.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            makeTab(controller: TrackerViewController(), title: "Трекер", imageName: "circle_icon"),
            makeTab(controller: StatisticsViewController(), title: "Статистика", imageName: "rabbit_icon")
        ]
        
    }
    
    private func makeTab (controller: UIViewController, title: String, imageName: String) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: imageName),
            selectedImage: nil
        )
        return navigationController
    }
}
