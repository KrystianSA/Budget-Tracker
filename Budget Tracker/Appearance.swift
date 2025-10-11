import UIKit

func setupAppearance() {
    let nav = UINavigationBarAppearance()
    nav.configureWithOpaqueBackground()
    nav.backgroundColor = UIColor(named: "surface/card", in: .main, compatibleWith: nil)
    nav.titleTextAttributes = [
        .foregroundColor: UIColor(named: "text/primary", in: .main, compatibleWith: nil) ?? .black
    ]
    nav.shadowColor = UIColor(named: "border/muted", in: .main, compatibleWith: nil)

    UINavigationBar.appearance().standardAppearance = nav
    UINavigationBar.appearance().scrollEdgeAppearance = nav
    UINavigationBar.appearance().tintColor = UIColor(named: "primary/600")

    let tab = UITabBarAppearance()
    tab.configureWithOpaqueBackground()
    tab.backgroundColor = UIColor(named: "surface/base", in: .main, compatibleWith: nil)
    tab.stackedLayoutAppearance.selected.iconColor = UIColor(named: "primary/600", in: .main, compatibleWith: nil)
    if let primary700 = UIColor(named: "primary/700", in: .main, compatibleWith: nil) {
        tab.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: primary700]
    }
    UITabBar.appearance().standardAppearance = tab
    UITabBar.appearance().scrollEdgeAppearance = tab
}



