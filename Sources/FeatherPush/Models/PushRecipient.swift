import FeatherAPNS
import FeatherFCM

public struct PushRecipient {

    public let token: String
    public let platform: PushPlatform

    public init(
        token: String,
        platform: PushPlatform
    ) {
        self.token = token
        self.platform = platform
    }

}

extension [PushRecipient] {

    func convertToFCM(pushMessage: PushMessage) -> [FCMPushMessage] {
        var array = [FCMPushMessage]()
        for pr in self {
            array.append(
                .init(
                    pushType: "data",
                    token: pr.token,
                    title: pushMessage.title,
                    body: pushMessage.body,
                    extras: pushMessage.extras
                )
            )
        }
        return array
    }

    func convertToAPNS(pushMessage: PushMessage) -> [ApplePushMessage] {
        var array = [ApplePushMessage]()
        for pr in self {
            array.append(
                .init(
                    token: pr.token,
                    title: pushMessage.title,
                    body: pushMessage.body,
                    extras: pushMessage.extras
                )
            )
        }
        return array
    }

}
