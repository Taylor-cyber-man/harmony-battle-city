import { getStageTerrain, getStageEnemySequence } from '../game/levels/LevelData'
import { getStateManager } from '../game/core/GameState'
import { getStageManager } from '../game/levels/LevelManager'
import router from '@ohos.router'
import { init as initRenderSystem, updateRenderSystem, render, renderTrees } from '../game/systems/RenderSystem'
import { initAI, updateEnemyAI, spawnEnemy, getEnemiesRemaining, getEnemiesSpawned, onEnemyDestroyed, shouldEnemyFire } from '../game/systems/AISystem'
import { initBulletPool, getBulletPool, fireBulletFromTank, fireBulletDouble } from '../game/systems/BulletSystem'
import { bulletVsTank, bulletVsBullet, isEagleRegion, tankVsTerrain, tankVsBoundary, addExplosion, updateExplosions, getExplosions, collectPowerUp, moveAndCheckBullet } from '../game/systems/CollisionSystem'
import { TankData, createPlayerTank, moveTank, updateDirection, damageTank, resetPowerLevel, setFrozen, isPowerUpTank, getScore } from '../game/entities/Tank'
import { initScore, addScore, loseLife, addLife, getLives, getScore as getGameScore, checkGameOver } from '../game/core/ScoreManager'
import { drawBullet, drawTankSprite, drawMuzzleFlash, drawShield, drawExplosion, drawSpawnAnimation, drawPowerUpIcon } from '../game/systems/DrawHelper'
import { drawEagle } from '../game/levels/Eagle'
import { setInputDirection, requestFire, setTileSize, getInputDirectionX, getInputDirectionY, consumeFireRequest } from '../game/core/GameEngine'
import { getStorage } from '../managers/StorageManager'
import { getAudioManager } from '../managers/AudioManager'
import { randomPowerUpType, createPowerUp, PowerUpData } from '../game/entities/PowerUp'
import { PLAYER_INITIAL_LIVES, STAGE_COUNT, EAGLE_WALL_POSITIONS, PLAYER1_START_X, PLAYER1_START_Y, MAX_ENEMIES_PER_STAGE, PowerUpType, SHOVEL_DURATION_FRAMES } from '../game/utils/Constants'
import { getPendingStage } from '../game/core/StageRouter'
import { common, ConfigurationConstant } from '@kit.AbilityKit'

let isGameStarted: boolean = false
let frameCounter: number = 0
let playerTank: TankData | null = null
let enemyTanks: TankData[] = []
let stageIndex: number = 0
let terrainData: number[][] = []
let brickMasks: number[][] = []
let currentPowerUp: PowerUpData | null = null
let stageClearTimer: number = 0
let gameOverTimer: number = 0
let autoDropTypeIndex: number = 1
let autoDropRespawnTimer: number = 0
let shovelTimer: number = 0
let introPhase: number = -1

interface EffectParticle {
  px: number
  py: number
  vx: number
  vy: number
  life: number
  maxLife: number
  color: string
  size: number
}

interface ShieldRing {
  x: number
  y: number
  r: number
  life: number
  maxLife: number
}

let effectParticles: EffectParticle[] = []
let shieldRings: ShieldRing[] = []

const HEAVY_HP_COLORS: string[] = ['#004D40', '#00695C', '#FFD740', '#90A4AE']

let tileSizeGlobal: number = 60
let canvasW: number = 1260
let canvasH: number = 600
let gameOffsetX: number = 0
let gameOffsetY: number = 0
let dPadRight: number = 0
let fireLeft: number = 0
let gameCanvasSize: number = 780
let uiPanelWidth: number = 0
let hudX: number = 0
let hudY: number = 0
let hudW: number = 0

let curDx: number = 0
let curDy: number = 0
let firePressed: boolean = false
let heldKeys: Record<number, number> = {}
let pendingUps: Record<number, number> = {}
let playerMuzzleFlash: number = 0
let playerIceSlideDx: number = 0
let playerIceSlideDy: number = 0
let pauseBtnX: number = 0
let pauseBtnY: number = 0
let pauseBtnR: number = 0
let pauseOverlayBtn1Rect: number[] = [0, 0, 0, 0]
let pauseOverlayBtn2Rect: number[] = [0, 0, 0, 0]

