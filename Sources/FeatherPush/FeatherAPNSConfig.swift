public struct FeatherAPNSConfig {

    var environment = "sandbox"
    let privateP8Key: String
    let keyIdentifier: String
    let teamIdentifier: String
    let appBundleID: String

    public init(
        isSandbox: Bool = true,
        privateP8Key: String,
        keyIdentifier: String,
        teamIdentifier: String,
        appBundleID: String
    ) {
        if !isSandbox {
            environment = "production"
        }
        self.privateP8Key = privateP8Key
        self.keyIdentifier = keyIdentifier
        self.teamIdentifier = teamIdentifier
        self.appBundleID = appBundleID
    }

}
