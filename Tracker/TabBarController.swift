//
//  TabBarController.swift
//  Tracker
//
//  Created by Adilkhan on 21/10/26.
//

import UIKit

final class TabBarController: UITabBarController {
    private let coreDataStack: CoreDataStack

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        viewControllers = [
            makeTab(
                controller: TrackersViewController(coreDataStack: coreDataStack),
                title: "Трекеры",
                imageName: "circle_icon"
            ),
            makeTab(controller: StatisticsViewController(), title: "Статистика", imageName: "rabbit_icon")
        ]
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor.ypBlue
    }

    private func makeTab(controller: UIViewController, title: String, imageName: String) -> UINavigationController {
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
