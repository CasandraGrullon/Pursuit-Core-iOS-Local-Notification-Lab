//
//  ManageTimerVC.swift
//  LocalNotificationsLab
//
//  Created by casandra grullon on 2/23/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import UIKit

class ManageTimerVC: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private var timers = [UNNotificationRequest]() {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private let pendingNotifications = PendingNotifications()
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        checkForAuthorization()
        loadTimers()
        configureRefreshControl()
        notificationCenter.delegate = self
        
    }
    private func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemPink
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadTimers), for: .valueChanged)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navController = segue.destination as? UINavigationController,
            let setTimerVC = navController.viewControllers.first as? SetTimerVC else {
            fatalError("could not downcast to CreateNotificationViewController")
        }
        setTimerVC.delegate = self
    }
    
    @objc private func loadTimers() {
        pendingNotifications.getPendingNotifications { (requests) in
            self.timers = requests
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func checkForAuthorization() {
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                print("authorization granted")
            } else {
                self.requestPermission()
            }
        }
    }
    
    private func requestPermission() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error {
                print("error requesting authorization: \(error)")
                return
            }
            if granted {
                print("access granted")
            } else {
                print("access denied")
            }
        }
    }


}
extension ManageTimerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timers.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timerCell", for: indexPath)
        let timer = timers[indexPath.row]
        cell.textLabel?.text = timer.content.title
        cell.detailTextLabel?.text = timer.content.subtitle
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeTimer(at: indexPath)
        }
    }
    private func removeTimer(at indexpath: IndexPath) {
        let timer = timers[indexpath.row]
        let identifier = timer.identifier
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        timers.remove(at: indexpath.row)
        tableView.deleteRows(at: [indexpath], with: .automatic)
    }
}

extension ManageTimerVC: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}
extension ManageTimerVC: CreateTimerDelegate {
    func didCreateTimer(_ setTimerVC: SetTimerVC) {
        loadTimers()
    }
    
    
}
