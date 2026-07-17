# Medsy iOS Engineering Guide

## Purpose

This document defines the working conventions for contributors and coding agents in the Medsy iOS repository. Treat it as the default engineering contract unless a Jira ticket or an approved architecture decision explicitly overrides it.

Medsy is a SwiftUI application for patients and pharmacies. The codebase uses:

- MVVM for presentation.
- Clean Architecture for dependency direction and separation of concerns.
- Feature-first organization so product work remains independently understandable and testable.
- Swift concurrency (`async`/`await`) for asynchronous work.

The current project is an early SwiftUI starter targeting iOS 18.4. Do not preserve the generated SwiftData sample (`Item`, `ContentView`) as an architectural pattern when product features replace it.

## Source Layout

Keep application code under `Medsy/` and organize it by product feature:

```text
Medsy/
  App/
    MedsyApp.swift
    AppRouter.swift
  Core/
    DI/
    DesignSystem/
    Networking/
    Persistence/
    Security/
    Utilities/
  Features/
    Authentication/
      DI/
        AuthenticationFactory.swift
      Domain/
        Entities/
        Repositories/
        UseCases/
      Data/
        DTOs/
        DataSources/
        Repositories/
        Mappers/
      Presentation/
        Views/
          Components/
        ViewModels/
        Routing/
    Onboarding/
      DI/
        OnboardingFactory.swift
      Domain/
      Data/
      Presentation/
  Resources/
    Assets.xcassets/
    Localization/
```

Mirror production structure in `MedsyTests/`. Keep end-to-end user journeys in `MedsyUITests/`.

Do not create broad type-based root folders such as `Views/`, `Models/`, or `ViewModels/`. A type belongs to its feature unless it is genuinely shared by multiple features. Move code into `Core/` only after a real cross-feature need exists.

## Dependency Rules

Dependencies point inward:

```text
Presentation -> Domain <- Data
       App composes concrete dependencies
```

- `Domain` contains entities, repository protocols, use cases, and business rules. It must not import SwiftUI, SwiftData, UIKit, or concrete networking libraries.
- `Data` implements domain repository protocols and owns API DTOs, persistence models, data sources, and mapping.
- `Presentation` owns SwiftUI views, view models, navigation state, and presentation-only models. It depends on domain abstractions, not concrete data implementations.
- `App` starts the composition root, selects the root flow, and passes shared dependencies from `Core/DI` to each feature factory.
- `Core` contains stable, product-agnostic infrastructure. `Core/DI` registers shared application dependencies only. Features must not depend on each other's `Data` or `Presentation` layers.
- Each feature owns a `DI` folder that assembles its repositories, use cases, view models, and entry views.

Prefer protocols at architectural boundaries. As a project convention, every use case and view model must define a protocol in its owning layer so callers, previews, and tests can inject substitutes. Other concrete types do not require protocols unless they cross an architectural boundary. Avoid global mutable state and service locators.

## Dependency Injection

Keep shared application dependency construction and registration under `Core/DI`:

```text
Core/
  DI/
    AppContainer.swift
    DependencyFactory.swift

Features/
  Authentication/
    DI/
      AuthenticationFactory.swift
  Onboarding/
    DI/
      OnboardingFactory.swift
```

- `AppContainer` owns long-lived shared infrastructure such as the HTTP client, secure storage, persistence stack, and application router.
- `Core/DI` must not import or register individual features.
- A feature factory receives the shared services it needs, constructs that feature's data and domain dependencies, and returns its entry view or coordinator.
- Keep feature-specific repositories in the feature factory rather than `AppContainer`; `AppContainer` should expose only shared infrastructure.
- Pass dependencies through initializers. Do not read dependencies from global singletons or static mutable containers.
- Depend on domain protocols at feature boundaries; keep concrete implementations private to the composition layer when possible.
- Scope stateful dependencies intentionally. Application services may be shared, while view models should normally be created for their feature flow.
- Tests and previews must be able to replace production dependencies with fakes without modifying global state.
- Do not import a feature's `DI` layer from its `Domain`, `Data`, or `Presentation` layers. Only `App` or parent composition code may request assembled feature dependencies.

## MVVM Conventions

- Views render state and forward user intent. Keep business rules, API calls, and persistence out of SwiftUI view bodies.
- Place feature-specific reusable view components under `Presentation/Views/Components/`, next to the feature's screen views. Do not create `Presentation/Components/` as a sibling of `Views/`.
- View models are `@MainActor` and expose explicit screen state. Prefer a single state value when a screen has meaningful loading, content, empty, and error states.
- Define a protocol for every view model in `Presentation/ViewModels/`. Views and factories should depend on the protocol when practical, while the concrete implementation remains responsible for Observation state and behavior.
- Use cases express one business action and are injected into view models.
- Define a protocol for every use case in `Domain/UseCases/`. Name the protocol after the capability and keep the implementation replaceable through constructor injection.
- Repositories hide remote and local storage details from the domain layer.
- Navigation is modeled explicitly through routes or coordinators. Do not scatter navigation decisions across reusable views.
- Use constructor injection. Previews and tests should receive fakes without starting production services.

Example state shape:

```swift
@MainActor
@Observable
final class LoginViewModel {
    enum State: Equatable {
        case idle
        case submitting
        case failed(message: String)
    }

    private(set) var state: State = .idle
}
```

Use the Observation framework for new iOS 18 view models unless an existing feature consistently uses another established approach.

## Swift Standards

