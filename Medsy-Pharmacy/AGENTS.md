# Medsy Pharmacy iOS Engineering Guide

## Scope

This guide applies to every file under `Medsy-Pharmacy/`. Treat it as the default contract for contributors and coding agents unless the user, an approved architecture decision, or a more specific nested `AGENTS.md` overrides it.

Medsy Pharmacy is a SwiftUI application targeting iOS 18.4. Use:

- MVVM for presentation.
- Clean Architecture when a feature introduces domain or data behavior.
- Feature-first source organization.
- The Observation framework for new view models.
- Swift concurrency for asynchronous work.


## Source Layout

Keep feature code inside its owning folder:

```text
Medsy-Pharmacy/
  Core/
    AppTheme/
    Configuration/
    DI/
    Localization/
    SharedViews/
  PharmacyCore/
    Navigation/
    SharedViews/
  Features/
    FeatureName/
      DI/
      Domain/
        Entities/
        Repositories/
        UseCases/
      Data/
        DTOs/
        DataSources/
        Network/
        Repositories/
      Presentation/
        Models/
        Navigation/
        ViewModels/
        Views/
          Components/
  Resources/
    ar.lproj/
    en.lproj/
```

The project currently has both `Core/` and `PharmacyCore/`. Follow the established ownership:

- Theme, localization, DI, configuration, and shared controls belong to `Core/`.
- Root navigation types currently belong to `PharmacyCore/Navigation/`.
- Do not introduce another shared root or move existing shared code without an explicit refactor request.

Do not create broad root folders such as `Views/`, `Models/`, or `ViewModels/`. A type belongs to a feature unless at least two features genuinely need it.

## Architecture and Dependency Direction

Dependencies point inward:

```text
Presentation -> Domain <- Data
       App and feature DI compose concrete dependencies
```

- `Domain` contains business entities, repository protocols, use-case protocols, and business rules. It must not import SwiftUI, UIKit, or concrete networking libraries.
- `Data` owns DTOs, endpoints, data sources, mappings, and repository implementations.
- `Presentation` owns views, view models, routes, and presentation-only models.
- A feature must not import another feature's `Data` or `Presentation` layers.
- Move code to `Core` only when it is stable and truly shared.

For API-backed work, preserve this chain:

```text
View -> ViewModel -> UseCase -> Repository -> DataSource -> NetworkService -> Endpoint
```

## Dependency Injection

Each feature owns its composition in `Features/<Feature>/DI/`:

- Add a feature assembly conforming to `PharmacyModuleAssembly`.
- Register the feature factory in that assembly.
- Register the assembly in `Medsy_PharmacyApp`'s module list.
- Resolve top-level factories once at the app composition root and pass them down through initializers.
- A feature factory creates the entry view and injects a fresh view model for that feature flow.
- Construct concrete feature dependencies in the assembly or factory provider closures.
- Do not call `PharmacyAppAssembler.shared` or resolve from `PharmacyDIContainer` inside a view, view model, use case, or repository.
- Do not use global mutable state as feature DI.
- Keep previews and tests able to inject alternate view models, use cases, or actions.

Stateful view models should normally be scoped to one feature screen or coordinator. Shared infrastructure such as networking and secure storage may be application-scoped.

## MVVM and SwiftUI State

- Views render state and forward user intent. Keep filtering rules, validation, networking, persistence, and workflow decisions in the view model or domain layer.
- New view models should be `@MainActor`, `@Observable`, and injected through an initializer.
- When an entry view owns an injected `@Observable` view model, store it with `@State` so SwiftUI preserves its lifetime:

```swift
@State private var viewModel: FeatureViewModel
```

- Use bindings such as `$viewModel.searchText` for editable child-component state.
- Use `@Bindable` only when a binding is needed from an observable reference that is not already exposed through a property wrapper providing bindings.
- Keep reusable components stateless where practical. Pass values, bindings, and intent closures into them.
- Put each meaningful reusable component in its own file under `Presentation/Views/Components/`.
- Keep navigation decisions in routes or coordinators, not reusable components.

## Theme and Reusable UI

- Use tokens from `Core/AppTheme/PharmacyAppTheme.swift`; do not hardcode screen-specific light-mode colors.
- Every new color must define suitable light and dark behavior through `PharmacyColor` when applicable.
- Use `PharmacySpacing`, `PharmacyRadius`, and `PharmacyColor.sans` consistently.
- Reuse controls from `Core/SharedViews/`, including `PharmacyPrimaryButton`, before creating feature-specific duplicates.
- Adapt external Android references to native iOS behavior, spacing, accessibility, safe areas, and interaction patterns.
- Support Dynamic Type where practical and avoid fixed frames that clip localized text.

## Localization and Accessibility

- Localize every user-facing string in both:
  - `Resources/en.lproj/Localizable.strings`
  - `Resources/ar.lproj/Localizable.strings`
- Read localized values through the existing `.localized` helpers.
- Apply the existing pharmacy localization environment at app and preview boundaries.
- Design layouts semantically with leading/trailing alignment so Arabic RTL mirroring works naturally.
- Do not hardcode English sample names, addresses, statuses, errors, or accessibility labels in views.
- Add accessibility labels and traits to icon-only buttons, selections, headers, and custom controls.

## Networking and Security

- Put reusable transport behavior in Core networking infrastructure and endpoint definitions in the owning feature's data layer.
- Convert DTOs to domain entities before values reach presentation.
- Inject repository protocols into use cases and use-case protocols into view models.
- Propagate cancellation through asynchronous work.
- Never log access tokens, refresh tokens, OTPs, passwords, prescriptions, addresses, phone numbers, or health data.
- Store credentials only through Keychain-backed infrastructure, never `UserDefaults` or source files.
- Translate transport failures into typed domain or presentation errors before displaying them.

## Verification

Before handing off a change:

- Run `git diff --check`.
- Build the pharmacy target:

```sh
xcodebuild -quiet -project Medsy.xcodeproj -scheme Medsy-Pharmacy -sdk iphonesimulator -configuration Debug build CODE_SIGNING_ALLOWED=NO
```

- Add or update unit tests for view-model logic, domain rules, mappings, and dependency delegation when behavior is introduced.
- Keep UI tests for critical end-to-end journeys.
- Confirm Arabic and English layouts, light and dark themes, empty states, and accessibility behavior for UI work.
- Do not overwrite or remove unrelated working-tree changes.

## Definition of Done

A pharmacy feature is complete when:

- It follows feature-first ownership and dependency direction.
- Its factory and assembly correctly compose feature dependencies.
- Views contain presentation code while view models/domain types own behavior.
- User-facing text supports Arabic and English with correct RTL behavior.
- Theme tokens support light and dark appearances.
- Loading, content, empty, error, and cancellation states are handled where applicable.
- Sensitive information is stored and logged safely.
- The target builds without new warnings and relevant tests pass.
