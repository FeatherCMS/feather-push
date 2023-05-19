import APNS
import APNSCore
import Foundation
import NIOCore

public struct FeatherAPNSClient {

    let client: APNSClient<JSONDecoder, JSONEncoder>
    let appBundleID: String

    public init(
        eventLoopGroupProvider: NIOEventLoopGroupProvider = .createNew,
        privateP8Key: String,
        keyIdentifier: String,
        teamIdentifier: String,
        appBundleID: String,
        environment: String
    ) throws {

        self.appBundleID = appBundleID
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
        try await client.sendAlertNotification(
            .init(
                alert: message.createAlert(),
                expiration: .immediately,
                priority: .immediately,
                topic: appBundleID,
                payload: message.getPayload()
            ),
            deviceToken: message.getToken()
        )
    }

    public func sendMorePush(messages: [ApplePushMessage]) async throws {
        let size = messages.count
        if size == 0 {
            fatalError("[ApplePushMessage] size is empty")
        }
        for msg in messages {
            try await sendOnePush(message: msg)
        }
    }

    public func syncShutdown() throws {
        try client.syncShutdown()
    }

}
