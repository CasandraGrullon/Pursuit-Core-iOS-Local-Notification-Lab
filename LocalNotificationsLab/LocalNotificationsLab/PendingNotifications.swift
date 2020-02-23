//
//  PendingNotifications.swift
//  LocalNotificationsLab
//
//  Created by casandra grullon on 2/23/20.
//  Copyright © 2020 casandra grullon. All rights reserved.
//

import Foundation
import UserNotifications

class PendingNotifications {
    public func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> ()) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("there are \(requests.count) pending requests")
            completion(requests)
        }
    }
}
