import UIKit
import SwiftUI

func setupAppearance() {
    let nav = UINavigationBarAppearance()
    nav.configureWithOpaqueBackground()
    nav.backgroundColor = UIColor.app("surface/card")
    nav.titleTextAttributes = [
        .foregroundColor: UIColor.app("text/primary")
    ]
    nav.shadowColor = UIColor.app("border/muted")

    UINavigationBar.appearance().standardAppearance = nav
    UINavigationBar.appearance().scrollEdgeAppearance = nav
    UINavigationBar.appearance().tintColor = UIColor.app("primary/600")

    let tab = UITabBarAppearance()
    tab.configureWithOpaqueBackground()
    tab.backgroundColor = UIColor.app("surface/base")
    tab.stackedLayoutAppearance.selected.iconColor = UIColor.app("primary/600")
    tab.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.app("primary/700")]
    UITabBar.appearance().standardAppearance = tab
    UITabBar.appearance().scrollEdgeAppearance = tab
}



