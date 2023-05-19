public struct FCMPushMessage {

    let pushType: String
    let token: String
    let title: String
    let body: String
    let extras: [String: String]

    public init(
        pushType: String,
        token: String,
        title: String,
        body: String,
        extras: [String: String]
    ) {
        self.pushType = pushType
        self.token = token
        self.title = title
        self.body = body
        self.extras = extras
    }

    public func makeJson() -> String {
        var extrasStr = ""
        if pushType == "data" && !extras.isEmpty {
            for (key, value) in extras {
                extrasStr += ",\"\(key)\":\"\(value)\""
            }
        }
        let msg = """
            {
                "message": {
                    "token":"\(token)",
                    "\(pushType)": {
                        "title": "\(title)",
                        "body": "\(body)" \(extrasStr)
                    }
                }
            }
            """
        return msg
    }

}
