public struct PushMessage {

    public let title: String
    public let body: String
    public let extras: [String: String]

    public init(
        title: String,
        body: String,
        extras: [String: String] = [:]
    ) {
        self.title = title
        self.body = body
        self.extras = extras
    }

}
