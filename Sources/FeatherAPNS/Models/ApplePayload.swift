public struct ApplePayload: Codable {

    let extras: [String: String]

    init(extras: [String: String]) {
        self.extras = extras
    }

}
