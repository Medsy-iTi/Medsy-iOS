//  CategoriesAssembly.swift
//  Medsy
//
//  Created by Antoneos Philip on 14/07/2026.

struct CategoriesAssembly: ModuleAssembly {
    func register(in container: DIContainer) {
        container.register(CategoryRepository.self) { c in
            CategoryRepositoryImpl(
                networkService: c.resolve(NetworkServiceProtocol.self)
            )
        }

        container.register(GetCategoriesUseCase.self) { c in
            GetCategoriesUseCase(
                repository: c.resolve(CategoryRepository.self)
            )
        }

        container.register(CategoriesViewModel.self) { c in
            CategoriesViewModel(
                getCategoriesUseCase: c.resolve(GetCategoriesUseCase.self)
            )
        }
    }
}
