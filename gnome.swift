import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URLSession {
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { continuation in
            let task = self.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.unknown))
                }
            }
            task.resume()
        }
    }
}


public enum DiscourseSort: String {
        case latest = "latest"
        case top = "top"
    }

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public class GnomeSite {

    private let api = "https://www.gnome.org"
    private let apiExtensions = "https://extensions.gnome.org"
    private let apiDiscourse = "https://discourse.gnome.org"

    private var headers: [String: String]

    public init() {
        self.headers = [
            "Connection": "keep-alive",
            "Accept-Encoding": "deflate, zstd",
            "Accept-Language": "en-US,en;q=0.9",
            "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36"
        ]
    }

    private func fetchJSON(from urlString: String,method: HTTPMethod = .get,body: Data? = nil,queryParameters: [String: String]? = nil) async throws -> Any {
        var urlComponents = URLComponents(string: urlString)
        if let queryParameters = queryParameters {
            urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = urlComponents?.url else {
            throw NSError(domain: "Invalid URL", code: -1)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        if let body = body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONSerialization.jsonObject(with: data)
    }

    public func getCategoryLatestTopics(categorySlug: String, categoryId: Int, filter: String = "default") async throws -> Any {
        try await fetchJSON(
            from: "\(apiDiscourse)/c/\(categorySlug)/\(categoryId)/l/latest.json",
            queryParameters: ["filter": filter]
        )
    }

    public func getCategoryTagTopics(
        categorySlug: String,
        categoryId: Int,
        tag: String,
        sort: DiscourseSort = .latest,
        solvedOnly: Bool = false
    ) async throws -> Any {
        var params: [String: String] = [:]
        if solvedOnly {
            params["solved"] = "yes"
        }
        return try await fetchJSON(
            from: "\(apiDiscourse)/tags/c/\(categorySlug)/\(categoryId)/\(tag)/l/\(sort.rawValue).json",
            queryParameters: params
        )
    }


    public func queryExtensions(
        page: Int = 1,
        shellVersion: String = "all",
        search: String? = nil,
        sort: String? = nil
    ) async throws -> Any {
        var params: [String: String] = [
            "page": String(page),
            "shell_version": shellVersion
        ]
        if let search = search {
            params["search"] = search
        }
        if let sort = sort {
            params["sort"] = sort
        }
        return try await fetchJSON(from: "\(apiExtensions)/extension-query/", queryParameters: params)
    }

    public func getSupportedLanguages() async throws -> Any {
        try await fetchJSON(from: "\(api)/languages.json")
    }
}