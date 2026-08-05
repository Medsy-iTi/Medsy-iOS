//
//  MedicineAnalyzeAssembly.swift
//  Medsy
//
//  Created by Ehab Salah on 23/07/2026.
//

struct MedicineAnalyzeAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(MedicineAnalyzeRemoteDataSourceProtocol.self) { container in
            MedicineAnalyzeRemoteDataSource(
                networkService: container.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(MedicineAnalyzeRepositoryProtocol.self) { container in
            MedicineAnalyzeRepository(
                remoteDataSource: container.resolve(MedicineAnalyzeRemoteDataSourceProtocol.self)
            )
        }

        container.register(AnalyzeMedicineImageUseCaseProtocol.self) { container in
            AnalyzeMedicineImageUseCase(
                repository: container.resolve(MedicineAnalyzeRepositoryProtocol.self)
            )
        }

        container.register(MedicineAnalyzeViewModelProtocol.self) { container in
            let languageManager = container.resolve(LanguageManager.self)
            return MainActor.assumeIsolated {
                MedicineAnalyzeViewModel(
                    analyzeMedicineImageUseCase: container.resolve(AnalyzeMedicineImageUseCaseProtocol.self),
                    languageProvider: { languageManager.languageCode }
                )
            }
        }
    }
}
