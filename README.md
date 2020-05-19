# Pivo basic SDK iOS test application

An iOS application that uses PivoBasicSDK to connect and control the Pivo Pod.

## Before you begin

Please visit [Pivo developer website](https://developer.pivo.app/) and generate the license file to include it into your project. 

## Installation

#### CocoaPods
In your pod file, add this:

```
pod 'PivoBasicSDK'
```
## Usage

In your AppDelegate.swift

```swift
//...
import PivoBasicSDK

class AppDelegate: UIResponder, UIApplicationDelegate {
{
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Override point for customization after application launch.
      
      if let licenseFileURL = Bundle.main.url(forResource: "licenseKey", withExtension: "json") {
        do {
          try PivoBasicSDK.shared.unlockWithLicenseKey(licenseKeyFileURL: licenseFileURL)
        }
        catch {
          print(error)
        }
      }
      
      return true
    }

//...
}
```

## Report
If you encounter an issue during setting up the sdk, please contact us at app@3i.ai or open an issue.
