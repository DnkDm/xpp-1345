@preconcurrency import SpriteKit

final class JetGameScene: SKScene, SKPhysicsContactDelegate {
    private static let groundSegmentWidth = GroundArt.segmentWidth
    private static let magnetReach: CGFloat = 250
    private static let magnetSpeed: CGFloat = 520

    weak var eventSink: JetGameSceneEvents?
    var isThrusting = false

    private let mode: GameMode
    private let config: ModeConfig
    private let chicken: SKSpriteNode
    /// 1 on iPhone. On iPad the whole world is drawn bigger so the play area
    /// keeps the same proportions as the phone layout.
    private var world: CGFloat = 1
    private var builtSize: CGSize = .zero
    private var isReady = false
    private var hasStarted = false
    private var hasFinished = false
    private var lastUpdateTime: TimeInterval = 0
    private var elapsed: TimeInterval = 0
    private var fuel: Double
    private var obstacleClock: TimeInterval = 0
    private var fuelClock: TimeInterval = 0
    private var coinClock: TimeInterval = 0
    private var powerUpClock: TimeInterval = 0
    private var invulnerableUntil: TimeInterval = 0
    private var magnetRemaining: TimeInterval = 0
    private var doubleRemaining: TimeInterval = 0
    private var shieldCharges = 0
    private var earnedCoins = 0
    private var collectedFuelCans = 0
    private var collectedPowerUps = 0
    private var passedBirds = 0
    private var passedDrones = 0
    private var lastPublishedTick = -1

    init(size: CGSize, mode: GameMode, skinAssetName: String) {
        self.mode = mode
        self.config = mode.config
        self.fuel = mode.config.initialFuel
        self.chicken = SKSpriteNode(imageNamed: skinAssetName)
        super.init(size: size)
        backgroundColor = UIColor(hex: config.skyHex)
        physicsWorld.contactDelegate = self
        buildWorld()
        isReady = true
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
    }

