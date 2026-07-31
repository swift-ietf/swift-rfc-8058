extension RFC_8058 {
    /// Errors that can occur when working with one-click unsubscribe
    public enum OneClickError: Swift.Error, Hashable, Sendable {
        case requiresHTTPS
        case invalidToken(String)
        case tokenMismatch
        case invalidURI(String)
    }
}

// MARK: - CustomStringConvertible Conformance

extension RFC_8058.OneClickError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .requiresHTTPS:
            return "One-click unsubscribe requires HTTPS URI per RFC 8058 Section 3.1"
        case .invalidToken(let token):
            return "Invalid opaque token: '\(token)'. Token must be non-empty and URL-safe."
        case .tokenMismatch:
            return "Token validation failed. The provided token does not match the expected value."
        case .invalidURI(let uri):
            return "Invalid URI: '\(uri)'. URI must be a valid HTTPS IRI."
        }
    }
}
