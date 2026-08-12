//
//  FavoritesAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 13/08/2026.
//

struct FavoritesAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        let localDataSource: FavoriteLocalDataSource
        do {
            localDataSource = try FavoriteLocalDataSource()
        } catch {
            fatalError("Unable to create favorites persistence: \(error.localizedDescription)")
        }

        container.register(FavoriteLocalDataSourceProtocol.self) { _ in localDataSource }
        container.register(FavoriteRepositoryProtocol.self) { container in
            FavoriteRepository(
                localDataSource: container.resolve(FavoriteLocalDataSourceProtocol.self),
                accountScopeProvider: container.resolve(AccountScopeProviderProtocol.self)
            )
        }
        container.register(FetchFavoritesUseCaseProtocol.self) { container in
            FetchFavoritesUseCase(repository: container.resolve(FavoriteRepositoryProtocol.self))
        }
        container.register(IsFavoriteUseCaseProtocol.self) { container in
            IsFavoriteUseCase(repository: container.resolve(FavoriteRepositoryProtocol.self))
        }
        container.register(SetFavoriteUseCaseProtocol.self) { container in
            SetFavoriteUseCase(repository: container.resolve(FavoriteRepositoryProtocol.self))
        }
        container.register(FavoriteViewModel.self) { container in
            MainActor.assumeIsolated {
                FavoriteViewModel(
                    fetchFavoritesUseCase: container.resolve(FetchFavoritesUseCaseProtocol.self),
                    setFavoriteUseCase: container.resolve(SetFavoriteUseCaseProtocol.self),
                    connectivity: container.resolve(NetworkConnectivityProviding.self),
                    languageManager: container.resolve(LanguageManager.self)
                )
            }
        }
    }
}
