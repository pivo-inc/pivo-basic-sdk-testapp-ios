//
//  ControlPivoVC.swift
//
//
//  Created by Tuan on 2020/02/21.
//  Copyright © 2020 3i. All rights reserved.
//

import UIKit
import PivoBasicSDK

class ControlPivoVC: UIViewController {

  static func storyboardInstance() -> ControlPivoVC? {
    let storyboard = UIStoryboard(name: String(describing: ControlPivoVC.self), bundle: nil)
    return storyboard.instantiateInitialViewController() as? ControlPivoVC
  }
  
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var labelBatteryLevel: UILabel!
  @IBOutlet weak var labelCommand: UILabel!
  @IBOutlet weak var tfAngle: UITextField!
  @IBOutlet weak var buttonSpeed: UIButton!
  @IBOutlet weak var bypassSwitch: UISwitch!
    
    private var oneDegreeRotateLeftCount: Int = 0
    private var oneDegreeRotateRightCount: Int = 0
    
  private lazy var pivoSDK = PivoSDK.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    pivoSDK.addDelegate(self)
    setPivoFastestSpeed()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    pivoSDK.removeDelegate(self)
    setPivoFastestSpeed()
  }
  
  private func setupView() {
    let supportedSpeeds = pivoSDK.getSupportedSpeedsInSecondsPerRound()
    guard supportedSpeeds.count > 0 else { return }
    let maxSpeed = supportedSpeeds[0]
    buttonSpeed.setTitle("\(maxSpeed) s/r", for: .normal)
    setPivoFastestSpeed()
    
    scrollView.keyboardDismissMode = .onDrag
    didToggleByPassRCChanged(bypassSwitch)
  }
  
  private func setPivoFastestSpeed() {
    pivoSDK.setFastestSpeed()
  }
  
  @IBAction func didRotateLeftByDegreeButtonClicked(_ sender: Any) {
      resetOneDegreeRotateCount()
    resignResponder()
    if let angleStr = tfAngle.text, var angle = Int(angleStr) {
      angle = angle > 360 ? 360 : angle
      tfAngle.text = "\(angle)"
      pivoSDK.turnLeft(angle: angle)
      do {
        try pivoSDK.turnLeftWithFeedback(angle: angle)
      }
      catch {
        pivoSDK.turnLeft(angle: angle)
      }
    }
  }
  
  @IBAction func didRotateRightByDegreeButtonClicked(_ sender: Any) {
      resetOneDegreeRotateCount()
    resignResponder()
    if let angleStr = tfAngle.text, var angle = Int(angleStr) {
      angle = angle > 360 ? 360 : angle
      tfAngle.text = "\(angle)"
      do {
        try pivoSDK.turnRightWithFeedback(angle: angle)
      }
      catch {
        pivoSDK.turnRight(angle: angle)
      }
    }
  }
  
  @IBAction func didRotateLeftContinouslyButtonClicked(_ sender: Any) {
      resetOneDegreeRotateCount()
    resignResponder()
    pivoSDK.turnLeftContinuously()
  }
  
  @IBAction func didRotateRightContinouslyButtonClicked(_ sender: Any) {
      resetOneDegreeRotateCount()
    resignResponder()
    pivoSDK.turnRightContinuously()
  }
  
  @IBAction func didStopButtonClicked(_ sender: Any) {
      resetOneDegreeRotateCount()
    resignResponder()
    pivoSDK.stop()
  }
  
  @IBAction func didSpeedButtonClicked(_ sender: Any) {
    resignResponder()
    openSpeedPickerView()
  }
  
  @IBAction func didChangeRotatornameButtonClicked(_ sender: Any) {
    resignResponder()
    showChangeRotatorName()
  }
  
  @IBAction func didRefreshBatteryLevelButtonClicked(_ sender: Any) {
    resignResponder()
    pivoSDK.requestBatteryLevel()
  }
  
  @IBAction func didGetPivoVersionButtonClicked(_ sender: Any) {
    resignResponder()
    let version = pivoSDK.getPivoVersion()
    labelCommand.text = "Pivo Version: \(version)"
  }
  
  @IBAction func didDisconnectButtonClicked(_ sender: Any) {
    resignResponder()
    pivoSDK.disconnect()
    navigationController?.popViewController(animated: true)
  }
  
  
  @IBAction func didToggleByPassRCChanged(_ sender: UISwitch) {
    do {
      guard try pivoSDK.isByPassRemoteControllerSupported() else {
        return
      }
        
      print("bypass is \(sender.isOn)")
      sender.isOn ? pivoSDK.turnOnByPassRemoteController() : pivoSDK.turnOffBypassRemoteController()
//      sender.isOn ? pivoConnectionByPassRemoteControllerOn() : pivoConnectionByPassRemoteControllerOff()
    }
    catch {
      print(error)
    }
  }
    @IBAction func didToggleNotifierRCChanged(_ sender: UISwitch) {
        do {
            guard try pivoSDK.isNotifierSupported() else {
                return
            }
            
            print("notifier is \(sender.isOn)")
            sender.isOn ? pivoSDK.turnOnNotifier() : pivoSDK.turnOffNotifier()
        }
        catch {
            print(error)
        }
    }
    
  private func resignResponder() {
    tfAngle.resignFirstResponder()
  }
}

