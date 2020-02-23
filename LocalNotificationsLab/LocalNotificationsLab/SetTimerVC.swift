//
//  ViewController.swift
//  LocalNotificationsLab
//
//  Created by casandra grullon on 2/23/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit

protocol CreateTimerDelegate: AnyObject {
    func didCreateTimer(_ setTimerVC: SetTimerVC)
}

class SetTimerVC: UIViewController {

    @IBOutlet weak var timerTitle: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5
    weak var delegate: CreateTimerDelegate?
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(tapGesture(sender:)))
        return gesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDatePicker()
        view.addGestureRecognizer(tapGesture)
    }
    
    private func createTimer() {
        let content = UNMutableNotificationContent()
        content.title = timerTitle.text ?? "no title"
        content.subtitle = datePicker.countDownDuration.description
        let identifier = UUID().uuidString
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("error adding request: \(error)")
            } else {
                print("request successfully added")
            }
        }
        
    }

    private func configureDatePicker() {
        datePicker.datePickerMode = .countDownTimer
    }
    @objc func tapGesture(sender: UITapGestureRecognizer) {
        timerTitle.resignFirstResponder()
    }

    @IBAction func datePickerAction(_ sender: UIDatePicker) {
        guard sender.date > Date() else {return}
        timeInterval = sender.date.timeIntervalSinceNow + 5
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        createTimer()
        delegate?.didCreateTimer(self)
    }
    
}

