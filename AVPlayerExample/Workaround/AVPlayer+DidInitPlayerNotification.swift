import AVFoundation

@objc extension AVPlayer {
    public static let didInitPlayerNotificationName = "didInitPlayerNotification"

    static let didInitPlayerNotification = Notification.Name(AVPlayer.didInitPlayerNotificationName)
}