- Enable strict concurrency incrementally and keep new code concurrency-safe.
- Prefer value types and immutable values. Use reference types when identity or shared lifetime is required.
- Use typed errors at domain boundaries and translate transport errors before they reach presentation.
- Never log access tokens, OTPs, passwords, prescriptions, personal details, or other health-related data.
- Store credentials and tokens in Keychain-backed infrastructure, never `UserDefaults` or source files.
- Keep DTOs out of views and domain entities out of wire-format decoding concerns.
- Localize user-facing strings and support right-to-left layouts from the beginning.
- Keep accessibility labels, Dynamic Type, loading, empty, offline, and error states part of feature completion.

## Networking

- Put reusable HTTP transport in `Core/Networking`.
- Define endpoint/request details in the owning feature's data layer.
- Decode API responses into DTOs, then map DTOs to domain entities.
- Make cancellation propagate through async calls.
- Centralize authentication headers, refresh behavior, status-code handling, and decoding policy.
- Do not expose `URLSession`, raw response dictionaries, or HTTP status codes through repository protocols.

### Feature Networking Workflow

Implement API-backed feature actions through this dependency chain:

```text
View -> ViewModel -> UseCase -> Repository -> NetworkDataSource -> NetworkService -> Endpoint
```

1. Define a domain input or entity containing only business and user-provided values. Do not include wire-only constants or JSON formatting in the domain layer.
2. Define the repository protocol and use-case protocol in `Domain`. The use case represents one user action and delegates to the repository abstraction.
3. Add request and response DTOs in the feature's `Data/DTOs` folder. Map domain values to exact API keys here, including fixed backend values and date/string formatting.
4. Add an endpoint enum in the feature's `Data/Network` folder and conform it to `ApiEndpoint`. The endpoint owns the path, HTTP method, headers, query parameters, and encoded body.
5. Add a network datasource protocol and implementation in `Data/DataSources`. It must receive `NetworkServiceProtocol` through its initializer, execute the endpoint, decode the response DTO, and never contain presentation behavior.
6. Implement the domain repository protocol in `Data/Repositories`. The repository maps domain input into request DTOs and delegates remote work to the datasource; it must not call `NetworkService` directly.
7. Register the datasource, repository, use case, and feature factory in the feature's assembly. Inject the use case into the view model through the factory/coordinator instead of resolving dependencies inside views or view models.
8. In the `@MainActor` view model, validate local input before starting the request, expose explicit loading/success/error state, prevent duplicate submissions, propagate cancellation, and translate typed errors into displayable messages.
9. In the view, start the async action from user intent, render loading through shared controls, navigate only after success, and present network failures through the shared alert modifier with localized text.
10. Add tests for exact request encoding, endpoint path/method, datasource delegation, repository/use-case forwarding, backend error translation, local-validation short-circuiting, and view-model state transitions. Use fakes and spies; never call a live API.

For APIs that return a shared `{ "success": Bool, "message": String, "data": ... }` envelope, `NetworkService` must inspect the raw envelope before normal status/result handling. A `success: false` response throws `NetworkError.validationError(message)` whether the HTTP status is successful or failing, so the backend message reaches presentation consistently. Responses that do not use this envelope continue through `NetworkErrorHandler` and the existing status-code mapping.

Never log request bodies or sensitive response values. Passwords, OTPs, access tokens, personal details, and health data must not appear in console or analytics logs.

## Jira Workflow

- Product backlog: `https://dawanow.atlassian.net/jira/software/projects/DAWA/boards/1/backlog`
- Reference Jira keys in branches, commits, and pull requests when available.
- Read the parent story and its acceptance criteria before implementing an iOS subtask.
- Do not change Jira status, fields, estimates, or assignees unless the user requests it.
- Keep implementation scope aligned with the selected ticket; avoid bundling unrelated features.

## Backlog Feature Map

The DAWA backlog was reviewed on 2026-07-15. It contains iOS work across these feature areas:

- Splash, onboarding, and role-specific tutorials.
- Patient and pharmacy authentication, registration, OTP, session persistence, and logout.
- Pharmacy receiving-requests availability toggle.
- Medicine search and medicine details.
- Request cart, request submission, and active request status.
- Pharmacy incoming requests and request details.
- Prescription capture, upload, and review.
- Alternative medicine proposals and offer review.
- Patient offer comparison and pharmacy selection.
- Patient order tracking and pharmacy order management.
- Push notifications and deep links.
- Pharmacy promotions and the patient promotion order path.
- Pharmacy profile, order history/reorder, and delivery workflows.

Notable iOS tickets currently visible include `DAWA-20`, `DAWA-23`, `DAWA-26`, `DAWA-29`, `DAWA-32`, `DAWA-35`, `DAWA-38`, `DAWA-41`, `DAWA-44`, `DAWA-47`, `DAWA-59`, `DAWA-62`, `DAWA-65`, `DAWA-71`, `DAWA-74`, `DAWA-77`, and `DAWA-80`, plus later presentation and profile work.

Authentication presentation is currently split into:

- `DAWA-138`: iOS Register.
- `DAWA-139`: iOS Login.

Jira remains the source of truth because backlog scope, ordering, ownership, and acceptance criteria can change.

## Definition of Done

A feature is complete when:

- It follows the dependency rules above and is placed under the owning feature.
- Loading, success, empty, validation, error, and cancellation behavior are handled where applicable.
- Sensitive data is stored and logged safely.
- Accessibility and localization implications are addressed.
- Unit tests cover business rules and view-model behavior; data mapping is tested when introduced.
- The app builds without new warnings and relevant tests pass.
- Documentation is updated when the change introduces a new shared convention or architectural decision.
