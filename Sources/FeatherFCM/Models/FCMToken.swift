import Foundation

public struct FCMToken: Codable {

    public var accessToken: String?
    public var tokenType: String?
    public var expiresIn: Int?
    public var refreshToken: String?
    public var scope: String?
    public var creationTime: Date?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope = "scope"
        case creationTime = "creation_time"
    }

    func save(_ filename: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(self)
        try data.write(to: URL(fileURLWithPath: filename))
    }

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    public init(urlComponents: URLComponents) {
        creationTime = Date()
        for queryItem in urlComponents.queryItems! {
            if let value = queryItem.value {
                switch queryItem.name {
                case "access_token": accessToken = value
                case "token_type": tokenType = value
                case "expires_in": expiresIn = Int(value)
                case "refresh_token": refreshToken = value
                case "scope": scope = value
                default: break
                }
            }
        }
    }

}
