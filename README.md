# swift-rfc-8058

Use this package when a mailing list you send needs one-click unsubscribe headers, and when your server has to check the token in the unsubscribe request it gets back. Start from `RFC_8058.OneClick.Unsubscribe`. For the other list headers, such as List-Help and List-Subscribe, use swift-rfc-2369.

## Laws

- The base URL must use the HTTPS scheme. The scheme is matched case-insensitively, so `HTTPS://` is accepted and `http://` is refused.
- The token is appended to the base URL as the last path segment, with a slash added only if the base URL doesn't already end in one.
- `RFC_8058.OneClick.Unsubscribe.validate(token:)` returns false at once for a token of a different length. For a token of the same length, it doesn't stop at the first difference, so the time taken doesn't depend on where the tokens differ.
- The headers are exactly two: `List-Unsubscribe`, holding the URI in angle brackets, and `List-Unsubscribe-Post`, holding `List-Unsubscribe=One-Click`.
