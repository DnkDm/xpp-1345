import Foundation

enum HopMode: String, CaseIterable, Codable, Equatable, Identifiable {
    case classic
    case cruise
    case pure
    case storm

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Sky Hop"
        case .cruise: "Cloud Cruise"
        case .pure: "Pure Climb"
        case .storm: "Storm Run"
        }
    }

    var tagline: String {
        switch self {
        case .classic: "The full climb - clouds, jet cans and traffic."
        case .cruise: "Slow and gentle. Wide clouds, nothing in the way."
        case .pure: "No jet cans up here. Every metre is bounced, coins pay double."
        case .storm: "Quick, crowded and dark. Half the clouds break."
        }
    }

    var hint: String {
        switch self {
        case .classic: "DRAG TO STEER\nBOUNCE UP THE CLOUDS"
        case .cruise: "DRAG TO STEER\nTAKE YOUR TIME"
        case .pure: "DRAG TO STEER\nNO JETS UP HERE"
        case .storm: "DRAG TO STEER\nDASHED CLOUDS BREAK"
        }
    }

    var unlock: UnlockRule {
        switch self {
        case .classic, .cruise: .always
        case .pure: .hopHeight(40)
        case .storm: .hopHeight(80)
        }
    }

    /// Each mode keeps the same bounce height and only changes its pace, its
    /// weather and what shares the sky.
    var config: HopConfig {
        switch self {
        case .classic:
            HopConfig()
        case .cruise:
            HopConfig(
                gravity: -1700,
                bounceSpeed: 835,
                cloudWidthBonus: 16,
                gapScale: 0.88,
                driftingScale: 0.5,
                stormScale: 0,
                hazardsEnabled: false,
                duskAt: 200,
                nightAt: 460
            )
        case .pure:
            HopConfig(
                stormScale: 0.8,
                hazardsFrom: 70,
                hazardSpacingScale: 1.25,
                jetCansEnabled: false,
                coinValue: 2
            )
        case .storm:
            HopConfig(
                gravity: -2650,
                bounceSpeed: 1040,
                gapScale: 0.96,
                driftingScale: 1.35,
                stormScale: 1.6,
                hazardsFrom: 15,
                hazardSpacingScale: 0.65,
                coinValue: 3,
                duskAt: 70,
                nightAt: 190
            )
        }
    }
}
