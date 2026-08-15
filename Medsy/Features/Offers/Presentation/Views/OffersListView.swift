import SwiftUI

struct OffersListView: View {
    @State private var viewModel = OffersListViewModel()
    let onBack: () -> Void
    var onOfferSelected: ((OfferResult, Int) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.subtitleText.isEmpty {
                Text(viewModel.subtitleText)
                    .font(AppColor.sans(13))
                    .foregroundStyle(AppColor.textSec)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, MedsySpacing.md)
                    .padding(.vertical, MedsySpacing.xs)
            }

            if viewModel.isLoading && viewModel.offers.isEmpty {
                Spacer()
                ProgressView()
                    .tint(AppColor.green)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.offers) { offer in
                            OfferCardView(
                                offer: offer,
                                onTap: {
                                    if let reqId = Int(offer.id), let result = viewModel.offerResultsMap[reqId] {
                                        onOfferSelected?(result, reqId)
                                    }
                                }
                            )
                        }

                        Spacer().frame(height: 8)

                        OffersInfoBannerView()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(AppColor.bg.ignoresSafeArea())
        .navigationTitle("offers.list.title".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
