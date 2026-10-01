import Foundation
import Networking
import Testing

struct RequestBuilderTests {
    private let baseURL: URL

    init() throws {
        baseURL = try #require(URL(string: "https://api.example.com"))
    }

    @Test func defaultsToGetWithoutQueryHeadersOrBody() throws {
        let request = try RequestBuilder(baseURL: baseURL).path("v1/items").build()

        #expect(request.url?.absoluteString == "https://api.example.com/v1/items")
        #expect(request.httpMethod == "GET")
        #expect(request.allHTTPHeaderFields?.isEmpty ?? true)
        #expect(request.httpBody == nil)
    }

    @Test func appendsQueryItemsInOrderAndPercentEncodesValues() throws {
        let request = try RequestBuilder(baseURL: baseURL)
            .path("/v1/items")
            .query("codes", "MXN,ARS")
            .query("name", "a b&c")
            .build()

        #expect(request.url?.absoluteString == "https://api.example.com/v1/items?codes=MXN,ARS&name=a%20b%26c")
    }

    @Test func setsMethodHeadersAndBody() throws {
        let body = Data(#"{"id":1}"#.utf8)

        let request = try RequestBuilder(baseURL: baseURL)
            .path("v1/items")
            .method(.post)
            .header("Content-Type", "application/json")
            .body(body)
            .build()

        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        #expect(request.httpBody == body)
    }

    @Test func eachStepReturnsANewBuilderAndLeavesTheOriginalUnchanged() throws {
        let base = RequestBuilder(baseURL: baseURL).path("v1/items")

        _ = base.method(.delete).query("id", "1")

        let request = try base.build()
        #expect(request.httpMethod == "GET")
        #expect(request.url?.query == nil)
    }
}
