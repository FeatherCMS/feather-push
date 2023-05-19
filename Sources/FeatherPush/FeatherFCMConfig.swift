import Foundation

public struct FeatherFCMConfig {

    var credentials: Data

    public init?(credentialsData: Data) {
        self.credentials = credentialsData
    }

}