extension ControlPivoVC {
  private func showChangeRotatorName() {
    let alertController = UIAlertController(title: "Change Rotator's Name", message: "Please enter new name for rotator", preferredStyle: .alert)
    
    alertController.addTextField { (textField) in
      textField.placeholder = "New rotator's name"
    }
    
    let changeAction = UIAlertAction(title: "Change", style: .default) { (_) in
      if let textFields = alertController.textFields,
        let name = textFields[0].text,
        !name.isEmpty {
        self.pivoSDK.changePivoName(newName: name)
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    
    alertController.addAction(changeAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true, completion: nil)
  }
  
  private func openSpeedPickerView() {
    let alert = UIAlertController(title: "Select Speed", message: nil, preferredStyle: .actionSheet)
    
    let speeds = pivoSDK.getSupportedSpeedsInSecondsPerRound()
    
    let frameSizes: [Int] = speeds
    let pickerViewValues: [[String]] = [frameSizes.map { "\($0)" }]
    let pickerViewSelectedValue: PickerViewViewController.Index = (column: 0, 0)
    
    alert.addPickerView(values: pickerViewValues, initialSelection: pickerViewSelectedValue) { [weak self] vc, picker, index, values in
      guard let strongSelf = self else { return }
      strongSelf.buttonSpeed.setTitle("\(speeds[index.row]) s/r", for: .normal)
      strongSelf.pivoSDK.setSpeedBySecondsPerRound(speeds[index.row])
    }
    
    alert.addAction(title: "Done", style: .cancel)
    
    if let popoverController = alert.popoverPresentationController {
      popoverController.sourceView = self.view
      popoverController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.maxY, width: 0, height: 0)
    }
    
    DispatchQueue.main.async { [weak self] in
      self?.present(alert, animated: true, completion: nil)
    }
  }
    
    private func resetOneDegreeRotateCount() {
        oneDegreeRotateLeftCount = 0
        oneDegreeRotateRightCount = 0
    }
}

extension ControlPivoVC: PivoConnectionDelegate {
  
  func pivoConnectionDidRotate() {
    labelCommand.text = "ROTATED"
  }
  
  func pivoConnection(remoteControlerCommandReceived command: PivoEvent) {
    labelCommand.text = "\(command)"
  }
  
  func pivoConnectionByPassRemoteControllerOn() {
    labelCommand.text = "By Pass Remote Controller On"
  }
  
  func pivoConnectionByPassRemoteControllerOff() {
    labelCommand.text = "By Pass Remote Controller Off"
  }
    
    func pivoConnectionNotifierOn() {
        labelCommand.text = "1 Degree Rotate Notifier On"
    }
     
    func pivoConnectionNotifierOff() {
        labelBatteryLevel.text = "Battery Level:"
        labelCommand.text = "1 Degree Rotate Notifier turned Off"
    }
    
    func pivoConnectionDidRotate1DegreeLeft() {
        oneDegreeRotateLeftCount += 1
        labelBatteryLevel.text = "Rotated 1 Degree Left: \(oneDegreeRotateLeftCount)"
    }
    
    func pivoConnectionDidRotate1DegreeRight() {
        oneDegreeRotateRightCount += 1
        labelBatteryLevel.text = "Rotated 1 Degree Right: \(oneDegreeRotateRightCount)"
    }
  
  func pivoConnection(batteryLevel: Int) {
    labelBatteryLevel.text = "Battery Level: \(batteryLevel)%"
      labelCommand.text = "BATTERY_CHANGED"
  }
  
  func pivoConnection(didDisconnect id: String) {
    navigationController?.popViewController(animated: true)
  }
  
  func pivoConnectionBluetoothPermissionDenied() {
    print("Permission denied")
  }
  
}
