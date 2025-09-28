//
//  Notifications.swift
//  Codepath-HW2
//
//  Created by Jeffrey Berdeal on 9/23/25.
//

import UserNotifications

enum BeRealReminder {
    static func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    /// Cancel all scheduled reminders (use on logout)
    static func clear() {
        let c = UNUserNotificationCenter.current()
        c.removeAllPendingNotificationRequests()
        c.removeAllDeliveredNotifications()
    }

    /// Schedule a reminder in `seconds` if the user hasn't posted recently.
    static func scheduleIfMissed(lastPostedAt: Date?, seconds: TimeInterval = 60*60*6) {
        guard shouldRemind(last: lastPostedAt) else { return }
        let content = UNMutableNotificationContent()
        content.title = "BeReal"
        content.body  = "Remember to upload today’s photo!"
        content.sound = .default

        // One-time reminder in N seconds (you can change to every 6 hours by repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let req = UNNotificationRequest(identifier: "bereal.missed", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req)
    }

    private static func shouldRemind(last: Date?) -> Bool {
        guard let last else { return true }              // never posted → remind
        return Date().timeIntervalSince(last) >= 24*3600 // older than 24h → remind
    }
}
