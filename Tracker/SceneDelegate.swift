//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Adilkhan on 10/10/26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private let coreDataStack = CoreDataStack()
    private let onboardingShownKey = "isOnboardingShown"

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = makeRootViewController()
        window?.makeKeyAndVisible()
    }

    private func makeRootViewController() -> UIViewController {
        guard !UserDefaults.standard.bool(forKey: onboardingShownKey) else {
            return TabBarController(coreDataStack: coreDataStack)
        }

        let onboardingViewController = OnboardingViewController()
        onboardingViewController.onFinish = { [weak self] in
            self?.finishOnboarding()
        }
        return onboardingViewController
    }

    private func finishOnboarding() {
        guard let window else { return }
        UserDefaults.standard.set(true, forKey: onboardingShownKey)
        window.rootViewController = TabBarController(coreDataStack: coreDataStack)
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        coreDataStack.saveContext()
    }


}

