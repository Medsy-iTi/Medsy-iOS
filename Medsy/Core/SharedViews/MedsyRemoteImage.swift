import Foundation
import Observation
import SwiftUI
import UIKit

struct MedsyRemoteImage<Placeholder: View, Failure: View>: View {
    let urlString: String?
    let contentMode: ContentMode
    private let placeholder: () -> Placeholder
    private let failure: () -> Failure

    @State private var loader = MedsyRemoteImageLoader()

    init(
        urlString: String?,
        contentMode: ContentMode = .fit,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder failure: @escaping () -> Failure
    ) {
        self.urlString = urlString
        self.contentMode = contentMode
        self.placeholder = placeholder
        self.failure = failure
    }

    var body: some View {
        Group {
            switch loader.phase {
            case .idle, .loading:
                placeholder()
            case let .success(image):
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                failure()
            }
        }
        .task(id: urlString) {
            await loader.load(urlString)
        }
    }
}

@MainActor
@Observable
private final class MedsyRemoteImageLoader {
    enum Phase {
        case idle
        case loading
        case success(UIImage)
        case failure
    }

    private(set) var phase: Phase = .idle
    private var currentURL: URL?

    func load(_ rawURL: String?) async {
        guard let url = MedsyImageURL.normalized(rawURL) else {
            currentURL = nil
            phase = .failure
            return
        }

        currentURL = url
        phase = .loading

        do {
            let data = try await MedsyImagePipeline.shared.data(for: url)
            guard !Task.isCancelled, currentURL == url else { return }
            guard let image = UIImage(data: data) else {
                await MedsyImagePipeline.shared.removeCachedData(for: url)
                if !Task.isCancelled, currentURL == url {
                    phase = .failure
                }
                return
            }
            phase = .success(image)
        } catch is CancellationError {
            return
        } catch {
            guard currentURL == url else { return }
            phase = .failure
        }
    }
}

private enum MedsyImageURL {
    static func normalized(_ rawValue: String?) -> URL? {
        guard let value = rawValue?
            .trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty,
              let components = URLComponents(string: value),
              let scheme = components.scheme?.lowercased(),
              scheme == "https" || scheme == "http",
              components.host != nil else {
            return nil
        }
        return components.url
    }
}

private actor MedsyImagePipeline {
    static let shared = MedsyImagePipeline()

    private let cache = NSCache<NSURL, NSData>()
    private var inFlight: [URL: Task<Data, Error>] = [:]

    init() {
        cache.countLimit = 150
        cache.totalCostLimit = 40 * 1_024 * 1_024
    }

    func data(for url: URL) async throws -> Data {
        if let cached = cache.object(forKey: url as NSURL) {
            return cached as Data
        }

        if let existingTask = inFlight[url] {
            return try await existingTask.value
        }

        let task = Task.detached(priority: .utility) {
            try await Self.download(from: url)
        }
        inFlight[url] = task

        do {
            let data = try await task.value
            cache.setObject(data as NSData, forKey: url as NSURL, cost: data.count)
            inFlight[url] = nil
            return data
        } catch {
            inFlight[url] = nil
            throw error
        }
    }

    func removeCachedData(for url: URL) {
        cache.removeObject(forKey: url as NSURL)
    }

    private nonisolated static func download(from url: URL) async throws -> Data {
        var lastError: Error = URLError(.cannotLoadFromNetwork)

        for attempt in 0..<2 {
            do {
                var request = URLRequest(
                    url: url,
                    cachePolicy: .returnCacheDataElseLoad,
                    timeoutInterval: 20
                )
                request.setValue("image/avif,image/webp,image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")

                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200..<300).contains(httpResponse.statusCode),
                      httpResponse.mimeType?.hasPrefix("image/") == true,
                      !data.isEmpty else {
                    throw URLError(.badServerResponse)
                }
                return data
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                lastError = error
                if attempt == 0 {
                    try await Task.sleep(for: .milliseconds(250))
                }
            }
        }

        throw lastError
    }
}
