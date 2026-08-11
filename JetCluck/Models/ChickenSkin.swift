struct ChickenSkin: Identifiable {
    let id: String
    let name: String
    let price: Int
    let assetName: String

    static let all: [ChickenSkin] = [
        .init(id: "classic", name: "Classic", price: 0, assetName: "Chicken"),
        .init(id: "black", name: "Black", price: 10, assetName: "SkinBlack"),
        .init(id: "gold", name: "Golden", price: 10, assetName: "SkinGold"),
        .init(id: "pink", name: "Pink", price: 10, assetName: "SkinPink"),
        .init(id: "red", name: "Red", price: 10, assetName: "SkinRed"),
        .init(id: "blue", name: "Blue", price: 10, assetName: "SkinBlue"),
        .init(id: "green", name: "Green", price: 10, assetName: "SkinGreen"),
        .init(id: "orange", name: "Orange", price: 10, assetName: "SkinOrange"),
        .init(id: "purple", name: "Purple", price: 10, assetName: "SkinPurple"),
        .init(id: "yellow", name: "Yellow", price: 10, assetName: "SkinYellow"),
        .init(id: "silver", name: "Silver", price: 10, assetName: "SkinSilver"),
        .init(id: "bronze", name: "Bronze", price: 10, assetName: "SkinBronze"),
        .init(id: "rainbow", name: "Rainbow", price: 10, assetName: "SkinRainbow"),
        .init(id: "tiger", name: "Tiger", price: 20, assetName: "SkinTiger"),
        .init(id: "zebra", name: "Zebra", price: 20, assetName: "SkinZebra"),
        .init(id: "cow", name: "Cow", price: 20, assetName: "SkinCow"),
        .init(id: "pirate", name: "Pirate", price: 20, assetName: "SkinPirate"),
        .init(id: "ninja", name: "Ninja", price: 20, assetName: "SkinNinja"),
        .init(id: "robot", name: "Robot", price: 20, assetName: "SkinRobot"),
        .init(id: "zombie", name: "Zombie", price: 20, assetName: "SkinZombie"),
        .init(id: "skeleton", name: "Skeleton", price: 20, assetName: "SkinSkeleton"),
        .init(id: "dragon", name: "Dragon", price: 20, assetName: "SkinDragon"),
        .init(id: "unicorn", name: "Unicorn", price: 20, assetName: "SkinUnicorn"),
        .init(id: "penguin", name: "Penguin", price: 20, assetName: "SkinPenguin"),
        .init(id: "clown", name: "Clown", price: 20, assetName: "SkinClown")
    ]
}
