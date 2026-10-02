import Foundation
import Networking
import Testing

struct RequestBuilderTests {
    private let baseURL: URL

    init() throws {
        baseURL = try #require(URL(string: "https://api.example.com"))
    }

    @Test func buildsGetRequestForPath() throws {
        let request = try RequestBuilder(baseURL: baseURL).path("v1/items").build()

        #expect(request.url?.absoluteString == "https://api.example.com/v1/items")
        #expect(request.httpMethod == "GET")
    }

    @Test func appendsQueryItemsInOrderAndPercentEncodesValues() throws {
        let request = try RequestBuilder(baseURL: baseURL)
            .path("/v1/items")
            .query("codes", "MXN,ARS")
            .query("name", "a b&c")
            .build()

        #expect(request.url?.absoluteString == "https://api.example.com/v1/items?codes=MXN,ARS&name=a%20b%26c")
    }

    @Test func eachStepReturnsANewBuilderAndLeavesTheOriginalUnchanged() throws {
        let base = RequestBuilder(baseURL: baseURL).path("v1/items")

        _ = base.path("v2/other").query("id", "1")

        let request = try base.build()
        #expect(request.url?.absoluteString == "https://api.example.com/v1/items")
    }
}
