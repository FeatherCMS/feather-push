import APNS
import APNSCore
import Foundation
import Logging
import NIOCore

public struct FeatherAPNSClient {

    let client: APNSClient<JSONDecoder, JSONEncoder>
    let appBundleID: String
    let logger: Logger?

    public init(
        eventLoopGroupProvider: NIOEventLoopGroupProvider,
        privateP8Key: String,
        keyIdentifier: String,
        teamIdentifier: String,
        appBundleID: String,
        environment: String,
        logger: Logger? = nil
    ) throws {

        self.appBundleID = appBundleID
        self.logger = logger

        var env: APNSEnvironment = .sandbox
        if environment != "sandbox" {
            env = .production
        }

        client = APNSClient(
            configuration: .init(
                authenticationMethod: .jwt(
                    privateKey: try .init(
                        pemRepresentation: privateP8Key
                    ),
                    keyIdentifier: keyIdentifier,
                    teamIdentifier: teamIdentifier
                ),
                environment: env
            ),
            eventLoopGroupProvider: eventLoopGroupProvider,
            responseDecoder: JSONDecoder(),
            requestEncoder: JSONEncoder(),
            byteBufferAllocator: .init()
        )
    }

    public func sendOnePush(message: ApplePushMessage) async throws {
        let response = try await client.sendAlertNotification(
            .init(
                alert: message.createAlert(),
                expiration: .immediately,
                priority: .immediately,
                topic: appBundleID,
                payload: message.getPayload()
            ),
            deviceToken: message.getToken()
        )

        logger?.info("\(response.apnsID!)")
    }

    public func sendMorePush(messages: [ApplePushMessage]) async throws {
        let size = messages.count
        if size == 0 {
            logger?.error("[ApplePushMessage] size is empty")
            return
        }
        for msg in messages {
            try await sendOnePush(message: msg)
        }
    }

    public func syncShutdown() throws {
        try client.syncShutdown()
    }

}
