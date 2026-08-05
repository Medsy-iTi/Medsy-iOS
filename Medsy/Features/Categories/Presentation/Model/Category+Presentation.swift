import SwiftUI

extension Category {
    var artworkName: String? {
        switch id {
        case 1: return "CategoryMentalHealth"
        case 2: return "CategoryPainRelief"
        case 3: return "CategoryColdCough"
        case 4: return "CategoryBrainNerves"
        case 5: return "CategorySkinCare"
        case 6: return "CategoryHeartBloodPressure"
        case 7: return "CategoryAntivirals"
        case 8: return "CategoryCancerImmunity"
        case 9: return "CategoryAllergy"
        case 10: return "CategoryStomachDigestion"
        case 11: return "CategoryAntiparasitics"
        case 12: return "CategoryVitaminsSupplements"
        case 13: return "CategoryAntibiotics"
        case 14: return "CategoryDiabetes"
        case 15: return "CategoryUrinaryKidney"
        case 16: return "CategoryWomensHealth"
        case 17: return "CategoryMensHealth"
        case 18: return "CategoryGout"
        case 19: return "CategoryCholesterol"
        case 20: return "CategoryLiverGallbladder"
        case 21: return "CategoryAntifungals"
        case 22: return "CategoryAsthmaBreathing"
        case 23: return "CategoryHemorrhoidsVeins"
        case 24: return "CategoryEyeCare"
        default: return nil
        }
    }

    var bgColor: Color {
        switch id % 6 {
        case 0: return Color(hex: "#E8F8F1")
        case 1: return Color(hex: "#EEF3FF")
        case 2: return Color(hex: "#FFF2DE")
        case 3: return Color(hex: "#FCEAF4")
        case 4: return Color(hex: "#F2EAFE")
        default: return Color(hex: "#EAF8FA")
        }
    }

    var iconName: String {
        artworkName == nil ? "pills.fill" : "cross.case.fill"
    }

    var iconColor: Color {
        AppColor.green
    }
}
