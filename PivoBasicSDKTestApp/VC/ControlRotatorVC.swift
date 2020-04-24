//
//  ControlRotatorVC.swift
//
//
//  Created by Tuan on 2020/02/21.
//  Copyright © 2020 3i. All rights reserved.
//

import UIKit
import PivoBasicSDK

class ControlRotatorVC: UIViewController {

  static func storyboardInstance() -> ControlRotatorVC? {
    let storyboard = UIStoryboard(name: String(describing: ControlRotatorVC.self), bundle: nil)
    return storyboard.instantiateInitialViewController() as? ControlRotatorVC
  }
  
  @IBOutlet weak var labelBatteryLevel: UILabel!
  @IBOutlet weak var labelCommand: UILabel!
  @IBOutlet weak var tfAngle: UITextField!
  @IBOutlet weak var buttonSpeed: UIButton!
  
  private lazy var pivoSDK = PivoBasicSDK.shared
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    pivoSDK.addDelegate(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    pivoSDK.removeDelegate(self)
    pivoSDK.disconnect()
  }
  
  private func setupView() {
    let supportedSpeeds = pivoSDK.getSupportedSpeedsInSecondsPerRound()
    guard supportedSpeeds.count > 0 else { return }
    let maxSpeed = supportedSpeeds[0]
    buttonSpeed.setTitle("\(maxSpeed) s/r", for: .normal)
    pivoSDK.setFastestSpeed()
  }
  
  @IBAction func didRotateLeftByDegreeButtonClicked(_ sender: Any) {
    resignResponder()
    if let angleStr = tfAngle.text, let angle = Int(angleStr) {
      pivoSDK.turnLeft(angle: angle)
    }
  }
  
  @IBAction func didRotateRightByDegreeButtonClicked(_ sender: Any) {
    resignResponder()
    if let angleStr = tfAngle.text, let angle = Int(angleStr) {
      pivoSDK.turnRight(angle: angle)
    }
  }
  
  @IBAction func didRotateLeftContinouslyButtonClicked(_ sender: Any) {
    resignResponder()
    pivoSDK.turnLeftContinuously()
  }
  
  @IBAction func didRotateRightContinouslyButtonClicked(_ sender: Any) {
    resignResponder()
    pivoSDK.turnRightContinuously()
  }
  
  @IBAction func didStopButtonClicked(_ sender: Any) {
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
  
  private func resignResponder() {
    tfAngle.resignFirstResponder()
  }
}

extension ControlRotatorVC {
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
}

extension ControlRotatorVC: PivoConnectionDelegate {
  
  func pivoConnectionDidRotate() {
    labelCommand.text = "ROTATED"
  }
  
  func pivoConnection(remoteControlerCommandReceived command: PivoEvent) {
    labelCommand.text = "\(command)"
  }
  
  func pivoConnection(batteryLevel: Int) {
    labelBatteryLevel.text = "Battery Level: \(batteryLevel)%"
  }
  
  func pivoConnection(didDisconnect id: String) {
    navigationController?.popViewController(animated: true)
  }
  
}
