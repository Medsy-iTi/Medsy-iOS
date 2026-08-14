// PharmacyProductSearchView.swift

import SwiftUI

struct PharmacyProductSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PharmacyProductSearchViewModel()
    @State private var searchTask: Task<Void, Never>? = nil
    @FocusState private var isSearchFocused: Bool

    let onSelectProduct: (PharmacyProductDTO) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: PharmacySpacing.xs) {
                    HStack(spacing: PharmacySpacing.xs) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(PharmacyColor.textSecondary)
                        
                        TextField("pharmacy.request.product_search.placeholder".localized, text: $viewModel.searchQuery)
                            .font(PharmacyColor.sans(14))
                            .foregroundStyle(PharmacyColor.textPrimary)
                            .autocorrectionDisabled()
                            .focused($isSearchFocused)
                        
                        if !viewModel.searchQuery.isEmpty {
                            Button {
                                viewModel.searchQuery = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(PharmacyColor.textSecondary)
                            }
                        }
                    }
                    .padding(.horizontal, PharmacySpacing.sm)
                    .frame(minHeight: 50)
                    .pharmacyInputSurface(isFocused: isSearchFocused)
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Label(error, systemImage: "exclamationmark.triangle.fill")
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.danger)
                        .multilineTextAlignment(.center)
                        .pharmacyCard(elevation: .subtle)
                        .padding(.horizontal, PharmacySpacing.md)
                    Spacer()
                } else if viewModel.products.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        PharmacyIconTile(systemImage: "magnifyingglass", size: 64, iconSize: 26)
                        Text(
                            viewModel.searchQuery.isEmpty
                                ? "pharmacy.request.product_search.prompt".localized
                                : "pharmacy.request.product_search.empty".localized
                        )
                            .font(PharmacyColor.sans(14, .semibold))
                            .foregroundStyle(PharmacyColor.textSecondary)
                    }
                    .pharmacyCard(elevation: .subtle)
                    .padding(.horizontal, PharmacySpacing.md)
                    Spacer()
                } else {
                    List(viewModel.products) { product in
                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous)
                                    .fill(PharmacyColor.primarySoft.opacity(0.6))
                                    .frame(width: 48, height: 48)

                                if let imageUrlStr = product.imageUrl, let url = URL(string: imageUrlStr) {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 48, height: 48)
                                            .clipShape(RoundedRectangle(cornerRadius: PharmacyRadius.sm, style: .continuous))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                } else {
                                    Image(systemName: "pill.fill")
                                        .font(.system(size: 18))
                                        .foregroundStyle(PharmacyColor.primary.opacity(0.4))
                                }
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.productName ?? product.name ?? "")
                                    .font(PharmacyColor.sans(14, .bold))
                                    .foregroundStyle(PharmacyColor.textPrimary)

                                HStack(spacing: 6) {
                                    if let form = product.form, !form.isEmpty {
                                        Text(form)
                                            .font(PharmacyColor.sans(10, .medium))
                                            .foregroundStyle(PharmacyColor.primary)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(PharmacyColor.primarySoft.opacity(0.5), in: Capsule())
                                    }
                                    if let strength = product.strength, !strength.isEmpty {
                                        Text(strength)
                                            .font(PharmacyColor.sans(10, .medium))
                                            .foregroundStyle(PharmacyColor.textSecondary)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(PharmacyColor.border, in: Capsule())
                                    }
                                    if let packSize = product.packSize, !packSize.isEmpty {
                                        Text(packSize)
                                            .font(PharmacyColor.sans(10, .medium))
                                            .foregroundStyle(PharmacyColor.textSecondary)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 1)
                                            .background(PharmacyColor.border, in: Capsule())
                                    }
                                }

                                if let price = product.price {
                                    Text("\(Int(price)) \("pharmacy.request.currency_unit".localized)")
                                        .font(PharmacyColor.sans(12, .bold))
                                        .foregroundStyle(PharmacyColor.textSecondary)
                                }
                            }

                            Spacer()

                            Button {
                                onSelectProduct(product)
                                dismiss()
                            } label: {
                                Text("pharmacy.request.product_search.select".localized)
                                    .font(PharmacyColor.sans(12, .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(PharmacyColor.primary, in: Capsule())
                            }
                            .buttonStyle(PharmacyPressableButtonStyle())
                        }
                        .pharmacyCard(
                            cornerRadius: PharmacyRadius.md,
                            padding: PharmacySpacing.sm,
                            elevation: .subtle
                        )
                        .listRowInsets(
                            EdgeInsets(
                                top: PharmacySpacing.xs,
                                leading: PharmacySpacing.md,
                                bottom: PharmacySpacing.xs,
                                trailing: PharmacySpacing.md
                            )
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .background(PharmacyColor.bg)
                }
            }
            .background(PharmacyColor.bg)
            .navigationTitle("pharmacy.request.product_search.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel".localized) {
                        dismiss()
                    }
                    .font(PharmacyColor.sans(14, .medium))
                    .foregroundStyle(PharmacyColor.textSecondary)
                }
            }
        }
        .onChange(of: viewModel.searchQuery) { oldValue, newValue in
            searchTask?.cancel()
            searchTask = Task {
                try? await Task.sleep(nanoseconds: 350_000_000)
                await viewModel.performSearch()
            }
        }
    }
}