@Entry
@Component
struct GamePage {
  private settings: RenderingContextSettings = new RenderingContextSettings(true)
  private canvasCtx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings)
  @State gamePaused: boolean = false
  @StorageLink('currentColorMode') colorMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_DARK
  private gameTimer: number = -1

  isDark(): boolean {
    return this.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK
  }

  aboutToAppear(): void {
    let ctx = getContext(this) as common.UIAbilityContext
    getAudioManager().init(ctx)
    tileSizeGlobal = 60
    gameCanvasSize = tileSizeGlobal * 16
    setTileSize(tileSizeGlobal)
    updateRenderSystem(this.canvasCtx, gameCanvasSize, gameCanvasSize, tileSizeGlobal)
  }

  aboutToDisappear(): void {
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
      this.gameTimer = -1
    }
  }

  recalcLayout(w: number, h: number): void {
    canvasW = w
    canvasH = h
    let dpadW = Math.floor(w * 0.18)
    let fireW = Math.floor(w * 0.12)
    let hudW = Math.floor(w * 0.15)
    let gameAreaWidth = w - dpadW - fireW - hudW
    dPadRight = dpadW
    fireLeft = dpadW + gameAreaWidth
    hudX = fireLeft
    hudY = 0
    let hudH = Math.floor(h * 0.5)

    let availH = h
    gameCanvasSize = availH
    tileSizeGlobal = availH / 16
    setTileSize(tileSizeGlobal)

    gameOffsetX = dpadW + Math.floor((gameAreaWidth - gameCanvasSize) / 2)
    gameOffsetY = 0

    updateRenderSystem(this.canvasCtx, gameCanvasSize, gameCanvasSize, tileSizeGlobal)
  }

  startNewGame(): void {
    isGameStarted = true
    frameCounter = 0
    let pending = getPendingStage()
    stageIndex = pending
    let sm = getStateManager()
    sm.startGame()
    this.loadCurrentStage()
    sm.onLoadComplete()
    initRenderSystem(this.canvasCtx, gameCanvasSize, gameCanvasSize, tileSizeGlobal)
    initBulletPool()
    if (this.gameTimer !== -1) {
      clearInterval(this.gameTimer)
    }
    this.gameTimer = setInterval(() => {
      this.gameTick()
    }, 16)
    getAudioManager().playBGM('bgm_battle.wav')
  }

  loadCurrentStage(): void {
    let terrain = getStageTerrain(stageIndex)
    let enemySeq = getStageEnemySequence(stageIndex)
    let stageMgr = getStageManager()
    stageMgr.loadStage(stageIndex, terrain, enemySeq)
    terrainData = terrain
    brickMasks = []
    for (let y = 0; y < 16; y++) {
      brickMasks[y] = []
      for (let x = 0; x < 16; x++) {
        brickMasks[y][x] = (terrain[y][x] === 1) ? 0b1111 : 0
      }
    }
    initAI(enemySeq, stageIndex)
    initScore(PLAYER_INITIAL_LIVES)
    let startX = PLAYER1_START_X * tileSizeGlobal + tileSizeGlobal / 2
    let startY = PLAYER1_START_Y * tileSizeGlobal + tileSizeGlobal / 2
    playerTank = createPlayerTank(0, startX, startY, tileSizeGlobal)
    enemyTanks = []
    currentPowerUp = null
    stageClearTimer = 0
    gameOverTimer = 0
    autoDropTypeIndex = 1
    autoDropRespawnTimer = 0
    shovelTimer = 0
    playerIceSlideDx = 0
    playerIceSlideDy = 0
    introPhase = 0
    effectParticles = []
    shieldRings = []
  }

  gameTick(): void {
    if (this.gamePaused) {
      this.renderFrame()
      return
    }
    let tSize = tileSizeGlobal
    let cSize = gameCanvasSize
    frameCounter++

    if (introPhase >= 0) {
      introPhase++
      if (introPhase > 240) {
        introPhase = -1
      }
      this.renderFrame()
      return
    }

    if (autoDropRespawnTimer > 0) {
      autoDropRespawnTimer--
      currentPowerUp = null
    }

    if (autoDropRespawnTimer === 0 && autoDropTypeIndex >= 0 && currentPowerUp === null && frameCounter > 60) {
      let dropType = autoDropTypeIndex as PowerUpType
      for (let retry = 0; retry < 20; retry++) {
        let px = Math.floor(Math.random() * 12) + 2
        let py = Math.floor(Math.random() * 10) + 2
        if (terrainData[py][px] === 0) {
          currentPowerUp = createPowerUp(px, py, dropType)
          autoDropTypeIndex = -1
          break
        }
      }
    }

    if (firePressed) {
      requestFire()
      firePressed = false
    }

    this.processPendingUps()

    let keyDown = false
    let keysDown = Object.keys(heldKeys)
    for (let i = 0; i < keysDown.length; i++) {
      let k = parseInt(keysDown[i])
      if (heldKeys[k] > 0) {
        keyDown = true
        if (k === 2050) {
          requestFire()
        }
      }
    }

    let kdx = 0
    let kdy = 0
    if (keyDown) {
      let helds = Object.keys(heldKeys)
      for (let i = 0; i < helds.length; i++) {
        let k = parseInt(helds[i])
        if (heldKeys[k] > 0) {
          if (k === 2017) { kdx = -1 }
          if (k === 2020) { kdx = 1 }
          if (k === 2039) { kdy = -1 }
          if (k === 2035) { kdy = 1 }
        }
      }
      setInputDirection(kdx, kdy)
    } else if (curDx !== 0 || curDy !== 0) {
      setInputDirection(curDx, curDy)
    } else {
      setInputDirection(0, 0)
    }

    if (playerTank !== null && playerTank.isAlive) {
      let dx = getInputDirectionX()
      let dy = getInputDirectionY()

      let tankTileX = Math.floor(playerTank.x / tSize)
      let tankTileY = Math.floor(playerTank.y / tSize)
      let onIce = tankTileY >= 0 && tankTileY < 16 && tankTileX >= 0 && tankTileX < 16 && terrainData[tankTileY][tankTileX] === 5

      if (onIce && dx === 0 && dy === 0 && (playerIceSlideDx !== 0 || playerIceSlideDy !== 0)) {
        dx = playerIceSlideDx
        dy = playerIceSlideDy
      }

      if (dx !== 0 || dy !== 0) {
        updateDirection(playerTank, dx, dy)
        let origX = playerTank.x
        let origY = playerTank.y
        moveTank(playerTank, dx, dy, 0.016)
        if (tankVsTerrain(playerTank, terrainData, tSize) || tankVsBoundary(playerTank, cSize, tSize)) {
          playerTank.x = origX
          playerTank.y = origY
          playerIceSlideDx = 0
          playerIceSlideDy = 0
        } else {
          if (onIce) {
            playerIceSlideDx = dx
            playerIceSlideDy = dy
          } else {
            playerIceSlideDx = 0
            playerIceSlideDy = 0
          }
        }
      }
      if (consumeFireRequest()) {
        if (playerTank.powerLevel >= 2) {
          fireBulletDouble(playerTank, true, tSize)
        } else {
          fireBulletFromTank(playerTank, true, tSize)
        }
        playerTank.fireCooldown = 15
        playerMuzzleFlash = 5
        getAudioManager().playSfx('sfx_fire.wav')
      }
      if (playerTank.fireCooldown > 0) {
        playerTank.fireCooldown -= 1
      }
      if (playerMuzzleFlash > 0) {
        playerMuzzleFlash -= 1
      }
      if (playerTank.isShielded && playerTank.shieldTimer > 0) {
        playerTank.shieldTimer -= 1
        if (playerTank.shieldTimer <= 0) {
          playerTank.isShielded = false
        }
      }
    }

    updateEnemyAI(enemyTanks, playerTank !== null ? playerTank.x : 0, playerTank !== null ? playerTank.y : 0, terrainData, tSize)

    let newEnemy = spawnEnemy(enemyTanks, getStageManager().getEnemySequence(), stageIndex, tSize)
    if (newEnemy !== null) {
      enemyTanks.push(newEnemy)
    }

    let bullets = getBulletPool()
    let eagleHitFn = (): boolean => {
      return false
    }
    for (let i = 0; i < bullets.length; i++) {
      if (bullets[i].isActive) {
        moveAndCheckBullet(bullets[i], terrainData, brickMasks, tSize, cSize, eagleHitFn)
        if (bullets[i].isActive && isEagleRegion(bullets[i].x, bullets[i].y, tSize)) {
          bullets[i].isActive = false
          if (!bullets[i].isPlayerBullet) {
            getStateManager().onGameOver()
            getAudioManager().stopBGM()
            getAudioManager().playSfx('sfx_gameover.wav')
            gameOverTimer = 180
          }
        }
      }
    }

    bulletVsBullet(bullets)

    if (playerTank !== null && playerTank.isAlive) {
      for (let i = 0; i < bullets.length; i++) {
        if (bullets[i].isActive && !bullets[i].isPlayerBullet) {
          let hitTank = bulletVsTank(bullets[i], [playerTank], tSize)
          if (hitTank !== null) {
            addExplosion(playerTank.x, playerTank.y)
            getAudioManager().playSfx('sfx_explosion.wav')
            loseLife()
            resetPowerLevel(playerTank)
            if (checkGameOver()) {
              getStateManager().onGameOver()
              getStorage().saveScore(getGameScore())
              getAudioManager().stopBGM()
              getAudioManager().playSfx('sfx_gameover.wav')
              gameOverTimer = 180
            } else {
              playerTank.x = PLAYER1_START_X * tSize + tSize / 2
              playerTank.y = PLAYER1_START_Y * tSize + tSize / 2
              playerTank.direction = 0
              playerTank.isShielded = false
              playerTank.shieldTimer = 0
              playerIceSlideDx = 0
              playerIceSlideDy = 0
            }
          }
        }
      }
    }

    for (let i = 0; i < enemyTanks.length; i++) {
      let enemy = enemyTanks[i]
      if (!enemy.isAlive) {
        continue
      }
      if (shouldEnemyFire(enemy, playerTank !== null ? playerTank.x : 0, playerTank !== null ? playerTank.y : 0)) {
        let fired = fireBulletFromTank(enemy, false, tSize)
        if (fired !== null) {
          enemy.fireCooldown = 30
        }
      }
      if (enemy.fireCooldown > 0) {
        enemy.fireCooldown -= 1
      }
      if (enemy.spawnTimer > 0) {
        enemy.spawnTimer -= 1
        if (enemy.spawnTimer <= 0) {
          enemy.isSpawning = false
        }
      }
    }

    for (let i = 0; i < bullets.length; i++) {
      if (bullets[i].isActive && bullets[i].isPlayerBullet) {
        let hitEnemy = bulletVsTank(bullets[i], enemyTanks, tSize)
        if (hitEnemy !== null) {
          let isDestroyed = damageTank(hitEnemy, 1)
          addExplosion(hitEnemy.x, hitEnemy.y)
          if (isDestroyed) {
            addScore(getScore(hitEnemy))
            onEnemyDestroyed(hitEnemy)
            getAudioManager().playSfx('sfx_explosion.wav')
            if (isPowerUpTank(hitEnemy)) {
              for (let retry = 0; retry < 20; retry++) {
                let px = Math.floor(Math.random() * 12) + 2
                let py = Math.floor(Math.random() * 10) + 2
                if (terrainData[py][px] === 0) {
                  currentPowerUp = createPowerUp(px, py, randomPowerUpType())
                  break
                }
              }
            }
          }
        }
      }
    }

    if (currentPowerUp !== null && currentPowerUp.isActive && playerTank !== null && playerTank.isAlive) {
      if (collectPowerUp(playerTank, currentPowerUp, tSize)) {
        getAudioManager().playSfx('sfx_powerup.wav')
        let puType = currentPowerUp.type
        if (puType === 1) {
          for (let i = 0; i < enemyTanks.length; i++) {
            if (enemyTanks[i].isAlive) {
              enemyTanks[i].isAlive = false
              addExplosion(enemyTanks[i].x, enemyTanks[i].y)
              addScore(getScore(enemyTanks[i]))
              onEnemyDestroyed(enemyTanks[i])
            }
          }
        } else if (puType === 2) {
          playerTank.isShielded = true
          playerTank.shieldTimer = 600
          addScore(500)
        } else if (puType === 3) {
          for (let i = 0; i < enemyTanks.length; i++) {
            setFrozen(enemyTanks[i], true)
          }
          addScore(500)
        } else if (puType === 4) {
          for (let i = 0; i < EAGLE_WALL_POSITIONS.length; i++) {
            let wx = EAGLE_WALL_POSITIONS[i][0]
            let wy = EAGLE_WALL_POSITIONS[i][1]
            if (wy >= 0 && wy < 16 && wx >= 0 && wx < 16) {
              terrainData[wy][wx] = 2
              brickMasks[wy][wx] = 0
            }
          }
          shovelTimer = SHOVEL_DURATION_FRAMES
          addScore(500)
        } else {
          addLife()
          addScore(500)
        }
        currentPowerUp.isActive = false
        this.spawnPickupEffect(playerTank.x, playerTank.y, puType)
        let nextType = puType + 1
        if (nextType > 5) {
          nextType = 1
        }
        autoDropTypeIndex = nextType
        autoDropRespawnTimer = 60
      }
    }

    if (shovelTimer > 0) {
      shovelTimer--
      if (shovelTimer <= 0) {
        for (let i = 0; i < EAGLE_WALL_POSITIONS.length; i++) {
          let wx = EAGLE_WALL_POSITIONS[i][0]
          let wy = EAGLE_WALL_POSITIONS[i][1]
          if (wy >= 0 && wy < 16 && wx >= 0 && wx < 16 && terrainData[wy][wx] === 2) {
            terrainData[wy][wx] = 1
            brickMasks[wy][wx] = 0b1111
          }
        }
      }
    }

    updateExplosions()
    this.renderFrame()

    if (getStateManager().isGameOver()) {
      gameOverTimer--
      if (gameOverTimer <= 0) {
        router.back()
        if (this.gameTimer !== -1) {
          clearInterval(this.gameTimer)
          this.gameTimer = -1
        }
        gameOverTimer = 0
      }
    }

    let aliveCount = 0
    for (let i = 0; i < enemyTanks.length; i++) {
      if (enemyTanks[i].isAlive) {
        aliveCount++
      }
    }
    let rem = getEnemiesRemaining()
    if (rem <= 0 && aliveCount <= 0 && stageClearTimer === 0) {
      getStateManager().onStageClear()
      getAudioManager().playSfx('sfx_stageclear.wav')
      stageClearTimer = 180
    }
    if (stageClearTimer > 0) {
      stageClearTimer--
      if (stageClearTimer <= 0) {
        if (stageIndex < STAGE_COUNT - 1) {
          stageIndex++
        } else {
          stageIndex = 0
        }
        getStateManager().onTransitionComplete()
        this.loadCurrentStage()
        getStateManager().onLoadComplete()
      }
    }
  }

  renderFrame(): void {
    let ctx = this.canvasCtx
    let tSize = tileSizeGlobal
    let gSize = gameCanvasSize
    if (ctx === null) {
      return
    }

    ctx.fillStyle = '#080C18'
    ctx.fillRect(0, 0, canvasW, canvasH)

    if (introPhase >= 0) {
      this.drawIntroAnimation(ctx, gSize)
      return
    }

    this.fillMapGaps(ctx)

    this.drawControls(ctx)

    ctx.save()
    ctx.translate(gameOffsetX, gameOffsetY)

    ctx.beginPath()
    ctx.rect(0, 0, gSize, gSize)
    ctx.clip()

    render(terrainData, brickMasks)
    drawEagle(ctx, tSize)

    if (currentPowerUp !== null && currentPowerUp.isActive) {
      drawPowerUpIcon(ctx, currentPowerUp.x, currentPowerUp.y, currentPowerUp.type, tSize)
    }

    if (playerTank !== null && playerTank.isAlive) {
      drawTankSprite(ctx, playerTank.x, playerTank.y, playerTank.direction, '#FF5722', true, tSize)
      if (playerMuzzleFlash > 0) {
        drawMuzzleFlash(ctx, playerTank.x, playerTank.y, playerTank.direction, tSize)
      }
      if (playerTank.isShielded) {
        drawShield(ctx, playerTank.x, playerTank.y, tSize)
      }
    }

    for (let i = 0; i < enemyTanks.length; i++) {
      let e = enemyTanks[i]
      if (e.isAlive) {
        let color = '#FF5252'
        if (e.slotIndex % 2 === 1) {
          color = '#FF9100'
        }
        if (e.enemyType === 3) {
          let hpIdx = e.hp - 1
          if (hpIdx >= 0 && hpIdx < 4) {
            color = HEAVY_HP_COLORS[hpIdx]
          }
        }
        if (e.isFlashing && frameCounter % 16 < 8) {
          ctx.strokeStyle = '#FF0000'
          ctx.lineWidth = Math.round(tSize * 0.05)
          let r = tSize * 0.4
          ctx.strokeRect(e.x - r, e.y - r, r * 2, r * 2)
        }
        drawTankSprite(ctx, e.x, e.y, e.direction, color, false, tSize)
        if (e.isSpawning) {
          drawSpawnAnimation(ctx, e.x, e.y, e.spawnTimer, tSize)
        }
      }
    }

    let allBullets = getBulletPool()
    for (let i = 0; i < allBullets.length; i++) {
      if (allBullets[i].isActive) {
        drawBullet(ctx, allBullets[i].x, allBullets[i].y, allBullets[i].isPlayerBullet, allBullets[i].isArmorPiercing, tSize)
      }
    }

    let allExplosions = getExplosions()
    for (let i = 0; i < allExplosions.length; i++) {
      if (allExplosions[i].isActive) {
        drawExplosion(ctx, allExplosions[i].x, allExplosions[i].y, allExplosions[i].frame, tSize)
      }
    }

    renderTrees(terrainData)
    ctx.restore()

    for (let i = shieldRings.length - 1; i >= 0; i--) {
      let ring = shieldRings[i]
      let alpha = ring.life / ring.maxLife
      ctx.globalAlpha = alpha
      ctx.strokeStyle = '#00E5FF'
      ctx.lineWidth = 3
      ctx.beginPath()
      ctx.arc(ring.x, ring.y, ring.r, 0, Math.PI * 2)
      ctx.stroke()
      ring.r += tSize * 0.025
      ring.life--
      if (ring.life <= 0) {
        shieldRings[i] = shieldRings[shieldRings.length - 1]
        shieldRings.pop()
      }
    }

    for (let i = effectParticles.length - 1; i >= 0; i--) {
      let p = effectParticles[i]
      p.px += p.vx
      p.py += p.vy
      p.life--
      let alpha = p.life / p.maxLife
      ctx.globalAlpha = alpha
      ctx.fillStyle = p.color
      ctx.fillRect(p.px - p.size / 2, p.py - p.size / 2, p.size, p.size)
      if (p.life <= 0) {
        effectParticles[i] = effectParticles[effectParticles.length - 1]
        effectParticles.pop()
      }
    }
    ctx.globalAlpha = 1

    this.drawHUD(ctx)

    if (getStateManager().isGameOver()) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.82)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)
      ctx.fillStyle = '#FF1744'
      ctx.font = 'bold 44px sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('GΛME  OVER', gameOffsetX + gSize / 2, gameOffsetY + gSize / 2 - 12)
      ctx.fillStyle = '#FF5252'
      ctx.font = '14px monospace'
      ctx.fillText('[  PRESS  ESC  TO  CONTINUE  ]', gameOffsetX + gSize / 2, gameOffsetY + gSize / 2 + 28)
    }
    if (getStateManager().isTransitioning()) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.88)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)

      ctx.strokeStyle = '#FFD740'
      ctx.lineWidth = 1
      ctx.setLineDash([6, 4])
      ctx.strokeRect(gameOffsetX + gSize * 0.08, gameOffsetY + gSize * 0.08, gSize * 0.84, gSize * 0.84)
      ctx.setLineDash([])

      ctx.fillStyle = '#00FF41'
      ctx.font = 'bold 34px sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('◈  STΛGE  CLEΛR  ◈', gameOffsetX + gSize / 2, gameOffsetY + gSize * 0.45)
      ctx.fillStyle = '#FFD740'
      ctx.font = 'bold 18px monospace'
      ctx.fillText('VICTORY', gameOffsetX + gSize / 2, gameOffsetY + gSize * 0.35)
    }
    if (this.gamePaused) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0.88)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)

      ctx.strokeStyle = '#00E5FF'
      ctx.lineWidth = 1
      ctx.setLineDash([4, 8])
      ctx.strokeRect(gameOffsetX + gSize * 0.08, gameOffsetY + gSize * 0.08, gSize * 0.84, gSize * 0.84)
      ctx.setLineDash([])

      ctx.fillStyle = '#00E5FF'
      ctx.font = 'bold 36px sans-serif'
      ctx.textAlign = 'center'
      ctx.textBaseline = 'middle'
      ctx.fillText('◈  PΛUSED  ◈', gameOffsetX + gSize / 2, gameOffsetY + gSize * 0.28)

      let btnW = Math.min(200, gSize * 0.55)
      let btnH = 72
      let btnGap = 18
      let centerX = gameOffsetX + gSize / 2
      let btnX = centerX - btnW / 2
      let btn1Y = gameOffsetY + gSize * 0.43
      let btn2Y = btn1Y + btnH + btnGap

      pauseOverlayBtn1Rect = [btnX, btn1Y, btnW, btnH]
      pauseOverlayBtn2Rect = [btnX, btn2Y, btnW, btnH]

      ctx.fillStyle = 'rgba(0, 229, 255, 0.15)'
      this.fillRoundRect(ctx, btnX, btn1Y, btnW, btnH, 4)
      ctx.strokeStyle = '#00E5FF'
      ctx.lineWidth = 1
      this.fillRoundRect(ctx, btnX, btn1Y, btnW, btnH, 4)
      ctx.fillStyle = '#FFFFFF'
      ctx.font = 'bold 40px sans-serif'
      ctx.fillText('继续游戏', centerX, btn1Y + btnH / 2)

      ctx.fillStyle = 'rgba(255, 82, 82, 0.15)'
      this.fillRoundRect(ctx, btnX, btn2Y, btnW, btnH, 4)
      ctx.strokeStyle = '#FF5252'
      ctx.lineWidth = 1
      this.fillRoundRect(ctx, btnX, btn2Y, btnW, btnH, 4)
      ctx.fillStyle = '#FFFFFF'
      ctx.font = 'bold 40px sans-serif'
      ctx.fillText('返回主菜单', centerX, btn2Y + btnH / 2)
    }

    ctx.strokeStyle = '#00FF41'
    ctx.lineWidth = 2
    ctx.setLineDash([8, 4])
    ctx.strokeRect(gameOffsetX, gameOffsetY, gSize, gSize)
    ctx.setLineDash([])
  }

  fillMapGaps(ctx: CanvasRenderingContext2D): void {
    let gapColor = this.isDark() ? '#0A0A14' : '#C5DCE8'
    ctx.fillStyle = gapColor
    ctx.fillRect(gameOffsetX, 0, gameCanvasSize, gameOffsetY)
    ctx.fillRect(gameOffsetX, gameOffsetY + gameCanvasSize, gameCanvasSize, canvasH - gameOffsetY - gameCanvasSize)
    if (gameOffsetX > dPadRight) {
      ctx.fillRect(dPadRight, gameOffsetY, gameOffsetX - dPadRight, gameCanvasSize)
    }
    let mapRight = gameOffsetX + gameCanvasSize
    if (fireLeft > mapRight) {
      ctx.fillRect(mapRight, gameOffsetY, fireLeft - mapRight, gameCanvasSize)
    }
  }

  drawControls(ctx: CanvasRenderingContext2D): void {
    let columnW = dPadRight
    let btnS = Math.max(56, Math.floor(columnW * 0.35))
    let dPadCX = Math.floor(dPadRight / 2) + Math.floor(btnS * 0.36)
    let dPadCY = Math.floor(canvasH / 2)
    let gap = Math.floor(btnS * 0.08)
    let crossSz = btnS * 0.32

    ctx.fillStyle = 'rgba(5, 11, 20, 0.85)'
    ctx.fillRect(0, 0, dPadRight, canvasH)

    this.drawDpad(ctx, dPadCX, dPadCY - btnS - gap, btnS, crossSz, 0)
    this.drawDpad(ctx, dPadCX - btnS - gap, dPadCY, btnS, crossSz, 1)
    this.drawDpad(ctx, dPadCX + btnS + gap, dPadCY, btnS, crossSz, 2)
    this.drawDpad(ctx, dPadCX, dPadCY + btnS + gap, btnS, crossSz, 3)

    ctx.strokeStyle = '#00E5FF'
    ctx.lineWidth = 2
    let rr = Math.max(8, Math.floor(btnS * 0.18))
    ctx.beginPath()
    ctx.arc(dPadCX, dPadCY, rr, 0, Math.PI * 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(dPadCX - rr * 1.6, dPadCY)
    ctx.lineTo(dPadCX + rr * 1.6, dPadCY)
    ctx.moveTo(dPadCX, dPadCY - rr * 1.6)
    ctx.lineTo(dPadCX, dPadCY + rr * 1.6)
    ctx.stroke()

    ctx.fillStyle = 'rgba(5, 11, 20, 0.85)'
    let fireColW = canvasW - fireLeft
    ctx.fillRect(fireLeft, 0, fireColW, canvasH)

    let fireCX = fireLeft + Math.floor(fireColW / 2)
    let fireCY = Math.floor(canvasH * 0.5)
    let fireR = Math.max(48, Math.floor(fireColW * 0.25))
    let fireFS = Math.max(12, Math.floor(fireR * 0.3))

    ctx.strokeStyle = '#FF5722'
    ctx.lineWidth = 3
    ctx.beginPath()
    ctx.arc(fireCX, fireCY, fireR, 0, Math.PI * 2)
    ctx.stroke()

    ctx.strokeStyle = '#FF7043'
    ctx.lineWidth = 1
    ctx.setLineDash([3, 5])
    ctx.beginPath()
    ctx.arc(fireCX, fireCY, fireR * 0.82, 0, Math.PI * 2)
    ctx.stroke()
    ctx.setLineDash([])

    ctx.fillStyle = '#FF5722'
    ctx.font = 'bold ' + fireFS + 'px monospace'
    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'
    ctx.fillText('FIRE', fireCX, fireCY - fireR * 0.05)

    let pauseR = Math.max(22, Math.floor(fireR * 0.3))
    let pauseCX = fireCX
    let pauseCY = fireCY + fireR + pauseR + Math.max(10, Math.floor(fireR * 0.15))
    pauseBtnX = pauseCX
    pauseBtnY = pauseCY
    pauseBtnR = pauseR

    ctx.strokeStyle = '#00E5FF'
    ctx.lineWidth = 2
    ctx.beginPath()
    ctx.arc(pauseCX, pauseCY, pauseR, 0, Math.PI * 2)
    ctx.stroke()

    let barW = Math.max(3, Math.floor(pauseR * 0.22))
    let barH = Math.max(10, Math.floor(pauseR * 0.6))
    let barGap = Math.max(3, Math.floor(pauseR * 0.18))
    ctx.fillStyle = '#00E5FF'
    ctx.fillRect(pauseCX - barGap - barW, pauseCY - barH / 2, barW, barH)
    ctx.fillRect(pauseCX + barGap, pauseCY - barH / 2, barW, barH)
  }

  drawDpad(ctx: CanvasRenderingContext2D, cx: number, cy: number, s: number, cs: number, dir: number): void {
    ctx.strokeStyle = '#1A2A3A'
    ctx.lineWidth = 2
    ctx.strokeRect(cx - s / 2, cy - s / 2, s, s)

    ctx.strokeStyle = '#00E5FF'
    ctx.lineWidth = 1

    if (dir === 0) {
      ctx.beginPath()
      ctx.moveTo(cx, cy - cs)
      ctx.lineTo(cx - cs * 0.7, cy)
      ctx.lineTo(cx + cs * 0.7, cy)
      ctx.closePath()
    } else if (dir === 1) {
      ctx.beginPath()
      ctx.moveTo(cx - cs, cy)
      ctx.lineTo(cx, cy - cs * 0.7)
      ctx.lineTo(cx, cy + cs * 0.7)
      ctx.closePath()
    } else if (dir === 2) {
      ctx.beginPath()
      ctx.moveTo(cx + cs, cy)
      ctx.lineTo(cx, cy - cs * 0.7)
      ctx.lineTo(cx, cy + cs * 0.7)
      ctx.closePath()
    } else {
      ctx.beginPath()
      ctx.moveTo(cx, cy + cs)
      ctx.lineTo(cx - cs * 0.7, cy)
      ctx.lineTo(cx + cs * 0.7, cy)
      ctx.closePath()
    }
    ctx.stroke()

    ctx.beginPath()
    ctx.moveTo(cx, cy - cs * 0.3)
    ctx.lineTo(cx, cy + cs * 0.3)
    ctx.moveTo(cx - cs * 0.3, cy)
    ctx.lineTo(cx + cs * 0.3, cy)
    ctx.stroke()
  }

  fillRoundRect(ctx: CanvasRenderingContext2D, x: number, y: number, w: number, h: number, r: number): void {
    ctx.beginPath()
    ctx.moveTo(x + r, y)
    ctx.lineTo(x + w - r, y)
    ctx.arcTo(x + w, y, x + w, y + r, r)
    ctx.lineTo(x + w, y + h - r)
    ctx.arcTo(x + w, y + h, x + w - r, y + h, r)
    ctx.lineTo(x + r, y + h)
    ctx.arcTo(x, y + h, x, y + h - r, r)
    ctx.lineTo(x, y + r)
    ctx.arcTo(x, y, x + r, y, r)
    ctx.closePath()
    ctx.fill()
  }

  drawHUD(ctx: CanvasRenderingContext2D): void {
    let lives = getLives()
    let aliveCount = 0
    for (let i = 0; i < enemyTanks.length; i++) {
      if (enemyTanks[i].isAlive) {
        aliveCount++
      }
    }
    let remaining = MAX_ENEMIES_PER_STAGE - getEnemiesSpawned() + aliveCount
    if (remaining < 0) {
      remaining = 0
    }

    let padding = Math.max(8, Math.floor(hudW * 0.1))
    let titleSize = Math.max(12, Math.floor(hudW * 2.8))
    let leftShift = Math.floor(hudW * 0.20)
    let startX = hudX + padding - leftShift

    let tankW = Math.max(20, Math.floor(hudW * 0.5 * 1.25))
    let tankH = tankW * 0.7
    let tankGap = Math.max(3, Math.floor(tankW * 0.1))
    let cols = 2
    let rowH = tankH + tankGap
    let startY = padding

    ctx.fillStyle = 'rgba(5, 11, 20, 0.9)'
    ctx.fillRect(hudX, hudY, hudW, canvasH)

    ctx.fillStyle = '#00E5FF'
    ctx.font = 'bold ' + titleSize + 'px monospace'
    ctx.textAlign = 'left'
    ctx.textBaseline = 'top'
    ctx.fillText('TΛNK', startX, startY)
    ctx.fillText('COUNT', startX, startY + titleSize + 2)

    ctx.strokeStyle = '#1A2A3A'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(startX, startY + titleSize * 2 + 6)
    ctx.lineTo(startX + tankW * cols + tankGap + padding, startY + titleSize * 2 + 6)
    ctx.stroke()

    let tankStartY = startY + titleSize * 2 + 12
    for (let i = 0; i < remaining; i++) {
      let col = i % cols
      let row = Math.floor(i / cols)
      let tx = startX + col * (tankW + tankGap)
      let ty = tankStartY + row * rowH
      let cx = tx + tankW / 2
      let cy = ty + tankH / 2

      ctx.fillStyle = '#00E5FF'
      ctx.fillRect(tx + tankW * 0.05, cy - tankH * 0.15, tankW * 0.9, tankH * 0.6)
      ctx.fillRect(cx - tankW * 0.12, cy - tankH * 0.3, tankW * 0.24, tankH * 0.24)
      ctx.beginPath()
      ctx.moveTo(cx + tankW * 0.12, cy - tankH * 0.18)
      ctx.lineTo(cx + tankW * 0.4, cy - tankH * 0.18)
      ctx.strokeStyle = '#00E5FF'
      ctx.lineWidth = Math.max(1, Math.floor(tankW * 0.08))
      ctx.stroke()
      ctx.fillStyle = '#00B8D4'
      ctx.fillRect(tx, cy + tankH * 0.3, tankW * 0.16, tankH * 0.15)
      ctx.fillRect(tx + tankW * 0.84, cy + tankH * 0.3, tankW * 0.16, tankH * 0.15)
    }

    let livesUp = Math.floor(canvasH * 0.12)
    let livesY = canvasH - padding * 2 - (lives * (rowH)) - padding - livesUp
    ctx.fillStyle = '#FFD740'
    ctx.font = 'bold ' + titleSize + 'px monospace'
    ctx.fillText('LIVES', startX, livesY)

    ctx.strokeStyle = '#1A2A3A'
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(startX, livesY + titleSize + 4)
    ctx.lineTo(startX + tankW + padding, livesY + titleSize + 4)
    ctx.stroke()

    let lifeStartY = livesY + titleSize + 12
    let battW = Math.max(24, Math.floor(hudW * 0.52))
    let battH = Math.max(12, Math.floor(battW * 0.35))
    let battGap = Math.max(4, Math.floor(battH * 0.4))
    let tipW = Math.max(4, Math.floor(battW * 0.12))
    let tipH = Math.max(5, Math.floor(battH * 0.4))
    for (let i = 0; i < lives; i++) {
      let bx = startX
      let by = lifeStartY + i * (battH + battGap) + battH / 2

      ctx.strokeStyle = '#FFD740'
      ctx.lineWidth = 2
      ctx.strokeRect(bx, by - battH / 2, battW, battH)
      ctx.fillStyle = '#FFD740'
      ctx.fillRect(bx + 2, by - battH / 2 + 2, battW - 4, battH - 4)
      ctx.fillStyle = '#FFA000'
      ctx.fillRect(bx + battW * 0.05, by - battH / 2 + 3, battW * 0.78, battH - 6)
      ctx.strokeStyle = '#FFD740'
      ctx.lineWidth = 1
      ctx.strokeRect(bx + battW, by - tipH / 2, tipW, tipH)
      ctx.fillStyle = '#FFA000'
      ctx.fillRect(bx + battW, by - tipH / 2 + 1, tipW, tipH - 2)
    }
  }

  // 根据道具类型触发独立视觉效果（1手雷-红爆/2头盔-青环/3时钟-蓝雪/4铲子-金炸/5坦克-绿升）
  spawnPickupEffect(tx: number, ty: number, puType: number): void {
    let colors: string[] = []
    let count: number = 0
    let speed: number = 0
    let life: number = 0

    if (puType === 1) {
      colors = ['#FF1744', '#FF5252', '#FF8A80', '#FF5722']
      count = 40
      speed = 3
      life = 20
    } else if (puType === 2) {
      for (let i = 0; i < 3; i++) {
        shieldRings.push({ x: tx, y: ty, r: 12 + i * 8, life: 30 - i * 6, maxLife: 30 - i * 6 })
      }
      colors = ['#00E5FF', '#00B8D4', '#84FFFF']
      count = 16
      speed = 1.5
      life = 18
    } else if (puType === 3) {
      colors = ['#40C4FF', '#80DEEA', '#B3E5FC', '#E1F5FE']
      count = 30
      speed = 0.8
      life = 30
    } else if (puType === 4) {
      let baseCX = 7.5 * tileSizeGlobal
      let baseCY = 14 * tileSizeGlobal
      tx = baseCX
      ty = baseCY
      colors = ['#FFD740', '#FFA000', '#FFECB3', '#FFE082']
      count = 36
      speed = 2.5
      life = 24
    } else {
      colors = ['#00FF41', '#69F0AE', '#B9F6CA', '#E8F5E9']
      count = 24
      speed = 1.8
      life = 22
    }

    for (let i = 0; i < count; i++) {
      let angle = Math.random() * Math.PI * 2
      let spd = speed * (0.5 + Math.random() * 1.5)
      let vx = Math.cos(angle) * spd
      let vy = Math.sin(angle) * spd
      if (puType === 3) {
        vy = -Math.abs(vy) - Math.random() * speed
        vx = vx * 0.3
      }
      if (puType === 5) {
        vy = -Math.abs(vy) - Math.random() * speed * 0.5
      }
      effectParticles.push({
        px: tx + Math.random() * 4 - 2,
        py: ty + Math.random() * 4 - 2,
        vx: vx,
        vy: vy,
        life: Math.floor(life * (0.5 + Math.random() * 0.5)),
        maxLife: life,
        color: colors[Math.floor(Math.random() * colors.length)],
        size: 2 + Math.random() * 4
      })
    }
  }

  drawIntroAnimation(ctx: CanvasRenderingContext2D, gSize: number): void {
    let phase = introPhase
    let cx = gameOffsetX + gSize / 2
    let cy = gameOffsetY + gSize / 2

    ctx.textAlign = 'center'
    ctx.textBaseline = 'middle'

    if (phase < 30) {
      let alpha = 1 - phase / 30
      ctx.fillStyle = 'rgba(0, 0, 0, ' + alpha.toString() + ')'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)
      return
    }

    if (phase < 100) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)

      let localPhase = phase - 30
      let scale = 0.5 + 0.5 * Math.min(1, localPhase / 20)
      let titleAlpha = Math.min(1, localPhase / 15)
      ctx.globalAlpha = titleAlpha

      ctx.fillStyle = '#00FF41'
      ctx.font = 'bold ' + Math.floor(34 * scale) + 'px sans-serif'
      ctx.fillText('◈  STΛGE  ' + (stageIndex + 1).toString().padStart(2, '0') + '  ◈', cx, cy - 12)

      if (localPhase > 10) {
        let subAlpha = Math.min(1, (localPhase - 10) / 10)
        ctx.globalAlpha = subAlpha
        ctx.fillStyle = '#FFD740'
        ctx.font = 'bold 16px monospace'
        ctx.fillText('PREPARE  FOR  BATTLE', cx, cy + 32)
      }
      ctx.globalAlpha = 1
      return
    }

    if (phase < 160) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)

      let localPhase = phase - 100
      let alpha = 1 - Math.max(0, (localPhase - 40) / 20)
      ctx.globalAlpha = alpha
      ctx.fillStyle = '#00E5FF'
      ctx.font = 'bold 42px sans-serif'
      ctx.fillText('READY?', cx, cy)

      if (localPhase < 15 || (localPhase > 30 && localPhase < 45)) {
        ctx.fillStyle = '#FF00FF'
        let blinkAlpha = localPhase < 15 ? localPhase / 15 : (localPhase - 30) / 15
        ctx.globalAlpha = blinkAlpha
        ctx.fillRect(gameOffsetX + gSize * 0.3, gameOffsetY + gSize * 0.6, gSize * 0.4, gSize * 0.05)
      }
      ctx.globalAlpha = 1
      return
    }

    if (phase < 220) {
      ctx.fillStyle = 'rgba(0, 0, 0, 0)'
      ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)

      let localPhase = phase - 160
      let scale = 0.3 + 0.7 * Math.min(1, localPhase / 10)
      let alpha = Math.min(1, localPhase / 8)

      ctx.globalAlpha = alpha
      ctx.fillStyle = '#00FF41'
      ctx.font = 'bold ' + Math.floor(52 * scale) + 'px sans-serif'
      ctx.fillText('GO!', cx, cy)

      if (localPhase > 5 && effectParticles.length === 0) {
        for (let i = 0; i < 50; i++) {
          let angle = Math.random() * Math.PI * 2
          let spd = 3 + Math.random() * 4
          effectParticles.push({
            px: cx + Math.random() * 20 - 10,
            py: cy + Math.random() * 20 - 10,
            vx: Math.cos(angle) * spd,
            vy: Math.sin(angle) * spd,
            life: Math.floor(15 + Math.random() * 10),
            maxLife: 25,
            color: ['#00FF41', '#00E5FF', '#FFD740', '#FFFFFF'][Math.floor(Math.random() * 4)],
            size: 2 + Math.random() * 4
          })
        }
      }
      ctx.globalAlpha = 1
      return
    }

    ctx.fillStyle = 'rgba(0, 0, 0, 0)'
    ctx.fillRect(gameOffsetX, gameOffsetY, gSize, gSize)
  }

  handleTouch(event: TouchEvent): void {
    if (event.type === TouchType.Down || event.type === TouchType.Move) {
      let touch = event.touches[0]
      let tx = touch.x
      let ty = touch.y

      if (this.gamePaused) {
        if (event.type === TouchType.Down) {
          let bx1 = pauseOverlayBtn1Rect[0]
          let by1 = pauseOverlayBtn1Rect[1]
          let bw1 = pauseOverlayBtn1Rect[2]
          let bh1 = pauseOverlayBtn1Rect[3]
          if (tx > bx1 && tx < bx1 + bw1 && ty > by1 && ty < by1 + bh1) {
            this.gamePaused = false
            return
          }
          let bx2 = pauseOverlayBtn2Rect[0]
          let by2 = pauseOverlayBtn2Rect[1]
          let bw2 = pauseOverlayBtn2Rect[2]
          let bh2 = pauseOverlayBtn2Rect[3]
          if (tx > bx2 && tx < bx2 + bw2 && ty > by2 && ty < by2 + bh2) {
            router.back()
            return
          }
        }
        return
      }

      if (tx >= 0 && tx < dPadRight) {
        let dPadCX = Math.floor(dPadRight / 2)
        let dPadCY = Math.floor(canvasH / 2)
        let columnW = dPadRight
        let btnS = Math.max(56, Math.floor(columnW * 0.35))
        let gap = Math.floor(btnS * 0.1)
        let half = Math.floor(btnS / 2)

        let inUp = (tx > dPadCX - half && tx < dPadCX + half && ty > dPadCY - btnS - gap - half && ty < dPadCY - gap + half)
        let inDown = (tx > dPadCX - half && tx < dPadCX + half && ty > dPadCY + gap - half && ty < dPadCY + btnS + gap + half)
        let inLeft = (tx > dPadCX - btnS - gap - half && tx < dPadCX - gap + half && ty > dPadCY - half && ty < dPadCY + half)
        let inRight = (tx > dPadCX + gap - half && tx < dPadCX + btnS + gap + half && ty > dPadCY - half && ty < dPadCY + half)

        curDx = 0
        curDy = 0
        if (inLeft) {
          curDx = -1
        }
        if (inRight) {
          curDx = 1
        }
        if (inUp) {
          curDy = -1
        }
        if (inDown) {
          curDy = 1
        }
      } else if (tx > fireLeft) {
        curDx = 0
        curDy = 0
        let fireColW = canvasW - fireLeft
        let fireCX = fireLeft + Math.floor(fireColW / 2)
        let fireCY = Math.floor(canvasH * 0.5)
        let fireR = Math.max(48, Math.floor(fireColW * 0.25))
        let dx = tx - fireCX
        let dy = ty - fireCY
        if (dx * dx + dy * dy < fireR * fireR) {
          firePressed = true
        } else {
          let pdx = tx - pauseBtnX
          let pdy = ty - pauseBtnY
          if (pdx * pdx + pdy * pdy < pauseBtnR * pauseBtnR) {
            this.gamePaused = true
            setInputDirection(0, 0)
            curDx = 0
            curDy = 0
          }
        }
      }
    } else if (event.type === TouchType.Up) {
      curDx = 0
      curDy = 0
    }
  }

  processPendingUps(): void {
    let ups = Object.keys(pendingUps)
    for (let i = 0; i < ups.length; i++) {
      let k = parseInt(ups[i])
      if (pendingUps[k] >= 0 && frameCounter - pendingUps[k] >= 4) {
        heldKeys[k] = 0
        pendingUps[k] = -1
      }
    }
    let helds = Object.keys(heldKeys)
    let kdx = 0
    let kdy = 0
    for (let i = 0; i < helds.length; i++) {
      let k = parseInt(helds[i])
      if (heldKeys[k] > 0) {
        if (k === 2017) { kdx = -1 }
        if (k === 2020) { kdx = 1 }
        if (k === 2039) { kdy = -1 }
        if (k === 2035) { kdy = 1 }
      }
    }
    if (kdx !== 0 || kdy !== 0) {
      setInputDirection(kdx, kdy)
    }
  }

  handleKeyEvent(type: number, keyCode: number): void {
    if (type === 0) {
      if (keyCode === 2070) {
        this.gamePaused = !this.gamePaused
        return
      }
      heldKeys[keyCode] = 1
      pendingUps[keyCode] = -1
      let kdx = 0
      let kdy = 0
      if (heldKeys[2017] !== undefined && heldKeys[2017] > 0) { kdx = -1 }
      if (heldKeys[2020] !== undefined && heldKeys[2020] > 0) { kdx = 1 }
      if (heldKeys[2039] !== undefined && heldKeys[2039] > 0) { kdy = -1 }
      if (heldKeys[2035] !== undefined && heldKeys[2035] > 0) { kdy = 1 }
      setInputDirection(kdx, kdy)
      if (keyCode === 2050) {
        requestFire()
      }
    } else if (type === 1) {
      pendingUps[keyCode] = frameCounter
    }
  }

  build() {
    Stack() {
      Canvas(this.canvasCtx)
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDark() ? '#0D0D1A' : '#D6EAF8')
        .focusable(true)
        .defaultFocus(true)
        .onAreaChange((oldArea: Area, newArea: Area) => {
          let w = newArea.width as number
          let h = newArea.height as number
          if (w > 0 && h > 0 && (w !== canvasW || h !== canvasH)) {
            this.recalcLayout(w, h)
            if (!isGameStarted) {
              this.startNewGame()
            }
          }
        })
        .onTouch((event: TouchEvent) => {
          this.handleTouch(event)
        })
        .onKeyEvent((event: KeyEvent) => {
          this.handleKeyEvent(event.type, event.keyCode)
          return false
        })
    }
    .width('100%')
    .height('100%')
    .focusable(true)
    .defaultFocus(true)
    .onKeyEvent((event: KeyEvent) => {
      this.handleKeyEvent(event.type, event.keyCode)
      return false
    })
  }
}

export default GamePage
