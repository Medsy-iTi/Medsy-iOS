struct PrescriptionAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(PrescriptionRemoteDataSourceProtocol.self) { container in
            PrescriptionRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(PrescriptionRepositoryProtocol.self) { container in
            PrescriptionRepository(
                remoteDataSource: container.resolve(PrescriptionRemoteDataSourceProtocol.self)
            )
        }

        container.register(AnalyzePrescriptionUseCaseProtocol.self) { container in
            AnalyzePrescriptionUseCase(
                repository: container.resolve(PrescriptionRepositoryProtocol.self)
            )
        }

        container.register(PrescriptionViewModel.self) { container in
            let languageManager = container.resolve(LanguageManager.self)
            return MainActor.assumeIsolated {
                PrescriptionViewModel(
                    analyzePrescriptionUseCase: container.resolve(AnalyzePrescriptionUseCaseProtocol.self),
                    languageProvider: { languageManager.languageCode }
                )
            }
        }
    }
}
