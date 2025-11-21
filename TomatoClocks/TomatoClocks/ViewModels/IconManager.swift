import SwiftUI
import Combine

class IconManager: ObservableObject {
    static let shared = IconManager()
    
    func updateAppIcon(for colorScheme: ColorScheme) {
        // NOTE: For this to work, you must configure 'CFBundleIcons' in your Info.plist
        // and include the icon files (AppIcon-Dark, AppIcon-Light) in your project bundle (not just Assets).
        // However, iOS 18 handles this automatically if Assets.xcassets is configured correctly.
        
        let currentIcon = UIApplication.shared.alternateIconName
        
        if colorScheme == .dark {
            // Attempt to switch to Dark icon
            // The icon name "AppIcon-Dark" must be defined in Info.plist
            if currentIcon != "AppIcon-Dark" {
                UIApplication.shared.setAlternateIconName("AppIcon-Dark") { error in
                    if let error = error {
                        print("Error switching to Dark icon: \(error.localizedDescription)")
                    } else {
                        print("Switched to Dark icon")
                    }
                }
            }
        } else {
            // Switch back to Primary (Light) icon
            if currentIcon != nil {
                UIApplication.shared.setAlternateIconName(nil) { error in
                    if let error = error {
                        print("Error switching to Light icon: \(error.localizedDescription)")
                    } else {
                        print("Switched to Light icon")
                    }
                }
            }
        }
    }
}
