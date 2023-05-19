import APNSCore

public struct ApplePushMessage {

    let token: String
    let title: String
    let body: String
    let extras: [String: String]

    public init(
        token: String,
        title: String,
        body: String,
        extras: [String: String]
    ) {
        self.token = token
        self.title = title
        self.body = body
        self.extras = extras
    }

    public func createAlert() -> APNSAlertNotificationContent {
        return APNSAlertNotificationContent(
            title: .raw(title),
            body: .raw(body)
        )
    }

    public func getPayload() -> ApplePayload {
        return ApplePayload(extras: extras)
    }

    public func getToken() -> String {
        return token
    }

}
