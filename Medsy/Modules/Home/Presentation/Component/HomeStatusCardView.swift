import SwiftUI

enum HomeSearchStatus: String, CaseIterable, Identifiable {
    case home
    case searching
    case firstOffer
    case multipleOffers
    case expired
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .home:
            return "home.status.home".localized
        case .searching:
            return "home.status.searching".localized
        case .firstOffer:
            return "home.status.firstOffer".localized
        case .multipleOffers:
            return "home.status.multipleOffers".localized
        case .expired:
            return "home.status.expired".localized
        }
    }
}

struct HomeStatusSelectorView: View {
    @Binding var selectedStatus: HomeSearchStatus
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(HomeSearchStatus.allCases) { status in
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            selectedStatus = status
                        }
                    } label: {
                        Text(status.title)
                            .font(AppColor.sans(13, selectedStatus == status ? .bold : .medium))
                            .foregroundStyle(selectedStatus == status ? AppColor.white : AppColor.green)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Group {
                                    if selectedStatus == status {
                                        Capsule()
                                            .fill(AppColor.green)
                                    } else {
                                        Color.clear
                                    }
                                }
                            )
                    }
                }
            }
            .padding(4)
            .background(
                Capsule()
                    .stroke(AppColor.green.opacity(0.15), lineWidth: 1.5)
                    .background(AppColor.card.clipShape(Capsule()))
            )
            .padding(.horizontal)
        }
    }
}

