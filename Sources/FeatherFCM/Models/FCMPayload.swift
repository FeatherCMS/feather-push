import JWTKit

struct FCMPayload: JWTPayload, Equatable {

    var iss: IssuerClaim
    var aud: AudienceClaim
    let scope: String
    var iat: IssuedAtClaim
    var exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try self.exp.verifyNotExpired()
    }

}
