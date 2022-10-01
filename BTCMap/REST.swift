//
//  REST.swift
//  BTC Map
//
//  Created by Vitaly Berg on 10/1/22.
//

import Foundation

class REST {
    let base: URL
    let queue: DispatchQueue
    
    init(base: URL, queue: DispatchQueue = .main) {
        self.base = base
        self.queue = queue
        self.session = .init(configuration: .default)
    }
    
    private(set) var session: URLSession!
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
    
    typealias Completion<Response> = (Result<Response, Error>) -> Void
    typealias Query = [String: String]
    
    enum RequestError: Error {
        case badURL
        case badBody(Error)
    }
    
    enum ResponseError: Error {
        case noResponse
        case notOK(Int)
        case noBody
        case badBody(Error)
    }
    
    struct NoBody: Codable {}
    
    func url(_ path: String, query: Query? = nil) -> URL? {
        guard let url = URL(string: path, relativeTo: base) else { return nil }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return nil }
        if let query = query, !query.isEmpty {
            components.queryItems = query.map { .init(name: $0.key, value: $0.value) }
        }
        return components.url
    }
    
    func request<Body: Encodable>(_ method: String, path: String, query: Query? = nil, body: Body?) throws -> URLRequest {
        guard let url = url(path, query: query) else { throw RequestError.badURL }
        var request = URLRequest(url: url, timeoutInterval: 30)
        
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw RequestError.badBody(error)
            }
        }
        
        return request
    }
    
    func handleTaskCompletion<Body: Decodable>(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Result<Body, Error> {
        if let error = error {
            return .failure(error)
        }
        guard let response = response as? HTTPURLResponse else {
            return .failure(ResponseError.noResponse)
        }
        guard 200 ..< 300 ~= response.statusCode else {
            return .failure(ResponseError.notOK(response.statusCode))
        }
        guard Body.self != NoBody.self else {
            return .success(NoBody() as! Body)
        }
        guard let data = data else {
            return .failure(ResponseError.noBody)
        }
        do {
            let body = try decoder.decode(Body.self, from: data)
            return .success(body)
        } catch {
            return .failure(ResponseError.badBody(error))
        }
    }
    
    func `do`<Request: Encodable, Response: Decodable>(_ method: String, path: String, query: Query? = nil, body: Request?, completion: @escaping Completion<Response>) {
        do {
            let request = try request(method, path: path, query: query, body: body)
            let task = session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                let result: Result<Response, Error> = self.handleTaskCompletion(data, response, error)
                self.queue.async { completion(result) }
            }
            task.resume()
        } catch {
            queue.async { completion(.failure(error)) }
        }
    }
    
    func get<Response: Decodable>(_ path: String, query: Query? = nil, completion: @escaping Completion<Response>) {
        self.do("GET", path: path, query: query, body: Optional<NoBody>.none, completion: completion)
    }
}
