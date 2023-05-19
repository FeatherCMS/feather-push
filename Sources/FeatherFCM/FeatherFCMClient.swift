import AsyncHTTPClient
import Foundation
import JWTKit
import NIOConcurrencyHelpers
import NIOCore
import NIOHTTP1
import NIOSSL
import NIOTLS

public struct FeatherFCMClient {

    var credentials: ServiceAccountCredentials
    let client: HTTPClient

    private let defaultRequestHeaders: HTTPHeaders = {
        var headers = HTTPHeaders()
        headers.add(name: "content-type", value: "application/json")
        return headers
    }()

    public init?(
        eventLoopGroupProvider: NIOEventLoopGroupProvider = .createNew,
        credentialsData: Data
    ) {
        guard
            let credentials = try? JSONDecoder().decode(
                ServiceAccountCredentials.self,
                from: credentialsData
            )
        else {
            return nil
        }
        self.credentials = credentials

        var httpClientConfiguration = HTTPClient.Configuration()
        httpClientConfiguration.tlsConfiguration =
            TLSConfiguration.makeClientConfiguration()
        httpClientConfiguration.httpVersion = .automatic

        let httpClientEventLoopGroupProvider: HTTPClient.EventLoopGroupProvider
        switch eventLoopGroupProvider {
        case .shared(let eventLoopGroup):
            httpClientEventLoopGroupProvider = .shared(eventLoopGroup)
        case .createNew:
            httpClientEventLoopGroupProvider = .createNew
        }

        client = HTTPClient(
            eventLoopGroupProvider: httpClientEventLoopGroupProvider,
            configuration: httpClientConfiguration
        )
    }

    public func sendOnePush(fcmPushMessage: FCMPushMessage) async throws {
        let accessToken = try await getToken()
        if accessToken == nil {
            fatalError("FCM AccessToken nil")
        }

        var headers = defaultRequestHeaders
        headers.add(name: "Authorization", value: "Bearer " + accessToken!)

        var httpClientRequest = HTTPClientRequest(
            url:
                "https://fcm.googleapis.com/v1/projects/\(credentials.projectId)/messages:send"
        )
        httpClientRequest.method = .POST
        httpClientRequest.headers = headers
        httpClientRequest.body = .bytes(
            fcmPushMessage.makeJson().data(using: .utf8)!
        )

        let response = try await client.execute(
            httpClientRequest,
            deadline: .distantFuture
        )
        if response.status == .ok {
            var byteBuffer = try await response.body.collect(upTo: 8192)
            let pushResponse = byteBuffer.readString(
                length: byteBuffer.readableBytes
            )
            print(pushResponse!)
        }
        else {
            print("Send push error: " + response.status.description)
        }
    }

    public func sendMorePush(fcmPushMessages: [FCMPushMessage]) async throws {
        let accessToken = try await getToken()
        if accessToken == nil {
            fatalError("FCM AccessToken nil")
        }

        let size = fcmPushMessages.count
        var fullBatch = ""
        let step = 500  //FCM max batch size
        for i in stride(from: 0, to: size, by: step) {

            fullBatch = ""
            var j = i + step
            if j > size {
                j = size
            }
            for k in stride(from: i, to: j, by: 1) {
                let partJson = fcmPushMessages[k].makeJson()
                let batchPart = """
                    --subrequest_boundary
                    Content-Type: application/http
                    Content-Transfer-Encoding: binary

                    POST /v1/projects/\(credentials.projectId)/messages:send
                    Content-Type: application/json
                    accept: application/json

                    \(partJson)

                    """
                fullBatch += batchPart
            }
            fullBatch += "--subrequest_boundary"

            var headers = HTTPHeaders()
            headers.add(
                name: "Content-Type",
                value: "multipart/mixed; boundary=subrequest_boundary"
            )
            headers.add(name: "Authorization", value: "Bearer " + accessToken!)

            var httpClientRequest = HTTPClientRequest(
                url: "https://fcm.googleapis.com/batch"
            )
            httpClientRequest.method = .POST
            httpClientRequest.headers = headers
            httpClientRequest.body = .bytes(fullBatch.data(using: .utf8)!)

            let response = try await client.execute(
                httpClientRequest,
                deadline: .distantFuture
            )
            print(response.status)
        }
    }

    public func syncShutdown() throws {
        try client.syncShutdown()
    }

    private func getToken() async throws -> String? {
        let iat = Date()
        let exp = iat.addingTimeInterval(3600)
        let test = FCMPayload(
            iss: .init(value: credentials.clientEmail),
            aud: .init(value: credentials.tokenURI),
            scope: "https://www.googleapis.com/auth/cloud-platform",
            iat: .init(value: iat),
            exp: .init(value: exp)
        )
        let jwt = try JWTSigner.rs256(
            key: .private(pem: credentials.privateKey)
        ).sign(test)

        let json: [String: Any] = [
            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
            "assertion": jwt,
        ]
        let data = try? JSONSerialization.data(withJSONObject: json)

        var httpClientRequest = HTTPClientRequest(
            url: credentials.tokenURI
        )
        httpClientRequest.method = .POST
        httpClientRequest.headers = defaultRequestHeaders
        httpClientRequest.body = .bytes(data!)

        let response = try await client.execute(
            httpClientRequest,
            deadline: .distantFuture
        )
        if response.status == .ok {
            let responseDecoder = JSONDecoder()
            let body = try await response.body.collect(upTo: 8192)
            let tokenResponse = try responseDecoder.decode(
                FCMToken.self,
                from: body
            )
            return tokenResponse.accessToken
        }
        else {
            print("Token error: " + response.status.description)
        }
        return nil
    }

}
