//
//  SceneDelegate.swift
//  async-recipes
//
//  Created by William Towe on 12/27/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    // MARK: - UIWindowSceneDelegate
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {
            return
        }
        self.window = UIWindow(windowScene: windowScene).also {
            $0.rootViewController = UINavigationController(rootViewController: ViewController(style: .insetGrouped))
            $0.makeKeyAndVisible()
        }
    }
}

