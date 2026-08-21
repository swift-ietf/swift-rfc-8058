import Foundation
import RFC_3987
import Testing

@testable import RFC_8058

@Suite
struct `README Verification` {

    @Suite
    struct Unit {

        @Test
        func `Example from README: Creating One-Click Unsubscribe`() throws {

            let token = "secure-token-123"

            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: token
            )

            #expect(oneClick.opaqueToken == token)
            #expect(oneClick.httpsURI.value.contains("https://example.com/unsubscribe"))
        }
    }

    @Suite
    struct `Edge Case` {

        @Test
        func `Example from README: Token Validation`() throws {
            let token = "valid-token-123"
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try .init("https://example.com/unsubscribe"),
                opaqueToken: token
            )

            #expect(oneClick.validate(token: token) == true)
            #expect(oneClick.validate(token: "wrong-token") == false)
        }
    }

    @Suite
    struct Integration {

        @Test
        func `Example from README: Rendering Email Headers`() throws {
            let token = "token123"
            let oneClick = try RFC_8058.OneClick.Unsubscribe(
                baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
                opaqueToken: token
            )

            let headers = [String: String](oneClickUnsubscribe: oneClick)

            #expect(
                headers["List-Unsubscribe"]?.contains("https://example.com/unsubscribe") == true
            )
            #expect(headers["List-Unsubscribe-Post"] == "List-Unsubscribe=One-Click")
        }

    }
}
