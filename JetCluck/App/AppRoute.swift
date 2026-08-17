enum AppRoute: Equatable {
    case splash
    case story
    case menu
    case gameHub
    case modeSelection
    case quests
    case shop
    case game(GameMode)
    case skyHopModes
    case skyHop(HopMode)
}
