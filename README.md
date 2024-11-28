# Pivo basic SDK iOS test application

An iOS application that uses PivoBasicSDK to connect and control the Pivo Pod.

## Before you begin

Please visit [Pivo developer website](https://developer.pivo.app/) and generate the license file to include it into your project. 

## Installation

#### CocoaPods
In your pod file, add this:

```
pod 'PivoBasicSDK', :git => 'https://github.com/pivo-inc/pivo-basic-sdk-ios.git', :tag => '1.0.3'
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

## Changelogs

In version 1.0.3:
- Add Notifier for `1 degree rotate(right/left)`
- Add Pivo Max remote control commands

In version 1.0.2:
- Remove 3rd party framework
- Change `PodConnectionDelegate` to `PivoConnectionDelegate`

In version 1.0.1:
- Support Pivo Max
- Fix third-party framework build error

In version 0.0.8:
- Change class name from `PivoBasicSDK` to `PivoSDK` to prevent an error
- Support new Pivo types
- Build with Swift 5.5
- In order to get `Rotated` feedback when rotates Pivo, please make sure to use `turnLeftWithFeedback` and `turnRightWithFeedback` with speed from `getSupportedSpeedsByRemoteControllerInSecoundsPerRound`
