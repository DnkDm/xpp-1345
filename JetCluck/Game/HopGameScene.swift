@preconcurrency import SpriteKit

/// Sky Hop - the chicken bounces her way up an endless stack of clouds.
///
/// The whole world is scrolled down by hand every frame, so nothing that moves
/// may use an `SKAction.move`: the action and the scroll would both write
/// `position` and fight over it. Fades and scales are safe, and are what the
/// small effects are built from.
final class HopGameScene: SKScene, SKPhysicsContactDelegate {
    private static let daySky = UIColor(hex: AppPalette.Hex.daySky)
    private static let duskSky = UIColor(hex: AppPalette.Hex.duskSky)
    private static let nightSky = UIColor(hex: AppPalette.Hex.nightSky)

    weak var eventSink: HopGameSceneEvents?

    private let mode: HopMode
    private let config: HopConfig
    private let chicken: SKSpriteNode
    /// 1 on iPhone. On iPad the world is drawn bigger, so the climb is exactly
    /// as hard - the player just sees it larger.
    private var world: CGFloat = 1
    private var builtSize: CGSize = .zero
    private var isReady = false
    private var hasStarted = false
    private var hasFinished = false

    private var lastUpdateTime: TimeInterval = 0
    private var publishClock: TimeInterval = 0
    private var verticalSpeed: CGFloat = 0
    /// Where the chicken's feet were last frame, so a fast fall can never slip
    /// between two frames and miss a cloud.
    private var previousFeetY: CGFloat = 0
    private var steerBacklog: CGFloat = 0
    private var climb: CGFloat = 0
    private var nextCloudY: CGFloat = 0
    private var lastCloudX: CGFloat = 0
    private var firstCloudY: CGFloat = 0
    private var cloudsUntilCan = 0
    private var lastCloudWasStorm = false
    private var nextHazardClimb: CGFloat = 0
    private var boostRemaining: TimeInterval = 0
    private var earnedCoins = 0
    private var bouncedClouds = 0
    private var collectedCans = 0
    private var lastSkyMetres = -1

