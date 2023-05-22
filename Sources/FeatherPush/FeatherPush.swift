import FeatherAPNS
import FeatherFCM
import Logging
import NIOCore

public struct FeatherPush {

    var featherFCMClient: FeatherFCMClient? = nil
    var featherAPNSClient: FeatherAPNSClient? = nil
    let logger: Logger?

    public init(
        eventLoopGroupProvider: NIOEventLoopGroupProvider,
        featherFCMConfig: FeatherFCMConfig? = nil,
        featherAPNSConfig: FeatherAPNSConfig? = nil,
        logger: Logger? = nil
    ) throws {
        self.logger = logger
        if let fcmConfig = featherFCMConfig {
            featherFCMClient = FeatherFCMClient(
                eventLoopGroupProvider: eventLoopGroupProvider,
                credentialsData: fcmConfig.credentials,
                logger: logger
            )
        }
        if let apnsConfig = featherAPNSConfig {
            featherAPNSClient = try FeatherAPNSClient(
                eventLoopGroupProvider: eventLoopGroupProvider,
                privateP8Key: apnsConfig.privateP8Key,
                keyIdentifier: apnsConfig.keyIdentifier,
                teamIdentifier: apnsConfig.teamIdentifier,
                appBundleID: apnsConfig.appBundleID,
                environment: apnsConfig.environment,
                logger: logger
            )
        }
    }

    public func send(recipients: [PushRecipient], pushMessage: PushMessage)
        async throws
    {
        if featherFCMClient == nil && featherAPNSClient == nil {
            logger?.error("FeatherPush: no providers initialized")
            return
        }
        if recipients.isEmpty {
            logger?.error("FeatherPush: no recipients")
            return
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