struct HomeSearchingStatusView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedStatus: HomeSearchStatus
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    selectedStatus = .home
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.textSec)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("home.status.searching.title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)
                    
                    Text("home.status.searching.subtitle".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }
                
                ZStack {
                    Circle()
                        .fill(AppColor.green)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .heavy))
                        .foregroundStyle(.white)
                        .offset(x: -3, y: -3)
                }
            }
            
            HStack {
                Text("00:41")
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.green)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("home.status.searching.time".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                    
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.textSec)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.card)
            )
            
            VStack(spacing: 12) {
                HStack(alignment: .top, spacing: 0) {
                    VStack(spacing: 4) {
                        Text("home.status.searching.stage3".localized)
                            .font(AppColor.sans(11, .bold))
                            .foregroundStyle(AppColor.textSec)
                        
                        Text("home.status.searching.stage3Desc".localized)
                            .font(AppColor.sans(9))
                            .foregroundStyle(AppColor.textSec)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("home.status.searching.stage2".localized)
                            .font(AppColor.sans(11, .bold))
                            .foregroundStyle(AppColor.green)
                        
                        Text("home.status.searching.stage2Desc".localized)
                            .font(AppColor.sans(9))
                            .foregroundStyle(AppColor.green)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack(spacing: 4) {
                        Text("home.status.searching.stage1".localized)
                            .font(AppColor.sans(11, .bold))
                            .foregroundStyle(AppColor.textSec)
                        
                        Text("home.status.searching.stage1Desc".localized)
                            .font(AppColor.sans(9))
                            .foregroundStyle(AppColor.textSec)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                ZStack {
                    HStack(spacing: 0) {
                        AppColor.green
                            .frame(height: 3)
                        
                        Color.gray.opacity(0.2)
                            .frame(height: 3)
                    }
                    
                    HStack(spacing: 0) {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 3)
                            .background(Circle().fill(AppColor.card))
                            .frame(width: 14, height: 14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Circle()
                            .stroke(AppColor.green, lineWidth: 3)
                            .background(Circle().fill(AppColor.green.opacity(0.2)))
                            .frame(width: 14, height: 14)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Circle()
                            .fill(AppColor.green)
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(AppColor.card, lineWidth: 3)
                            )
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Text("home.status.searching.notify".localized)
                .font(AppColor.sans(11))
                .foregroundStyle(AppColor.textSec)
                .multilineTextAlignment(.center)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColor.green.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppColor.green.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct HomeFirstOfferStatusView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedStatus: HomeSearchStatus
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    selectedStatus = .home
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.textSec)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("home.status.firstOffer.title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)
                    
                    Text("home.status.firstOffer.subtitle".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }
                
                ZStack {
                    Circle()
                        .fill(AppColor.green)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
            }
            
            HStack {
                Text("00:36")
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.green)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("home.status.searching.time".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                    
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.textSec)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.card)
            )
            
            HStack(spacing: 12) {
                Button {
                } label: {
                    Text("home.status.firstOffer.showOffer".localized)
                        .font(AppColor.sans(12, .bold))
                        .foregroundStyle(AppColor.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColor.green)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("home.status.firstOffer.priceFrom".localized)
                        .font(AppColor.sans(11))
                        .foregroundStyle(AppColor.textSec)
                    
                    Text("home.status.firstOffer.priceValue".localized)
                        .font(AppColor.sans(15, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 32)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("home.status.firstOffer.availableMeds".localized)
                        .font(AppColor.sans(11))
                        .foregroundStyle(AppColor.textSec)
                    
                    Text("home.status.firstOffer.medsCount".localized)
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.green.opacity(0.12), lineWidth: 1)
                    )
            )
            
            Button {
            } label: {
                Text("home.status.firstOffer.continueCompare".localized)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.green)
                    .cornerRadius(16)
            }
            
            Button {
            } label: {
                HStack(spacing: 4) {
                    Text("home.status.firstOffer.orderDetails".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.green)
                    
                    Image(systemName: languageManager.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColor.green.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppColor.green.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct HomeMultipleOffersStatusView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedStatus: HomeSearchStatus
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    selectedStatus = .home
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.textSec)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("home.status.multipleOffers.title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)
                    
                    Text("home.status.multipleOffers.subtitle".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }
                
                ZStack {
                    Circle()
                        .fill(AppColor.green)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                }
            }
            
            HStack {
                Text("00:00")
                    .font(AppColor.sans(16, .bold))
                    .foregroundStyle(AppColor.green)
                
                Spacer()
                
                HStack(spacing: 6) {
                    Text("home.status.searching.time".localized)
                        .font(AppColor.sans(13))
                        .foregroundStyle(AppColor.textSec)
                    
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                        .foregroundStyle(AppColor.textSec)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.card)
            )
            
            HStack(spacing: 12) {
                Button {
                } label: {
                    Text("home.status.firstOffer.showOffer".localized)
                        .font(AppColor.sans(12, .bold))
                        .foregroundStyle(AppColor.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColor.green)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("home.status.firstOffer.priceFrom".localized)
                        .font(AppColor.sans(11))
                        .foregroundStyle(AppColor.textSec)
                    
                    Text("home.status.multipleOffers.priceValue".localized)
                        .font(AppColor.sans(15, .bold))
                        .foregroundStyle(AppColor.textPrim)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 1, height: 32)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("home.status.firstOffer.availableMeds".localized)
                        .font(AppColor.sans(11))
                        .foregroundStyle(AppColor.textSec)
                    
                    Text("home.status.multipleOffers.medsCount".localized)
                        .font(AppColor.sans(14, .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.green.opacity(0.12), lineWidth: 1)
                    )
            )
            
            Text("home.status.multipleOffers.offersAvailableCount".localized)
                .font(AppColor.sans(12, .bold))
                .foregroundStyle(AppColor.green)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppColor.green.opacity(0.08))
                .clipShape(Capsule())
            
            Button {
            } label: {
                Text("home.status.multipleOffers.compareOffers".localized)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColor.green)
                    .cornerRadius(16)
            }
            
            Button {
            } label: {
                HStack(spacing: 4) {
                    Text("home.status.firstOffer.orderDetails".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.green)
                    
                    Image(systemName: languageManager.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            
            Text("home.status.multipleOffers.stopSearchDesc".localized)
                .font(AppColor.sans(11))
                .foregroundStyle(AppColor.textSec)
                .multilineTextAlignment(.center)
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppColor.green.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(AppColor.green.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct HomeExpiredStatusView: View {
    @Environment(LanguageManager.self) private var languageManager
    @Binding var selectedStatus: HomeSearchStatus
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    selectedStatus = .home
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(AppColor.textSec)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("home.status.expired.title".localized)
                        .font(AppColor.sans(16, .bold))
                        .foregroundStyle(AppColor.textPrim)
                        .multilineTextAlignment(.trailing)
                    
                    Text("home.status.expired.subtitle".localized)
                        .font(AppColor.sans(12))
                        .foregroundStyle(AppColor.textSec)
                        .multilineTextAlignment(.trailing)
                }
                
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.gray)
                }
            }
            
            Button {
            } label: {
                Text("home.status.expired.searchWider".localized)
                    .font(AppColor.sans(15, .bold))
                    .foregroundStyle(AppColor.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "#2E3A33"))
                    .cornerRadius(16)
            }
            
            Button {
            } label: {
                HStack(spacing: 4) {
                    Text("home.status.firstOffer.orderDetails".localized)
                        .font(AppColor.sans(13, .bold))
                        .foregroundStyle(AppColor.green)
                    
                    Image(systemName: languageManager.isRTL ? "chevron.left" : "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(AppColor.green)
                }
            }
            
            Button {
            } label: {
                Text("home.status.expired.cancelOrder".localized)
                    .font(AppColor.sans(13, .bold))
                    .foregroundStyle(AppColor.textSec)
            }
        }
        .environment(\.layoutDirection, languageManager.isRTL ? .rightToLeft : .leftToRight)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "#FAFAF9"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.12), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}
