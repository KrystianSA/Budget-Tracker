import UIKit
import SwiftUI

func setupAppearance() {
    let nav = UINavigationBarAppearance()
    nav.configureWithOpaqueBackground()
    nav.backgroundColor = UIColor.named("surface/card", fallback: .white)
    nav.titleTextAttributes = [
        .foregroundColor: UIColor.named("text/primary", fallback: .black)
    ]
    nav.shadowColor = UIColor.named("border/muted", fallback: .systemGray5)

    UINavigationBar.appearance().standardAppearance = nav
    UINavigationBar.appearance().scrollEdgeAppearance = nav
    UINavigationBar.appearance().tintColor = UIColor.named("primary/600")

    let tab = UITabBarAppearance()
    tab.configureWithOpaqueBackground()
    tab.backgroundColor = UIColor.named("surface/base", fallback: .white)
    tab.stackedLayoutAppearance.selected.iconColor = UIColor.named("primary/600")
    tab.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.named("primary/700")]
    UITabBar.appearance().standardAppearance = tab
    UITabBar.appearance().scrollEdgeAppearance = tab
}



