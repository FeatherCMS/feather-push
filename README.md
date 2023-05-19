# Feather Push Component

A push notification component, which can send push using via [FCM](https://firebase.google.com/docs/cloud-messaging) or [APNS](https://developer.apple.com/documentation/usernotifications/setting_up_a_remote_notification_server/sending_notification_requests_to_apns) providers.

## Getting started 

Adding the dependency

Add the following entry in your Package.swift to start using `FeatherPush`:

```swift
.package(url: "https://github.com/feathercms/feather-push", from: "1.0.0"),
```

and the FeatherPush dependency to your target:

```swift
.product(name: "FeatherPush", package: "feather-push"),
```    

## FeatherFCM

Simple usage

```swift
import FeatherPush

let path = URL(fileURLWithPath: #filePath).pathComponents
    .joined(separator: "/")
    .dropLast(22)
let credsUrl = URL(fileURLWithPath: String(path))
    .appendingPathComponent("fcm_service_account.json")
let data = try Data(contentsOf: credsUrl)

let featherFCMConfig = FeatherFCMConfig(credentialsData: data)
let featherPush = try FeatherPush(featherFCMConfig: featherFCMConfig)

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
```

## FeatherAPNS

Simple usage

```swift
import FeatherPush

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
let featherPush = try FeatherPush(featherAPNSConfig: featherAPNSConfig)

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
```

## Credits 

The FeatherAPNS library is using [APNSwift](https://github.com/swift-server-community/APNSwift).

The FeatherFCM library is inspired by [google-auth-library-swift](https://github.com/googleapis/google-auth-library-swift).