    init(size: CGSize, mode: HopMode, skinAssetName: String) {
        self.mode = mode
        self.config = mode.config
        chicken = SKSpriteNode(imageNamed: skinAssetName)
        super.init(size: size)
        backgroundColor = Self.daySky
        physicsWorld.gravity = .zero
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
    /// so the world is rebuilt for the device it actually runs on.
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

    // MARK: - Building

    private func buildWorld() {
        removeAllChildren()
        chicken.removeFromParent()
        builtSize = size
        world = DeviceLayout.worldScale(for: size)
        resetRun()
        buildSkyDecor()
        buildGround()
        buildStartingClouds()
        setupChicken()
    }

    private func resetRun() {
        backgroundColor = Self.daySky
        verticalSpeed = 0
        steerBacklog = 0
        climb = 0
        boostRemaining = 0
        earnedCoins = 0
        bouncedClouds = 0
        collectedCans = 0
        nextHazardClimb = 0
        lastSkyMetres = -1
        lastCloudWasStorm = false
        cloudsUntilCan = HopTuning.cansEvery
    }

    /// Distance the parallax layer covers before it starts over.
    private var parallaxSpan: CGFloat {
        size.height + 420 * world
    }

    private func buildSkyDecor() {
        for index in 0..<3 {
            let clouds = SKSpriteNode(imageNamed: "GameClouds")
            clouds.name = "bgCloud"
            clouds.size = CGSize(width: 483 * world, height: 418 * world)
            clouds.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat(index) * parallaxSpan / 3
            )
            clouds.zPosition = -8
            clouds.alpha = 0.9
            addChild(clouds)
        }

        for _ in 0..<26 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.4...2.8) * world)
            star.name = "star"
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = 0
            star.zPosition = -9
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...parallaxSpan)
            )
            addChild(star)
        }
    }

    /// The farm the run starts from. It scrolls away for good after the first
    /// few clouds - there is no way back down.
    private func buildGround() {
        let count = max(2, Int(ceil(size.width / (GroundArt.segmentWidth * world))) + 1)
        for index in 0..<count {
            let segment = GroundArt.makeSegment(index: index, world: world)
            segment.name = "ground"
            segment.zPosition = -2
            addChild(segment)
        }
    }

    private func buildStartingClouds() {
        firstCloudY = 205 * world
        nextCloudY = firstCloudY
        lastCloudX = size.width / 2
        spawnCloud(kind: .solid, x: size.width / 2, withPickup: false)
        fillClouds()
    }

    private func setupChicken() {
        chicken.setScale(1)
        chicken.size = CGSize(width: 92 * world, height: 92 * world)
        chicken.position = CGPoint(
            x: size.width / 2,
            y: firstCloudY + HopTuning.cloudHeight * 0.30 * world
                + HopTuning.footOffset * world
        )
        chicken.zPosition = 10
        chicken.zRotation = 0
        chicken.alpha = 1
        chicken.physicsBody = SKPhysicsBody(circleOfRadius: 28 * world)
        chicken.physicsBody?.isDynamic = false
        chicken.physicsBody?.affectedByGravity = false
        chicken.physicsBody?.allowsRotation = false
        chicken.physicsBody?.linearDamping = 0
        chicken.physicsBody?.categoryBitMask = HopCategory.chicken
        chicken.physicsBody?.contactTestBitMask = HopCategory.coin
            | HopCategory.can
            | HopCategory.hazard
        chicken.physicsBody?.collisionBitMask = 0
        addChild(chicken)
        previousFeetY = chicken.position.y - HopTuning.footOffset * world
    }

    // MARK: - Run

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        chicken.physicsBody?.isDynamic = true
        Haptics.prepare()
        bounce()
        eventSink?.hopSceneDidStart()
    }

    /// Horizontal steering, in screen points of finger travel.
    func steer(by dx: CGFloat) {
        guard !hasFinished else { return }
        let backlog = HopTuning.steerBacklog * world
        steerBacklog = min(
            max(steerBacklog + dx * HopTuning.steerFactor, -backlog),
            backlog
        )
    }

    override func update(_ currentTime: TimeInterval) {
        guard hasStarted, !hasFinished else {
            lastUpdateTime = currentTime
            return
        }
        let rawDelta = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        let delta = min(rawDelta, 1.0 / 20.0)
        lastUpdateTime = currentTime

        checkLanding()
        updateBoost(by: delta)
        applyGravity(by: delta)
        steerChicken(by: delta)
        driftClouds(by: delta)
        moveHazards(by: delta)
        scrollWorld()
        fillClouds()
        spawnHazardIfDue()
        recycleSkyDecor()
        removeFallenNodes()
        updateSky()

        if chicken.position.y < -HopTuning.despawnMargin * world {
            AudioManager.shared.play(.hit)
            return finish(outcome: .fell)
        }

        publish(after: delta)
    }

    // MARK: - Chicken

    /// Landing is resolved by sweeping the feet between the last frame and this
    /// one, so it holds at any fall speed - the clouds carry no physics body.
    private func checkLanding() {
        var feet = chicken.position.y - HopTuning.footOffset * world

        if let cloud = landingCloud(feet: feet) {
            chicken.position.y = cloud.position.y + cloud.surface
                + HopTuning.footOffset * world
            feet = chicken.position.y - HopTuning.footOffset * world
            bouncedClouds += 1
            bounce()
            if cloud.kind == .storm {
                cloud.breakApart()
            }
        }

        previousFeetY = feet
    }

    private func landingCloud(feet: CGFloat) -> CloudNode? {
        guard verticalSpeed <= 0, boostRemaining <= 0 else { return nil }

        var landing: CloudNode?
        for case let cloud as CloudNode in children where !cloud.isBroken {
            let surface = cloud.position.y + cloud.surface
            guard
                previousFeetY >= surface - 2 * world,
                feet <= surface,
                abs(chicken.position.x - cloud.position.x) <= cloud.cloudWidth / 2
            else { continue }

            if cloud.position.y > (landing?.position.y ?? -.greatestFiniteMagnitude) {
                landing = cloud
            }
        }
        return landing
    }

    private func bounce() {
        verticalSpeed = config.bounceSpeed * world
        chicken.physicsBody?.velocity = CGVector(dx: 0, dy: verticalSpeed)
        chicken.removeAction(forKey: "squash")
        chicken.run(
            .sequence([
                .scaleX(to: 1.16, y: 0.84, duration: 0.07),
                .scaleX(to: 1, y: 1, duration: 0.13)
            ]),
            withKey: "squash"
        )
        Haptics.bounce()
    }

    private func updateBoost(by delta: TimeInterval) {
        guard boostRemaining > 0 else { return }
        boostRemaining = max(0, boostRemaining - delta)
        if boostRemaining == 0 {
            setFlameVisible(false)
        }
    }

    private func applyGravity(by delta: TimeInterval) {
        if boostRemaining > 0 {
            verticalSpeed = HopTuning.boostSpeed * world
        } else {
            verticalSpeed = max(
                verticalSpeed + config.gravity * world * CGFloat(delta),
                HopTuning.fallSpeedLimit * world
            )
        }
        chicken.physicsBody?.velocity = CGVector(dx: 0, dy: verticalSpeed)
    }

    private func steerChicken(by delta: TimeInterval) {
        let step = min(
            max(steerBacklog, -HopTuning.steerSpeedLimit * world * CGFloat(delta)),
            HopTuning.steerSpeedLimit * world * CGFloat(delta)
        )
        steerBacklog -= step
        chicken.position.x += step

        // Flying out one side brings her back in on the other.
        let edge = 26 * world
        if chicken.position.x < -edge {
            chicken.position.x = size.width + edge
        } else if chicken.position.x > size.width + edge {
            chicken.position.x = -edge
        }

        let lean = -step / max(HopTuning.steerSpeedLimit * world * CGFloat(delta), 1) * 0.2
        let target = lean + (boostRemaining > 0 ? 0.16 : 0)
        chicken.zRotation += (target - chicken.zRotation) * 0.3
    }

    /// The jetpack burn, drawn under the chicken while a can is running.
    private func setFlameVisible(_ visible: Bool) {
        let name = "jetFlame"
        guard visible else {
            chicken.childNode(withName: name)?.removeFromParent()
            return
        }
        guard chicken.childNode(withName: name) == nil else { return }

        let flame = SKNode()
        flame.name = name
        flame.position = CGPoint(x: -22 * world, y: -26 * world)
        flame.zPosition = -1

        let outer = SKShapeNode(path: Self.flamePath(length: 34 * world))
        outer.fillColor = UIColor(hex: AppPalette.Hex.flame)
        outer.strokeColor = UIColor(hex: AppPalette.Hex.outline)
        outer.lineWidth = 2.5 * world
        outer.lineJoin = .round

        let core = SKShapeNode(path: Self.flamePath(length: 19 * world))
        core.fillColor = UIColor(hex: AppPalette.Hex.flameCore)
        core.strokeColor = .clear
        outer.addChild(core)

        flame.addChild(outer)
        flame.run(.repeatForever(.sequence([
            .scaleY(to: 0.78, duration: 0.09),
            .scaleY(to: 1.12, duration: 0.09)
        ])))
        chicken.addChild(flame)
    }

    private static func flamePath(length: CGFloat) -> CGPath {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addQuadCurve(
            to: CGPoint(x: 0, y: -length),
            control: CGPoint(x: length * 0.55, y: -length * 0.42)
        )
        path.addQuadCurve(
            to: .zero,
            control: CGPoint(x: -length * 0.55, y: -length * 0.42)
        )
        path.closeSubpath()
        return path
    }

    // MARK: - World

    private var currentMetres: Int {
        Int(climb / (HopTuning.metre * world))
    }

    private func scrollWorld() {
        let line = size.height * HopTuning.cameraLine
        guard chicken.position.y > line else { return }

        let delta = chicken.position.y - line
        chicken.position.y = line
        climb += delta
        previousFeetY -= delta
        nextCloudY -= delta

        for node in children where node !== chicken {
            switch node.name {
            case "bgCloud":
                node.position.y -= delta * 0.24
            case "star":
                node.position.y -= delta * 0.08
            default:
                node.position.y -= delta
            }
        }
    }

    private func recycleSkyDecor() {
        let span = parallaxSpan
        for node in children {
            guard
                node.name == "bgCloud" || node.name == "star",
                node.position.y < -140 * world
            else { continue }
            node.position.y += span
            node.position.x = CGFloat.random(in: 0...size.width)
        }
    }

    private func removeFallenNodes() {
        let floor = -HopTuning.despawnMargin * world - size.height * 0.15
        for node in children where node !== chicken {
            switch node.name {
            case "bgCloud", "star":
                continue
            default:
                if node.position.y < floor {
                    node.removeFromParent()
                }
            }
        }
    }

    private func updateSky() {
        let metres = currentMetres
        guard metres != lastSkyMetres else { return }
        lastSkyMetres = metres

        let dusk = min(CGFloat(metres) / config.duskAt, 1)
        let night = min(
            max((CGFloat(metres) - config.duskAt)
                / (config.nightAt - config.duskAt), 0),
            1
        )
        backgroundColor = Self.daySky
            .blended(with: Self.duskSky, amount: dusk)
            .blended(with: Self.nightSky, amount: night)

        for node in children {
            switch node.name {
            case "star":
                node.alpha = max(dusk, night)
            case "bgCloud":
                node.alpha = 0.9 - 0.55 * dusk
            default:
                continue
            }
        }
    }

    // MARK: - Spawning

    private func fillClouds() {
        while nextCloudY < size.height + HopTuning.spawnMargin * world {
            spawnCloud()
        }
    }

    private func spawnCloud(
        kind forcedKind: CloudNode.Kind? = nil,
        x forcedX: CGFloat? = nil,
        withPickup: Bool = true
    ) {
        let metres = currentMetres
        let width = config.cloudWidth(at: metres) * world
        let kind = forcedKind ?? randomKind(at: metres)
        let cloud = CloudNode(
            kind: kind,
            width: width,
            height: HopTuning.cloudHeight * world,
            lineWidth: 3 * world
        )
        cloud.position = CGPoint(x: forcedX ?? nextCloudX(width: width), y: nextCloudY)
        cloud.zPosition = 4
        if kind == .drifting {
            cloud.drift = HopTuning.driftSpeed(at: metres) * world
                * (Bool.random() ? 1 : -1)
        }
        addChild(cloud)

        lastCloudX = cloud.position.x
        lastCloudWasStorm = kind == .storm
        nextCloudY += config.gap(at: metres) * world
        if withPickup {
            addPickup(above: cloud)
        }
    }

    /// Puts the next cloud far enough sideways that the player has to steer to
    /// it, and near enough that one bounce can get there. Whichever side has
    /// room is used; if both do, it is a coin toss.
    private func nextCloudX(width: CGFloat) -> CGFloat {
        let margin = width / 2 + 12 * world
        let near = HopTuning.minShift * size.width
        let far = HopTuning.maxShift * size.width

        var sides: [ClosedRange<CGFloat>] = []
        if lastCloudX - near >= margin {
            sides.append(max(margin, lastCloudX - far)...(lastCloudX - near))
        }
        if lastCloudX + near <= size.width - margin {
            sides.append((lastCloudX + near)...min(size.width - margin, lastCloudX + far))
        }

        guard let side = sides.randomElement() else {
            return margin < size.width - margin
                ? CGFloat.random(in: margin...(size.width - margin))
                : size.width / 2
        }
        return CGFloat.random(in: side)
    }

    private func randomKind(at metres: Int) -> CloudNode.Kind {
        // Never two storm clouds in a row: a run should end on a mistake, not
        // on a stack of clouds that all fall apart.
        if !lastCloudWasStorm, Double.random(in: 0...1) < config.stormChance(at: metres) {
            return .storm
        }
        if Double.random(in: 0...1) < config.driftingChance(at: metres) {
            return .drifting
        }
        return .solid
    }

    private func addPickup(above cloud: CloudNode) {
        cloudsUntilCan -= 1
        if config.jetCansEnabled, cloudsUntilCan <= 0 {
            cloudsUntilCan = HopTuning.cansEvery + Int.random(in: -3...3)
            return spawnCan(above: cloud)
        }

        guard Double.random(in: 0...1) < HopTuning.coinChance else { return }
        let offsets: [CGPoint] = Double.random(in: 0...1) < HopTuning.coinRunChance
            ? [CGPoint(x: -44, y: 0), CGPoint(x: 0, y: 14), CGPoint(x: 44, y: 0)]
            : [.zero]

        for offset in offsets {
            let edge = 26 * world
            spawnCoin(
                at: CGPoint(
                    x: min(max(cloud.position.x + offset.x * world, edge), size.width - edge),
                    y: cloud.position.y + (52 + offset.y) * world
                )
            )
        }
    }

    private func spawnCoin(at position: CGPoint) {
        let coin = SKSpriteNode(imageNamed: "Coin")
        coin.name = "coin"
        coin.size = CGSize(width: 42 * world, height: 42 * world)
        coin.position = position
        coin.zPosition = 5
        coin.physicsBody = makeSensorBody(radius: 17 * world, category: HopCategory.coin)
        addChild(coin)
    }

    private func spawnCan(above cloud: CloudNode) {
        let can = SKSpriteNode(imageNamed: "Fuel")
        can.name = "can"
        can.size = CGSize(width: 56 * world, height: 56 * world)
        can.position = CGPoint(x: cloud.position.x, y: cloud.position.y + 58 * world)
        can.zPosition = 5
        can.physicsBody = makeSensorBody(radius: 22 * world, category: HopCategory.can)
        addChild(can)
    }

    private func spawnHazardIfDue() {
        let metres = currentMetres
        guard
            config.hazardsEnabled,
            metres >= config.hazardsFrom,
            climb >= nextHazardClimb
        else { return }
        nextHazardClimb = climb + config.hazardSpacing(at: metres) * world

        let speed = HopTuning.hazardSpeed(at: metres) * world
        let travel = Bool.random() ? speed : -speed
        let hazard = HazardNode(
            kind: HazardNode.Kind.allCases.randomElement() ?? .drone,
            travel: travel,
            world: world
        )
        hazard.position = CGPoint(
            x: travel > 0 ? -hazard.size.width : size.width + hazard.size.width,
            y: size.height + CGFloat.random(in: 60...170) * world
        )
        addChild(hazard)
    }

    private func makeSensorBody(radius: CGFloat, category: UInt32) -> SKPhysicsBody {
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.categoryBitMask = category
        body.contactTestBitMask = HopCategory.chicken
        body.collisionBitMask = 0
        return body
    }

    // MARK: - Moving pieces

    private func driftClouds(by delta: TimeInterval) {
        for case let cloud as CloudNode in children where cloud.drift != 0 {
            cloud.position.x += cloud.drift * CGFloat(delta)
            let margin = cloud.cloudWidth / 2 + 10 * world
            guard cloud.position.x < margin || cloud.position.x > size.width - margin
            else { continue }
            cloud.drift = -cloud.drift
            cloud.position.x = min(max(cloud.position.x, margin), size.width - margin)
        }
    }

    private func moveHazards(by delta: TimeInterval) {
        for case let hazard as HazardNode in children {
            hazard.position.x += hazard.travel * CGFloat(delta)
            let margin = abs(hazard.size.width) / 2

            switch hazard.kind {
            case .drone:
                // Drones settle into a patrol across the screen.
                guard hazard.position.x < margin || hazard.position.x > size.width - margin
                else { continue }
                hazard.turnAround()
                hazard.position.x = min(
                    max(hazard.position.x, margin),
                    size.width - margin
                )
            case .bird:
                if hazard.position.x < -margin * 2 || hazard.position.x > size.width + margin * 2 {
                    hazard.removeFromParent()
                }
            }
        }
    }

    // MARK: - Pickups

    func didBegin(_ contact: SKPhysicsContact) {
        guard !hasFinished else { return }
        let pair = [contact.bodyA, contact.bodyB]

        if let coin = pair.first(where: { $0.categoryBitMask == HopCategory.coin }) {
            collectCoin(coin.node)
        } else if let can = pair.first(where: { $0.categoryBitMask == HopCategory.can }) {
            collectCan(can.node)
        } else if let hazard = pair.first(where: { $0.categoryBitMask == HopCategory.hazard }) {
            hit(hazard.node as? HazardNode)
        }
    }

    private func collectCoin(_ node: SKNode?) {
        guard let node, node.physicsBody != nil else { return }
        node.physicsBody = nil
        earnedCoins += config.coinValue
        AudioManager.shared.play(.coin)
        pop(node)
        publish()
    }

    private func collectCan(_ node: SKNode?) {
        guard let node, node.physicsBody != nil else { return }
        node.physicsBody = nil
        collectedCans += 1
        boostRemaining = HopTuning.boostDuration
        verticalSpeed = HopTuning.boostSpeed * world
        setFlameVisible(true)
        AudioManager.shared.play(.fuel)
        Haptics.punch()
        pop(node)
        publish()
    }

    private func hit(_ hazard: HazardNode?) {
        guard let hazard else { return }
        guard boostRemaining <= 0 else {
            // The jet burn goes straight through anything in the way.
            return hazard.burstApart()
        }
        AudioManager.shared.play(.hit)
        Haptics.punch()
        finish(outcome: .crashed)
    }

    private func pop(_ node: SKNode) {
        node.run(.sequence([
            .group([
                .scale(to: 1.7, duration: 0.18),
                .fadeOut(withDuration: 0.18)
            ]),
            .removeFromParent()
        ]))
    }

    // MARK: - Reporting

    private func publish(after delta: TimeInterval) {
        publishClock += delta
        guard publishClock >= 1.0 / 15 else { return }
        publishClock = 0
        publish()
    }

    private func publish() {
        eventSink?.hopSceneDidUpdate(
            HopRunSnapshot(
                height: currentMetres,
                coins: earnedCoins,
                boost: boostRemaining > 0
                    ? boostRemaining / HopTuning.boostDuration
                    : nil
            )
        )
    }

    private func finish(outcome: HopOutcome) {
        guard !hasFinished else { return }
        hasFinished = true
        setFlameVisible(false)
        chicken.physicsBody?.velocity = .zero
        speed = 0
        eventSink?.hopSceneDidFinish(
            stats: HopRunStats(
                height: currentMetres,
                coins: earnedCoins,
                clouds: bouncedClouds,
                cans: collectedCans,
                outcome: outcome
            )
        )
    }
}

enum HopCategory {
    static let chicken: UInt32 = 1 << 0
    static let coin: UInt32 = 1 << 1
    static let can: UInt32 = 1 << 2
    static let hazard: UInt32 = 1 << 3
}
