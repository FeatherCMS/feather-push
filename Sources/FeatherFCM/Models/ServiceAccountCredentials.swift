struct ServiceAccountCredentials: Codable {

    let credentialType: String
    let projectId: String
    let privateKeyId: String
    let privateKey: String
    let clientEmail: String
    let clientID: String
    let authURI: String
    let tokenURI: String
    let authProviderX509CertURL: String
    let clientX509CertURL: String

    enum CodingKeys: String, CodingKey {
        case credentialType = "type"
        case projectId = "project_id"
        case privateKeyId = "private_key_id"
        case privateKey = "private_key"
        case clientEmail = "client_email"
        case clientID = "client_id"
        case authURI = "auth_uri"
        case tokenURI = "token_uri"
        case authProviderX509CertURL = "auth_provider_x509_cert_url"
        case clientX509CertURL = "client_x509_cert_url"
    }

}
