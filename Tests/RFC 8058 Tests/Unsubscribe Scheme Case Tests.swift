import RFC_3987
import RFC_8058
import Testing

@Suite
struct `Unsubscribe scheme case` {
    @Test(arguments: ["HTTPS://example.com/unsubscribe", "Https://example.com/unsubscribe"])
    func `an upper-case HTTPS scheme is HTTPS`(_ base: String) throws {
        _ = try RFC_8058.OneClick.Unsubscribe(baseURL: try RFC_3987.IRI(base), opaqueToken: "abc")
    }

    @Test(arguments: ["http://example.com/unsubscribe", "HTTP://example.com/unsubscribe", "httpsx://example.com/u"])
    func `a non-HTTPS scheme is refused`(_ base: String) {
        #expect(throws: RFC_8058.OneClickError.self) {
            try RFC_8058.OneClick.Unsubscribe(baseURL: try RFC_3987.IRI(base), opaqueToken: "abc")
        }
    }
}
