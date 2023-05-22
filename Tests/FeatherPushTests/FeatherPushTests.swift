import FeatherPush
import Logging
import NIOCore
import XCTest

final class FeatherPushTests: XCTestCase {

    func testFeatherFCM() async throws {
        let path = URL(fileURLWithPath: #filePath).pathComponents
            .joined(separator: "/")
            .dropLast(22)
        let credsUrl = URL(fileURLWithPath: String(path))
            .appendingPathComponent("fcm_service_account.json")
        let data = try Data(contentsOf: credsUrl)

        let featherFCMConfig = FeatherFCMConfig(credentialsData: data)
        let logger = Logger(label: "push_test")
        let eventLoopGroupProvider: NIOEventLoopGroupProvider = .createNew
        let featherPush = try FeatherPush(
            eventLoopGroupProvider: eventLoopGroupProvider,
            featherFCMConfig: featherFCMConfig,
            logger: logger
        )

        let token = "#add an Android FCM device token here#"
        let pushRecipient = PushRecipient(token: token, platform: .android)
        var pushRecipients = [PushRecipient]()
        pushRecipients.append(pushRecipient)
        let pushMessage = PushMessage(
            title: "Title from FCM",
            body: "Body from FCM"
        )

        try await featherPush.send(
            recipients: pushRecipients,
            pushMessage: pushMessage
        )
        try featherPush.syncShutdown()
    }

    func testFeatherAPNS() async throws {
        let appBundleID = "com.your.app.bundle.id"
        let privateP8Key = """
            -----BEGIN PRIVATE KEY-----
            #add your p8 private key here#
            -----END PRIVATE KEY-----
            """
        let keyIdentifier = "add your key identifier here"
        let teamIdentifier = "add your team identifier here"

        let featherAPNSConfig = FeatherAPNSConfig(
            privateP8Key: privateP8Key,
            keyIdentifier: keyIdentifier,
            teamIdentifier: teamIdentifier,
            appBundleID: appBundleID
        )
        let logger = Logger(label: "push_test")
        let eventLoopGroupProvider: NIOEventLoopGroupProvider = .createNew
        let featherPush = try FeatherPush(
            eventLoopGroupProvider: eventLoopGroupProvider,
            featherAPNSConfig: featherAPNSConfig,
            logger: logger
        )

        let token = "#add an Apple APNS device token here#"
        let pushRecipient = PushRecipient(token: token, platform: .ios)
        var pushRecipients = [PushRecipient]()
        pushRecipients.append(pushRecipient)
        let pushMessage = PushMessage(
            title: "Title from APNS",
            body: "Body from APNS"
        )

        try await featherPush.send(
            recipients: pushRecipients,
            pushMessage: pushMessage
        )
        try featherPush.syncShutdown()
    }

}
