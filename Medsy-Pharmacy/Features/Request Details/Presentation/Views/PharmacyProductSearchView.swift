// PharmacyProductSearchView.swift

import SwiftUI

struct PharmacyProductSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = PharmacyProductSearchViewModel()
    @State private var searchTask: Task<Void, Never>? = nil

    let onSelectProduct: (PharmacyProductDTO) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack(spacing: PharmacySpacing.xs) {
                    HStack(spacing: PharmacySpacing.xs) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(PharmacyColor.textSecondary)
                        
                        TextField("البحث عن المنتجات...", text: $viewModel.searchQuery)
                            .font(PharmacyColor.sans(14))
                            .foregroundStyle(PharmacyColor.textPrimary)
                            .autocorrectionDisabled()
                        
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
                    .padding(.vertical, 10)
                    .background(PharmacyColor.mutedSurface, in: RoundedRectangle(cornerRadius: PharmacyRadius.md))
                }
                .padding(.horizontal, PharmacySpacing.md)
                .padding(.vertical, PharmacySpacing.sm)

                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let error = viewModel.errorMessage {
                    Spacer()
                    Text(error)
                        .font(PharmacyColor.sans(14, .medium))
                        .foregroundStyle(PharmacyColor.danger)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                } else if viewModel.products.isEmpty {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "square.dashed")
                            .font(.system(size: 40))
                            .foregroundStyle(PharmacyColor.textSecondary)
                        Text(viewModel.searchQuery.isEmpty ? "اكتب للبحث عن بديل" : "لا توجد نتائج بحث")
                            .font(PharmacyColor.sans(14, .semibold))
                            .foregroundStyle(PharmacyColor.textSecondary)
                    }
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
                                Text("اختر")
                                    .font(PharmacyColor.sans(12, .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 6)
                                    .background(PharmacyColor.primary, in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(PharmacyColor.card)
                    }
                    .listStyle(.plain)
                    .background(PharmacyColor.bg)
                }
            }
            .background(PharmacyColor.bg)
            .navigationTitle("البحث عن بديل")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("إلغاء") {
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
