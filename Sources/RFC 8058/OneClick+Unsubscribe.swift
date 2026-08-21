import RFC_3987

extension RFC_8058.OneClick {

    public struct Unsubscribe: Hashable, Sendable, Codable {

        public let httpsURI: RFC_3987.IRI

        public let opaqueToken: String

        public init(
            baseURL: RFC_3987.IRI,
            opaqueToken: String
        ) throws(RFC_8058.OneClickError) {

            guard baseURL.value.hasPrefix("https://") else {
                throw RFC_8058.OneClickError.requiresHTTPS
            }

            guard !opaqueToken.isEmpty else {
                throw RFC_8058.OneClickError.invalidToken(opaqueToken)
            }

            self.opaqueToken = opaqueToken

            let fullURIString: String
            if baseURL.value.hasSuffix("/") {
                fullURIString = "\(baseURL.value)\(opaqueToken)"
            } else {
                fullURIString = "\(baseURL.value)/\(opaqueToken)"
            }

            let uri: RFC_3987.IRI
            do throws(RFC_3987.IRI.Error) {
                uri = try RFC_3987.IRI(fullURIString)
            } catch {
                throw RFC_8058.OneClickError.invalidURI(fullURIString)
            }

            self.httpsURI = uri
        }

        public init(
            baseURL: some RFC_3987.IRI.Representable,
            opaqueToken: String
        ) throws(RFC_8058.OneClickError) {
            try self.init(baseURL: baseURL.iri, opaqueToken: opaqueToken)
        }
    }
}

extension RFC_8058.OneClick.Unsubscribe {

    public func validate(token: String) -> Bool {

        guard token.count == opaqueToken.count else { return false }

        var result = 0
        for (a, b) in zip(token.utf8, opaqueToken.utf8) {
            result |= Int(a ^ b)
        }
        return result == 0
    }
}

extension [String: String] {

    public init(oneClickUnsubscribe: RFC_8058.OneClick.Unsubscribe) {
        self = [
            "List-Unsubscribe": "<\(oneClickUnsubscribe.httpsURI.value)>",
            "List-Unsubscribe-Post": "List-Unsubscribe=One-Click",
        ]
    }
}
