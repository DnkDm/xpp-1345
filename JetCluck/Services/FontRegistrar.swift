import CoreText
import Foundation

enum FontRegistrar {
    static func registerFredokaOne() {
        let urls = [
            Bundle.main.url(forResource: "FredokaOne-Regular", withExtension: "ttf"),
            Bundle.main.url(
                forResource: "FredokaOne-Regular",
                withExtension: "ttf",
                subdirectory: "Resources/Fonts"
            )
        ]

        guard let url = urls.compactMap({ $0 }).first else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }
}
