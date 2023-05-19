import FeatherAPNS
import FeatherFCM

public struct FeatherPush {

    var featherFCMClient: FeatherFCMClient? = nil
    var featherAPNSClient: FeatherAPNSClient? = nil

    public init(
        featherFCMConfig: FeatherFCMConfig? = nil,
        featherAPNSConfig: FeatherAPNSConfig? = nil
    ) throws {
        if let fcmConfig = featherFCMConfig {
            featherFCMClient = FeatherFCMClient(
                credentialsData: fcmConfig.credentials
            )
        }
        if let apnsConfig = featherAPNSConfig {
            featherAPNSClient = try FeatherAPNSClient(
                privateP8Key: apnsConfig.privateP8Key,
                keyIdentifier: apnsConfig.keyIdentifier,
                teamIdentifier: apnsConfig.teamIdentifier,
                appBundleID: apnsConfig.appBundleID,
                environment: apnsConfig.environment
            )
        }
    }

    public func send(recipients: [PushRecipient], pushMessage: PushMessage)
        async throws
    {
        if featherFCMClient == nil && featherAPNSClient == nil {
            fatalError("FeatherPush: no providers initialized")
        }
        if recipients.isEmpty {
            fatalError("FeatherPush: no recipients")
        }

        let fcmRecipients = recipients.filter { $0.platform == .android }
        let apnsRecipients = recipients.filter { $0.platform == .ios }
        if !fcmRecipients.isEmpty {
            let fcmPushMessages = fcmRecipients.convertToFCM(
                pushMessage: pushMessage
            )
            if fcmPushMessages.count == 1 {
                try await featherFCMClient?.sendOnePush(
                    fcmPushMessage: fcmPushMessages[0]
                )
            }
            else {
                try await featherFCMClient?.sendMorePush(
                    fcmPushMessages: fcmPushMessages
                )
            }
        }
        if !apnsRecipients.isEmpty {
            let apnsPushMessages = apnsRecipients.convertToAPNS(
                pushMessage: pushMessage
            )
            try await featherAPNSClient?.sendMorePush(
                messages: apnsPushMessages
            )
        }
    }

    public func syncShutdown() throws {
        try featherFCMClient?.syncShutdown()
        try featherAPNSClient?.syncShutdown()
    }

}
