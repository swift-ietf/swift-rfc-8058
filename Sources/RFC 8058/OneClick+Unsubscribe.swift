import RFC_3987

extension RFC_8058.OneClick {

    public struct Unsubscribe: Hashable, Sendable {

        public let httpsURI: RFC_3987.IRI

        public let opaqueToken: String

        public init(
            baseURL: RFC_3987.IRI,
            opaqueToken: String
        ) throws(RFC_8058.OneClickError) {

            guard baseURL.value.prefix(8).lowercased() == "https://" else {
                throw RFC_8058.OneClickError.requiresHTTPS
            }

            guard
                !opaqueToken.isEmpty,
                opaqueToken.utf8.allSatisfy(Self.isUnreserved)
            else {
                throw RFC_8058.OneClickError.invalidToken(opaqueToken)
            }

            self.opaqueToken = opaqueToken

            let fullURIString: String
            fullURIString =
                if baseURL.value.hasSuffix("/") {
                    "\(baseURL.value)\(opaqueToken)"
                } else {
                    "\(baseURL.value)/\(opaqueToken)"
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

extension RFC_8058.OneClick.Unsubscribe: Codable {

    private enum CodingKeys: String, CodingKey {
        case httpsURI
        case opaqueToken
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let httpsURI = try container.decode(RFC_3987.IRI.self, forKey: .httpsURI)
        let opaqueToken = try container.decode(String.self, forKey: .opaqueToken)
        let suffix = "/\(opaqueToken)"
        guard httpsURI.value.hasSuffix(suffix) else {
            throw DecodingError.dataCorruptedError(
                forKey: .httpsURI,
                in: container,
                debugDescription: "URI '\(httpsURI.value)' does not end in its opaque token '\(opaqueToken)'."
            )
        }
        let baseURLString = String(decoding: httpsURI.value.utf8.dropLast(suffix.utf8.count), as: UTF8.self)
        do {
            try self.init(baseURL: RFC_3987.IRI(baseURLString), opaqueToken: opaqueToken)
        } catch let error as RFC_8058.OneClickError {
            throw DecodingError.dataCorruptedError(
                forKey: .httpsURI,
                in: container,
                debugDescription: error.description
            )
        } catch {
            throw DecodingError.dataCorruptedError(
                forKey: .httpsURI,
                in: container,
                debugDescription: "Invalid base URI '\(baseURLString)'."
            )
        }
        guard self.httpsURI == httpsURI else {
            throw DecodingError.dataCorruptedError(
                forKey: .httpsURI,
                in: container,
                debugDescription: "URI '\(httpsURI.value)' is not the URI derived from its base and opaque token."
            )
        }
    }
}

extension RFC_8058.OneClick.Unsubscribe {

    private static func isUnreserved(_ byte: UInt8) -> Bool {
        switch byte {
        case UInt8(ascii: "A")...UInt8(ascii: "Z"),
            UInt8(ascii: "a")...UInt8(ascii: "z"),
            UInt8(ascii: "0")...UInt8(ascii: "9"),
            UInt8(ascii: "-"), UInt8(ascii: "."), UInt8(ascii: "_"), UInt8(ascii: "~"):
            true
        default:
            false
        }
    }
}

extension RFC_8058.OneClick.Unsubscribe {

    public func validate(token: String) -> Bool {

        guard token.utf8.count == opaqueToken.utf8.count else { return false }

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
