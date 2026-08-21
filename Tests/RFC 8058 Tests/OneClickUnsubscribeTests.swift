import Foundation
import RFC_3987
import RFC_3987_Foundation
import RFC_8058
import Testing

@Suite
struct `RFC 8058 One-Click Unsubscribe Tests` {

    @Suite
    struct Unit {

        @Test
        func `OneClick.Unsubscribe can be created with HTTPS URI`() throws {
            let baseURL = try RFC_3987.IRI("https://example.com/unsubscribe")
            let token = "abc123xyz"

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: baseURL,
                opaqueToken: token
            )

            #expect(oneClick.opaqueToken == token)
            #expect(oneClick.httpsURI.value == "https://example.com/unsubscribe/abc123xyz")
        }

        @Test
        func `Renders RFC 8058 compliant headers`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token123"
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)

            #expect(headers.count == 2)
            #expect(headers["List-Unsubscribe"] == "<https://example.com/unsubscribe/token123>")
            #expect(headers["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click")
        }

        @Test
        func `List-Unsubscribe header uses angle brackets per RFC 2369`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "abc"
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)
            let unsubscribeHeader = headers["List-Unsubscribe"]!

            #expect(unsubscribeHeader.hasPrefix("<"))
            #expect(unsubscribeHeader.hasSuffix(">"))
        }

        @Test
        func `List-Unsubscribe-Post has exact value per RFC 8058`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token"
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)

            #expect(headers["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click")
        }

        @Test
        func `Token validation succeeds with correct token`() throws {
            let token = "correct-token-123"
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: token
            )

            let isValid = oneClick.validate(token: token)

            #expect(isValid == true)
        }

        @Test
        func `Token validation fails with incorrect token`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "correct-token"
            )

            let isValid = oneClick.validate(token: "wrong-token")

            #expect(isValid == false)
        }

        @Test
        func `OneClick.Unsubscribe is Codable`() throws {
            let original = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "test-token-123"
            )

            let encoded = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(
                RFC_8058.OneClick.Unsubscribe.self,
                from: encoded
            )

            #expect(decoded.httpsURI == original.httpsURI)
            #expect(decoded.opaqueToken == original.opaqueToken)
        }

        @Test
        func `OneClick.Unsubscribe is Hashable`() throws {
            let oneClick1 = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token123"
            )

            let oneClick2 = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token123"
            )

            let oneClick3 = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "different-token"
            )

            #expect(oneClick1 == oneClick2)
            #expect(oneClick1 != oneClick3)

            var set = Set<RFC_8058.OneClick.Unsubscribe>()
            set.insert(oneClick1)
            set.insert(oneClick2)
            set.insert(oneClick3)

            #expect(set.count == 2)
        }

        @Test
        func `OneClick.Unsubscribe is Sendable`() async throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token"
            )

            await withCheckedContinuation { continuation in
                Task {
                    let _ = oneClick
                    continuation.resume()
                }
            }
        }
    }

    @Suite
    struct `Edge Case` {

        @Test
        func `OneClick.Unsubscribe throws error for non-HTTPS URI`() throws {
            let httpURL = try RFC_3987.IRI("http://example.com/unsubscribe")

            #expect(throws: RFC_8058.OneClickError.self) {
                try RFC_8058.OneClick.Unsubscribe(
                    baseURL: httpURL,
                    opaqueToken: "token123"
                )
            }
        }

        @Test
        func `OneClick.Unsubscribe throws error for empty token`() throws {
            let baseURL = try RFC_3987.IRI("https://example.com/unsubscribe")

            #expect(throws: RFC_8058.OneClickError.self) {
                try RFC_8058.OneClick.Unsubscribe(
                    baseURL: baseURL,
                    opaqueToken: ""
                )
            }
        }

        @Test
        func `OneClick.Unsubscribe handles base URL with trailing slash`() throws {
            let baseWithSlash = try RFC_3987.IRI("https://example.com/unsubscribe/")
            let baseWithoutSlash = try RFC_3987.IRI("https://example.com/unsubscribe")
            let token = "abc123"

            let oneClick1 = try RFC_8058.OneClick.Unsubscribe(
                baseURL: baseWithSlash,
                opaqueToken: token
            )

            let oneClick2 = try RFC_8058.OneClick.Unsubscribe(
                baseURL: baseWithoutSlash,
                opaqueToken: token
            )

            #expect(oneClick1.httpsURI.value == "https://example.com/unsubscribe/abc123")
            #expect(oneClick2.httpsURI.value == "https://example.com/unsubscribe/abc123")
        }

        @Test
        func `Token validation fails with different length token`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "short"
            )

            let isValid = oneClick.validate(token: "this-is-much-longer")

            #expect(isValid == false)
        }

        @Test
        func `Token validation uses constant-time comparison`() throws {

            let token = "abcdefghijklmnop"
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: token
            )

            let allDifferent = "xxxxxxxxxxxxxxxx"
            let result1 = oneClick.validate(token: allDifferent)
            #expect(result1 == false)

            let firstMatches = "axxxxxxxxxxxxxxx"
            let result2 = oneClick.validate(token: firstMatches)
            #expect(result2 == false)

            let almostMatches = "abcdefghijklmnox"
            let result3 = oneClick.validate(token: almostMatches)
            #expect(result3 == false)

        }

        @Test
        func `Token validation with empty string`() throws {
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "valid-token"
            )

            let isValid = oneClick.validate(token: "")

            #expect(isValid == false)
        }

        @Test
        func `Opaque token should be URL-safe`() throws {

            let urlSafeToken = "abc123-_."

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: urlSafeToken
            )

            #expect(oneClick.httpsURI.value.contains(urlSafeToken))
        }

        @Test
        func `Typical HMAC-based token works`() throws {

            let hmacToken = "dGVzdEBleGFtcGxlLmNvbTpuZXdzbGV0dGVy"

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: hmacToken
            )

            #expect(oneClick.opaqueToken == hmacToken)
            #expect(oneClick.validate(token: hmacToken) == true)
        }
    }

    @Suite
    struct Integration {

        @Test
        func `OneClick.Unsubscribe can be created with IRI.Representable (URL)`() throws {
            let baseURL = URL(string: "https://example.com/unsubscribe")!
            let token = "secure-token-123"

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: baseURL,
                opaqueToken: token
            )

            #expect(oneClick.httpsURI.value.contains("https://example.com/unsubscribe"))
            #expect(oneClick.httpsURI.value.contains(token))
        }

        @Test
        func `Can be combined with RFC 2369 List-Unsubscribe`() throws {

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: "token123"
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)

            #expect(headers["List-Unsubscribe"]?.contains("https://") == true)
            #expect(headers["List-Unsubscribe-Post"] != nil)
        }

        @Test
        func `Realistic unsubscribe workflow`() throws {

            let subscriber = "user@example.com"
            let list = "newsletter"
            let secret = "secret-key-12345"

            let tokenData = "\(subscriber):\(list):\(secret)"
            let token = tokenData.data(using: .utf8)!
                .base64EncodedString()
                .replacing("+", with: "-")
                .replacing("/", with: "_")
                .replacing("=", with: "")

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/api/unsubscribe"),
                opaqueToken: token
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)

            #expect(headers["List-Unsubscribe"]?.contains(token) == true)
            #expect(headers["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click")

            let requestToken = token
            #expect(oneClick.validate(token: requestToken) == true)
        }
    }
}
