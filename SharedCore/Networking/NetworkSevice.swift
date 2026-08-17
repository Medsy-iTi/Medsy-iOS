//
//  NetworkSevice.swift
//  Medsy
//
//  Created by Ehab Salah on 14/07/2026.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    private let transport: NetworkTransportProtocol
    private let requestBuilder: NetworkRequestBuilder
    private let tokenStore: TokenStoreProtocol?
    private let tokenRefresher: TokenRefreshing?

    init(
        transport: NetworkTransportProtocol,
        requestBuilder: NetworkRequestBuilder,
        tokenStore: TokenStoreProtocol? = nil,
        tokenRefresher: TokenRefreshing? = nil
    ) {
        self.transport = transport
        self.requestBuilder = requestBuilder
        self.tokenStore = tokenStore
        self.tokenRefresher = tokenRefresher
    }

    func request<T: Decodable>(endpoint: ApiEndpoint) async throws -> T {
        try await execute(endpoint: endpoint, hasRetriedAfterRefresh: false)
    }

    func requestData(endpoint: ApiEndpoint) async throws -> Data {
        let urlRequest = try requestBuilder.makeRequest(
            for: endpoint,
            accessToken: endpoint.requiresAuthentication ? tokenStore?.accessToken() : nil
        )
        print("[Network] \(endpoint.method.rawValue) \(urlRequest.url?.absoluteString ?? endpoint.path)")
        let response: NetworkResponse
        do {
            response = try await transport.execute(urlRequest)
        } catch {
            throw NetworkErrorHandler.map(error: error, statusCode: nil, data: nil)
        }
        print("[Network] Status: \(response.statusCode ?? 0), bytes: \(response.data?.count ?? 0)")
        guard let statusCode = response.statusCode, (200...299).contains(statusCode),
              let data = response.data else {
            throw NetworkErrorHandler.map(
                error: NetworkError.unacceptableStatusCode(response.statusCode ?? 0),
                statusCode: response.statusCode,
                data: response.data
            )
        }
        return data
    }

    func streamSSE(endpoint: ApiEndpoint) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            final class StreamSessionHolder: @unchecked Sendable {
                var session: URLSession?
                func cancel() {
                    session?.invalidateAndCancel()
                    session = nil
                }
            }

            let sessionHolder = StreamSessionHolder()

            let task = Task {
                var lastActivityDate = Date()

                // Watchdog to abort half-open hung TCP sockets if no keep-alive is received within 35s
                let watchdogTask = Task {
                    while !Task.isCancelled {
                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                        if Task.isCancelled { break }
                        let elapsed = Date().timeIntervalSince(lastActivityDate)
                        if elapsed > 35 {
                            print("[Network SSE] ⏱️ Inactivity watchdog timeout (>35s), invalidating dead socket...")
                            sessionHolder.cancel()
                            break
                        }
                    }
                }

                defer {
                    watchdogTask.cancel()
                    sessionHolder.cancel()
                }

                do {
                    var request = try requestBuilder.makeRequest(
                        for: endpoint,
                        accessToken: endpoint.requiresAuthentication ? tokenStore?.accessToken() : nil
                    )
                    request.setValue("text/event-stream", forHTTPHeaderField: "Accept")
                    request.setValue("no-cache, no-transform", forHTTPHeaderField: "Cache-Control")
                    request.setValue("keep-alive", forHTTPHeaderField: "Connection")
                    request.setValue("no", forHTTPHeaderField: "X-Accel-Buffering")

                    print("[Network SSE] 🚀 Stream starting for endpoint: \(endpoint.method.rawValue) \(request.url?.absoluteString ?? endpoint.path)")

                    let config = URLSessionConfiguration.default
                    config.timeoutIntervalForRequest = 20
                    config.timeoutIntervalForResource = 900
                    config.waitsForConnectivity = false
                    config.allowsCellularAccess = true
                    config.allowsExpensiveNetworkAccess = true
                    config.allowsConstrainedNetworkAccess = true
                    config.networkServiceType = .responsiveData

                    let session = URLSession(configuration: config)
                    sessionHolder.session = session

                    let (bytes, response) = try await session.bytes(for: request)
                    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                        print("[Network SSE] ❌ HTTP Error status code: \(httpResponse.statusCode)")
                        throw NetworkErrorHandler.map(
                            error: NetworkError.unacceptableStatusCode(httpResponse.statusCode),
                            statusCode: httpResponse.statusCode,
                            data: nil
                        )
                    }

                    print("[Network SSE] ✅ Stream HTTP connection established successfully!")
                    continuation.yield(SSEEvent(event: "connected", data: ""))
                    lastActivityDate = Date()

                    var currentEvent = ""
                    var currentData = ""

                    func flushCurrentEvent() {
                        let trimmedData = currentData.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedData.isEmpty || !currentEvent.isEmpty {
                            print("[Network SSE Yielding] Event: '\(currentEvent)', Data: '\(trimmedData)'")
                            continuation.yield(SSEEvent(event: currentEvent, data: trimmedData))
                            currentEvent = ""
                            currentData = ""
                        }
                    }

                    for try await line in bytes.lines {
                        if Task.isCancelled {
                            print("[Network SSE] ⏹️ Task cancelled, stopping stream loop.")
                            break
                        }
                        lastActivityDate = Date()
                        print("[Network SSE Line] \(line)")

                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)

                        if trimmed.hasPrefix(":") {
                            // Keepalive heartbeat comment from server; yield heartbeat event to refresh liveness
                            continuation.yield(SSEEvent(event: "heartbeat", data: ""))
                            continue
                        }

                        if trimmed.isEmpty {
                            flushCurrentEvent()
                        } else if trimmed.hasPrefix("event:") {
                            flushCurrentEvent()
                            currentEvent = trimmed.dropFirst(6).trimmingCharacters(in: .whitespaces)
                        } else if trimmed.hasPrefix("data:") {
                            let dataPart = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
                            if currentData.isEmpty {
                                currentData = dataPart
                            } else {
                                currentData += "\n" + dataPart
                            }

                            let dataCheck = currentData.trimmingCharacters(in: .whitespacesAndNewlines)
                            if (dataCheck.hasPrefix("{") && dataCheck.hasSuffix("}")) || (dataCheck.hasPrefix("[") && dataCheck.hasSuffix("]")) {
                                flushCurrentEvent()
                            }
                        }
                    }

                    flushCurrentEvent()
                    print("[Network SSE] Stream finished clean.")
                    continuation.finish()
                } catch {
                    if !Task.isCancelled {
                        print("[Network SSE Error] Stream exception: \(error)")
                    }
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { reason in
                print("[Network SSE] Stream terminated with reason: \(reason)")
                task.cancel()
                sessionHolder.cancel()
            }
        }
    }

    private func execute<T: Decodable>(
        endpoint: ApiEndpoint,
        hasRetriedAfterRefresh: Bool
    ) async throws -> T {
        let request = try requestBuilder.makeRequest(
            for: endpoint,
            accessToken: endpoint.requiresAuthentication ? tokenStore?.accessToken() : nil
        )

        print("[Network] \(endpoint.method.rawValue) \(endpoint.path) [Started]")

        let response: NetworkResponse
        do {
            response = try await transport.execute(request)
        } catch {
            throw NetworkErrorHandler.map(error: error, statusCode: nil, data: nil)
        }

        logResponse(response.data, statusCode: response.statusCode, endpoint: endpoint)

        if response.statusCode == 401, endpoint.requiresAuthentication {
            guard let tokenStore, let tokenRefresher else {
                throw NetworkError.unauthorized
            }

            guard !hasRetriedAfterRefresh else {
                try? tokenStore.clearTokens()
                throw NetworkError.unauthorized
            }

            do {
                try await tokenRefresher.refreshTokens()
            } catch {
                try? tokenStore.clearTokens()
                throw NetworkError.unauthorized
            }

            return try await execute(endpoint: endpoint, hasRetriedAfterRefresh: true)
        }

        if let apiError = NetworkErrorHandler.apiEnvelopeError(from: response.data) {
            throw apiError
        }

        guard let statusCode = response.statusCode, (200...299).contains(statusCode),
              let data = response.data else {
            throw NetworkErrorHandler.map(
                error: NetworkError.unacceptableStatusCode(response.statusCode ?? 0),
                statusCode: response.statusCode,
                data: response.data
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func logResponse(_ data: Data?, statusCode: Int?, endpoint: ApiEndpoint) {
        guard endpoint.allowsResponseLogging, let data else { return }
        print("[Network] \(endpoint.method.rawValue) \(endpoint.path) [Status: \(statusCode ?? 0)]")
        print(JsonHelper.prettyJSON(data))
    }
}