    /// `.resizeFill` hands the scene its real size only once it is presented,
    /// so the world is rebuilt for the device it actually runs on. Ignored
    /// until `init` is done, because `SKScene.init(size:)` fires this too.
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard
            DeviceLayout.isPad,
            isReady,
            !hasStarted,
            size != builtSize,
            size.width > 0,
            size.height > 0
        else { return }
        buildWorld()
    }

    private func buildWorld() {
        removeAllChildren()
        chicken.removeFromParent()
        builtSize = size
        world = DeviceLayout.worldScale(for: size)
        physicsWorld.gravity = CGVector(dx: 0, dy: -5.2 * world)
        buildBackground()
        setupChicken()
        buildTint()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        chicken.physicsBody?.isDynamic = true
        if config.usesFuel {
            spawnFuelCan()
        }
        eventSink?.sceneDidStart()
    }

    override func update(_ currentTime: TimeInterval) {
        guard hasStarted, !hasFinished else {
            lastUpdateTime = currentTime
            return
        }
        let rawDelta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        let delta = min(rawDelta, 1.0 / 20.0)
        lastUpdateTime = currentTime
        elapsed += delta

        moveScenery(by: delta)
        countPassedObstacles()
        updateThrust()
        updatePowerUps(by: delta)
        updateSpawners(by: delta)

        if config.usesFuel {
            fuel -= delta * config.fuelDrain
            if fuel <= 0 {
                fuel = 0
                return finish(outcome: .outOfFuel)
            }
        }

        if let limit = config.timeLimit, elapsed >= limit {
            return finish(outcome: .timeUp)
        }

        if chicken.position.y < 35 * world || chicken.position.y > size.height - 35 * world {
            AudioManager.shared.play(.hit)
            return finish(outcome: .crashed)
        }

        publishIfNeeded()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard !hasFinished else { return }
        let pair = [contact.bodyA, contact.bodyB]

        if let coinBody = pair.first(where: { $0.categoryBitMask == PhysicsCategory.coin }) {
            coinBody.node?.removeFromParent()
            earnedCoins += coinValue
            AudioManager.shared.play(.coin)
            publish()
        } else if let fuelBody = pair.first(where: { $0.categoryBitMask == PhysicsCategory.fuel }) {
            fuelBody.node?.removeFromParent()
            fuel += config.fuelPerCan
            collectedFuelCans += 1
            AudioManager.shared.play(.fuel)
            publish()
        } else if let powerBody = pair.first(where: { $0.categoryBitMask == PhysicsCategory.powerUp }) {
            collect(powerBody.node)
        } else if let obstacleBody = pair.first(where: { $0.categoryBitMask == PhysicsCategory.obstacle }) {
            handleObstacleHit(obstacleBody.node)
        }
    }

    // MARK: - Chicken

    private func setupChicken() {
        chicken.size = CGSize(width: 92 * world, height: 92 * world)
        chicken.position = CGPoint(x: size.width * 0.28, y: size.height * 0.56)
        chicken.zPosition = 10
        chicken.alpha = 1
        chicken.zRotation = 0
        chicken.physicsBody = SKPhysicsBody(circleOfRadius: 29 * world)
        chicken.physicsBody?.isDynamic = false
        chicken.physicsBody?.allowsRotation = false
        chicken.physicsBody?.linearDamping = 0.4
        chicken.physicsBody?.categoryBitMask = PhysicsCategory.chicken
        chicken.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle
            | PhysicsCategory.coin
            | PhysicsCategory.fuel
            | PhysicsCategory.powerUp
        chicken.physicsBody?.collisionBitMask = 0
        addChild(chicken)
    }

    private func updateThrust() {
        if isThrusting {
            chicken.physicsBody?.velocity.dy = min(
                (chicken.physicsBody?.velocity.dy ?? 0) + 32 * world,
                245 * world
            )
            chicken.zRotation = min(chicken.zRotation + 0.04, 0.22)
        } else {
            chicken.zRotation = max(chicken.zRotation - 0.025, -0.28)
        }
    }

    // MARK: - Scenery

    private func buildBackground() {
        let cloudWidth = 483 * world
        for index in 0..<cloudCount {
            let clouds = SKSpriteNode(imageNamed: "GameClouds")
            clouds.name = "movingClouds"
            clouds.size = CGSize(width: cloudWidth, height: 418 * world)
            clouds.position = CGPoint(x: CGFloat(index) * cloudWidth - 17 * world, y: 519 * world)
            clouds.zPosition = -8
            addChild(clouds)
        }

        for index in 0..<groundSegmentCount {
            addChild(makeGroundSegment(index: index))
        }
    }

    /// Enough tiles to cover the screen plus one spare scrolling in.
    private var groundSegmentCount: Int {
        max(3, Int(ceil(size.width / (Self.groundSegmentWidth * world))) + 2)
    }

    private var cloudCount: Int {
        max(2, Int(ceil(size.width / (483 * world))) + 1)
    }

    private func buildTint() {
        guard let tintHex = config.tintHex, config.tintAlpha > 0 else { return }
        let tint = SKSpriteNode(
            color: UIColor(hex: tintHex),
            size: CGSize(width: size.width * 1.4, height: size.height * 1.4)
        )
        tint.alpha = config.tintAlpha
        tint.zPosition = 15
        tint.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(tint)
    }

    private func makeGroundSegment(index: Int) -> SKNode {
        let segment = GroundArt.makeSegment(index: index, world: world)
        segment.name = "movingGround"
        segment.zPosition = -2
        return segment
    }

    private func moveScenery(by delta: TimeInterval) {
        let segmentWidth = Self.groundSegmentWidth * world
        let groundSpeed = CGFloat(delta) * config.scrollSpeed * world
        var groundSegments: [SKNode] = []
        enumerateChildNodes(withName: "movingGround") { node, _ in
            node.position.x -= groundSpeed
            groundSegments.append(node)
        }

        var rightmostX = groundSegments.map(\.position.x).max() ?? 0
        for segment in groundSegments
            .filter({ $0.position.x + segmentWidth <= 0 })
            .sorted(by: { $0.position.x < $1.position.x }) {
            segment.position.x = rightmostX + segmentWidth
            rightmostX = segment.position.x
        }

        let cloudWidth = 483 * world
        let cloudSpan = cloudWidth * CGFloat(cloudCount)
        let cloudSpeed = CGFloat(delta) * config.scrollSpeed * world * 0.23
        enumerateChildNodes(withName: "movingClouds") { node, _ in
            node.position.x -= cloudSpeed
            if node.position.x <= -cloudWidth {
                node.position.x += cloudSpan
            }
        }
    }

    // MARK: - Spawning

    private func updateSpawners(by delta: TimeInterval) {
        if config.obstaclesEnabled {
            obstacleClock += delta
            if obstacleClock >= config.obstacleInterval(at: elapsed) {
                obstacleClock = 0
                spawnObstacle()
            }
        }

        if config.usesFuel {
            fuelClock += delta
            if fuelClock >= config.fuelInterval {
                fuelClock = 0
                spawnFuelCan()
            }
        }

        coinClock += delta
        if coinClock >= config.coinInterval {
            coinClock = 0
            spawnCoinRun()
        }

        if !config.powerUps.isEmpty {
            powerUpClock += delta
            if powerUpClock >= config.powerUpInterval {
                powerUpClock = 0
                spawnPowerUp()
            }
        }
    }

    private func spawnObstacle() {
        if config.pairChance > 0, Double.random(in: 0...1) < config.pairChance {
            spawnObstaclePair()
        } else {
            spawnSingleObstacle()
        }
    }

    private func spawnSingleObstacle() {
        let isDrone = Bool.random()
        let node = makeObstacle(isDrone: isDrone)
        node.position = spawnPosition()
        addChild(node)

        if isDrone {
            let duration = max(0.48, 1.1 - elapsed * 0.004)
            let moveUp = SKAction.moveBy(
                x: 0,
                y: min(150, 90 + CGFloat(elapsed) * 0.45) * world,
                duration: duration
            )
            node.run(.repeatForever(.sequence([moveUp, moveUp.reversed()])))
        } else if Bool.random() {
            let glide = SKAction.moveBy(x: 0, y: 54 * world, duration: 1.35)
            glide.timingMode = .easeInEaseOut
            node.run(.repeatForever(.sequence([glide, glide.reversed()])))
        }

        moveAcrossScreen(node, duration: config.obstacleTravel(at: elapsed))
    }

    /// Two obstacles with a gap between them - the chicken has to thread it.
    private func spawnObstaclePair() {
        let gap: CGFloat = (config.pairChance > 0.3 ? 238 : 262) * world
        let lowest = 150 * world + gap / 2
        let highest = size.height - 170 * world - gap / 2
        guard lowest < highest else { return spawnSingleObstacle() }

        let center = CGFloat.random(in: lowest...highest)
        let travel = config.obstacleTravel(at: elapsed)

        for (index, y) in [center - gap / 2 - 46 * world, center + gap / 2 + 46 * world].enumerated() {
            let node = makeObstacle(isDrone: index == 1)
            node.position = CGPoint(x: size.width + 70 * world, y: y)
            addChild(node)
            moveAcrossScreen(node, duration: travel)
        }
    }

    private func makeObstacle(isDrone: Bool) -> SKSpriteNode {
        let node = SKSpriteNode(imageNamed: isDrone ? "DroneObstacle" : "BirdObstacle")
        node.name = "obstacle"
        node.userData = [
            "kind": isDrone ? "drone" : "bird",
            "counted": false
        ]
        node.size = CGSize(
            width: (isDrone ? 94 : 88) * world,
            height: (isDrone ? 64 : 82) * world
        )
        node.zPosition = 5
        if !isDrone {
            node.xScale = -1
        }
        node.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: node.size.width * 0.72,
                height: node.size.height * 0.52
            )
        )
        node.physicsBody?.isDynamic = false
        node.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        node.physicsBody?.contactTestBitMask = PhysicsCategory.chicken
        node.physicsBody?.collisionBitMask = 0
        return node
    }

    private func spawnCoinRun() {
        let count = config.coinRun > 1 ? Int.random(in: 1...config.coinRun) : 1
        let formation = count > 2 ? CoinFormation.allCases.randomElement() ?? .line : .line
        let offsets = formation.offsets(count: count)
        let origin = spawnPosition()

        // Keep the whole formation on screen instead of squashing coins on top
        // of each other at the edges.
        let lowest = 92 * world - (offsets.map(\.y).min() ?? 0)
        let highest = size.height - 100 * world - (offsets.map(\.y).max() ?? 0)
        let baseY = min(max(origin.y, lowest), max(lowest, highest))

        for offset in offsets {
            let coin = SKSpriteNode(imageNamed: "Coin")
            coin.name = "coin"
            coin.size = CGSize(width: 42 * world, height: 42 * world)
            coin.position = CGPoint(x: origin.x + offset.x, y: baseY + offset.y)
            coin.zPosition = 6
            coin.physicsBody = makeSensorBody(radius: 14 * world, category: PhysicsCategory.coin)
            addChild(coin)
            moveAcrossScreen(coin, duration: config.itemTravel)
        }
    }

    private func spawnFuelCan() {
        let can = SKSpriteNode(imageNamed: "Fuel")
        can.name = "fuelCan"
        can.size = CGSize(width: 54 * world, height: 54 * world)
        can.position = spawnPosition()
        can.zPosition = 6
        can.physicsBody = makeSensorBody(radius: 18 * world, category: PhysicsCategory.fuel)
        addChild(can)
        moveAcrossScreen(can, duration: config.itemTravel * 0.8)
    }

    private func spawnPowerUp() {
        guard let kind = config.powerUps.randomElement() else { return }
        let node = PowerUpNode.make(kind)
        node.setScale(world)
        node.position = spawnPosition()
        node.physicsBody = makeSensorBody(
            radius: PowerUpNode.radius * world,
            category: PhysicsCategory.powerUp
        )
        addChild(node)
        moveAcrossScreen(node, duration: config.itemTravel)
    }

    private func makeSensorBody(radius: CGFloat, category: UInt32) -> SKPhysicsBody {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.categoryBitMask = category
        body.contactTestBitMask = PhysicsCategory.chicken
        body.collisionBitMask = 0
        return body
    }

    private func spawnPosition() -> CGPoint {
        CGPoint(
            x: size.width + 70 * world,
            y: CGFloat.random(in: (130 * world)...(size.height - 150 * world))
        )
    }

    /// A wider iPad screen would otherwise sweep past at the same pace, so
    /// crossing takes proportionally longer and the flow stays identical.
    private var travelFactor: TimeInterval {
        TimeInterval(size.width / world / DeviceLayout.designSize.width)
    }

    private func moveAcrossScreen(_ node: SKNode, duration: TimeInterval) {
        node.run(.sequence([
            .moveTo(x: -100 * world, duration: duration * travelFactor),
            .removeFromParent()
        ]))
    }

    private func countPassedObstacles() {
        enumerateChildNodes(withName: "obstacle") { [weak self] node, _ in
            guard
                let self,
                node.position.x + node.frame.width / 2 < self.chicken.position.x,
                node.userData?["counted"] as? Bool != true
            else { return }

            node.userData?["counted"] = true
            switch node.userData?["kind"] as? String {
            case "bird":
                self.passedBirds += 1
            case "drone":
                self.passedDrones += 1
            default:
                break
            }
        }
    }

    // MARK: - Power-ups

    private var coinValue: Int {
        config.coinValue * (doubleRemaining > 0 ? 2 : 1)
    }

    private func collect(_ node: SKNode?) {
        guard
            let node,
            let raw = node.userData?["kind"] as? String,
            let kind = PowerUp(rawValue: raw)
        else { return }

        node.removeFromParent()
        collectedPowerUps += 1
        AudioManager.shared.play(.fuel)

        switch kind {
        case .shield:
            shieldCharges = 1
            setShieldVisible(true)
        case .magnet:
            magnetRemaining = kind.duration
        case .doubleCoins:
            doubleRemaining = kind.duration
        }
        publish()
    }

    private func updatePowerUps(by delta: TimeInterval) {
        if doubleRemaining > 0 {
            doubleRemaining = max(0, doubleRemaining - delta)
        }

        guard magnetRemaining > 0 else { return }
        magnetRemaining = max(0, magnetRemaining - delta)
        if magnetRemaining == 0 {
            releaseAttractedCoins()
        } else {
            attractCoins(by: delta)
        }
    }

    private func attractCoins(by delta: TimeInterval) {
        let target = chicken.position
        let step = CGFloat(delta) * Self.magnetSpeed * world
        let reach = Self.magnetReach * world

        enumerateChildNodes(withName: "coin") { node, _ in
            let dx = target.x - node.position.x
            let dy = target.y - node.position.y
            let distance = sqrt(dx * dx + dy * dy)
            guard distance < reach else { return }

            if node.userData?["attracted"] as? Bool != true {
                node.removeAllActions()
                node.userData = ["attracted": true]
            }
            guard distance > 1 else { return }
            node.position.x += dx / distance * step
            node.position.y += dy / distance * step
        }
    }

    /// Coins still homing in when the magnet runs out resume their flight,
    /// otherwise they would hang in the air.
    private func releaseAttractedCoins() {
        enumerateChildNodes(withName: "coin") { [weak self] node, _ in
            guard
                let self,
                node.userData?["attracted"] as? Bool == true
            else { return }
            node.userData?["attracted"] = false
            let remaining = max(0.6, (node.position.x + 100 * self.world) / (90 * self.world))
            self.moveAcrossScreen(node, duration: remaining)
        }
    }

    private func handleObstacleHit(_ node: SKNode?) {
        guard elapsed >= invulnerableUntil else { return }

        if shieldCharges > 0 {
            shieldCharges = 0
            invulnerableUntil = elapsed + 0.8
            setShieldVisible(false)
            node?.removeFromParent()
            AudioManager.shared.play(.hit)
            chicken.run(.repeat(
                .sequence([
                    .fadeAlpha(to: 0.35, duration: 0.13),
                    .fadeAlpha(to: 1, duration: 0.13)
                ]),
                count: 3
            ))
            publish()
        } else {
            AudioManager.shared.play(.hit)
            finish(outcome: .crashed)
        }
    }

    private func setShieldVisible(_ visible: Bool) {
        let name = "shieldRing"
        guard visible else {
            chicken.childNode(withName: name)?.removeFromParent()
            return
        }
        guard chicken.childNode(withName: name) == nil else { return }

        let ring = SKShapeNode(circleOfRadius: 47 * world)
        ring.name = name
        ring.strokeColor = UIColor(hex: "FFF0BA")
        ring.lineWidth = 5 * world
        ring.fillColor = UIColor(hex: "85CEE5").withAlphaComponent(0.22)
        ring.zPosition = -1
        ring.run(.repeatForever(.sequence([
            .scale(to: 1.07, duration: 0.6),
            .scale(to: 0.97, duration: 0.6)
        ])))
        chicken.addChild(ring)
    }

    // MARK: - Reporting

    private var activePowerUps: [ActivePowerUp] {
        var active: [ActivePowerUp] = []
        if shieldCharges > 0 {
            active.append(ActivePowerUp(kind: .shield, remaining: 0))
        }
        if magnetRemaining > 0 {
            active.append(ActivePowerUp(kind: .magnet, remaining: magnetRemaining))
        }
        if doubleRemaining > 0 {
            active.append(ActivePowerUp(kind: .doubleCoins, remaining: doubleRemaining))
        }
        return active
    }

    private var currentScore: Int {
        switch config.scoring {
        case .seconds: Int(elapsed)
        case .coins: earnedCoins
        }
    }

    private func publishIfNeeded() {
        let tick = Int(elapsed * 10)
        guard tick != lastPublishedTick else { return }
        lastPublishedTick = tick
        publish()
    }

    private func publish() {
        eventSink?.sceneDidUpdate(
            GameRunSnapshot(
                score: currentScore,
                coins: earnedCoins,
                fuel: max(0, fuel),
                timeRemaining: config.timeLimit.map { max(0, $0 - elapsed) },
                powerUps: activePowerUps
            )
        )
    }

    private func finish(outcome: GameOutcome) {
        guard !hasFinished else { return }
        hasFinished = true
        isThrusting = false
        chicken.physicsBody?.velocity = .zero
        speed = 0
        eventSink?.sceneDidFinish(
            stats: GameRunStats(
                seconds: Int(elapsed),
                score: currentScore,
                coins: earnedCoins,
                fuelCans: collectedFuelCans,
                birdStreak: passedBirds,
                droneStreak: passedDrones,
                powerUps: collectedPowerUps,
                outcome: outcome
            )
        )
    }
}

private enum PhysicsCategory {
    static let chicken: UInt32 = 1 << 0
    static let obstacle: UInt32 = 1 << 1
    static let coin: UInt32 = 1 << 2
    static let fuel: UInt32 = 1 << 3
    static let powerUp: UInt32 = 1 << 4
}
