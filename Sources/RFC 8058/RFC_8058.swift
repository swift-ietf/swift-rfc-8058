@_exported public import RFC_3987

/// RFC 8058: Signaling One-Click Functionality for List Email Headers
///
/// This module implements the one-click unsubscribe mechanism defined in RFC 8058,
/// which extends RFC 2369 list headers with enhanced security and user experience.
///
/// RFC 8058 provides a streamlined unsubscribe experience where email clients can
/// offer a single-click unsubscribe button without requiring the user to visit a
/// website or compose an email.
///
/// ## Key Features
///
/// - HTTPS-only URIs for security
/// - Opaque tokens to prevent abuse
/// - Single POST request for unsubscription
/// - No user context required (no cookies, no session)
///
/// ## Security Model
///
/// Per RFC 8058 Section 3:
///
/// > The URI SHOULD include an opaque identifier or another hard-to-forge
/// > component in addition to, or instead of, the plaintext names of the list
/// > and subscriber.
///
/// This prevents attackers from crafting unsubscribe requests for arbitrary users.
///
/// ## Usage Example
///
/// ```swift
/// // Generate opaque token (must be cryptographically secure)
/// let token = UUID().uuidString + "-" + HMAC(subscriber, list, secret)
///
/// // Create one-click unsubscribe
/// let oneClick = try RFC_8058.OneClick.Unsubscribe(
///     baseURL: try RFC_3987.IRI("https://example.com/unsubscribe"),
///     opaqueToken: token
/// )
///
/// // Render as email headers
/// let headers = [String: String](oneClickUnsubscribe: oneClick)
/// // [
/// //     "List-Unsubscribe": "<https://example.com/unsubscribe/TOKEN>",
/// //     "List-Unsubscribe-Post": "List-Unsubscribe=One-Click"
/// // ]
/// ```
///
/// ## RFC Reference
///
/// From RFC 8058 Section 1:
///
/// > This document describes a method for signaling a one-click function for
/// > the List-Unsubscribe email header field. The need for this arises out of
/// > the fact that the existing List-Unsubscribe header field has two major
/// > problems:
/// >
/// > 1. There is no way to indicate whether the List-Unsubscribe URI is
/// >    intended for human use or automated use.
/// > 2. There is no way to indicate what kind of credentials are required.
///
/// This module re-exports RFC 3987 (IRI) types for convenience.
public enum RFC_8058 {
}
