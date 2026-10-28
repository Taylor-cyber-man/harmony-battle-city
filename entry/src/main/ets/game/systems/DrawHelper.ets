import {
  COLOR_BULLET_PLAYER, COLOR_BULLET_ENEMY, COLOR_BULLET_ARMOR,
  COLOR_EXPLOSION_1, COLOR_EXPLOSION_2, COLOR_EXPLOSION_3, COLOR_EXPLOSION_4,
  COLOR_SHIELD, COLOR_PLAYER_BODY, COLOR_PLAYER_TURRET, COLOR_PLAYER_STRIPE,
  COLOR_PLAYER_TREAD, COLOR_PLAYER_BARREL, COLOR_ENEMY_BODY_WHITE,
  COLOR_ENEMY_TURRET_WHITE, COLOR_ENEMY_BODY_DARK, COLOR_ENEMY_TURRET_DARK,
  COLOR_ENEMY_TREAD
} from '../utils/Constants'

let cachedTS: number = 0
let cTankW: number = 0
let cTankH: number = 0
let cTreadW: number = 0
let cBodyW: number = 0
let cTurretW: number = 0
let cTurretH: number = 0
let cBW: number = 0
let cBL: number = 0
let cSegs: number = 5

function ensureTankDims(ts: number): void {
  if (ts === cachedTS) {
    return
  }
  cachedTS = ts
  cTankW = Math.max(14, Math.floor(ts * 0.76))
  cTankH = Math.max(12, Math.floor(ts * 0.68))
  cTreadW = Math.max(4, Math.floor(cTankW * 0.22))
  cBodyW = cTankW - cTreadW * 2
  cTurretW = Math.max(6, Math.floor(cBodyW * 0.5))
  cTurretH = Math.max(5, Math.floor(cTurretW * 0.78))
  cBW = Math.max(2, Math.floor(ts * 0.04))
  cBL = Math.max(8, Math.floor(ts * 0.28))
}

function drawBullet(ctx: CanvasRenderingContext2D, x: number, y: number, isPlayer: boolean, isArmorPiercing: boolean, tileSize: number): void {
  let bw = Math.max(8, Math.floor(tileSize / 8))
  let bh = Math.max(12, Math.floor(tileSize / 7))
  if (isArmorPiercing) {
    ctx.fillStyle = COLOR_BULLET_ARMOR
    bw = Math.floor(bw * 1.5)
    bh = Math.floor(bh * 1.3)
  } else if (isPlayer) {
    ctx.fillStyle = COLOR_BULLET_PLAYER
  } else {
    ctx.fillStyle = COLOR_BULLET_ENEMY
  }
  ctx.fillRect(x - bw / 2, y - bh / 2, bw, bh)

  ctx.fillStyle = '#FFFFFF'
  ctx.fillRect(x - bw / 4, y - bh / 2 + 2, bw / 2, bh - 4)
}

function drawTankSprite(ctx: CanvasRenderingContext2D, x: number, y: number, direction: number, turretColor: string, isPlayer: boolean, tileSize: number): void {
  ensureTankDims(tileSize)
  let tankW = cTankW
  let tankH = cTankH
  let treadW = cTreadW
  let bodyW = cBodyW
  let turretW = cTurretW
  let turretH = cTurretH
  let bW = cBW
  let bL = cBL
  let segs = cSegs

  let isVert = direction === 0 || direction === 1

  let bodyColor: string
  let treadColor: string
  let turretBase: string
  let barrelColor: string
  let stripeColor: string
  let detailColor: string

  if (isPlayer) {
    bodyColor = COLOR_PLAYER_BODY
    treadColor = COLOR_PLAYER_TREAD
    turretBase = COLOR_PLAYER_TURRET
    barrelColor = COLOR_PLAYER_BARREL
    stripeColor = COLOR_PLAYER_STRIPE
    detailColor = '#060C18'
  } else {
    if (turretColor === '#FF5252') {
      bodyColor = COLOR_ENEMY_BODY_WHITE
      detailColor = '#1A0A14'
    } else {
      bodyColor = COLOR_ENEMY_BODY_DARK
      detailColor = '#0A0A0A'
    }
    treadColor = COLOR_ENEMY_TREAD
    turretBase = turretColor
    barrelColor = '#808080'
    stripeColor = turretColor
  }

  if (isVert) {
    let top = y - tankH / 2

    ctx.fillStyle = treadColor
    ctx.fillRect(x - tankW / 2, top, treadW, tankH)
    ctx.fillRect(x + tankW / 2 - treadW, top, treadW, tankH)

    let segH = (tankH - 1) / segs
    ctx.fillStyle = detailColor
    for (let s = 1; s < segs; s++) {
      let sy = top + Math.floor(s * segH)
      ctx.fillRect(x - tankW / 2 + 1, sy, treadW - 2, 1)
      ctx.fillRect(x + tankW / 2 - treadW + 1, sy, treadW - 2, 1)
    }
    ctx.fillStyle = stripeColor
    for (let s = 0; s < segs; s++) {
      let sy = top + Math.floor(s * segH) + Math.floor(segH * 0.35)
      ctx.fillRect(x - tankW / 2 + 4, sy, treadW - 8, Math.max(1, Math.floor(segH * 0.15)))
      ctx.fillRect(x + tankW / 2 - treadW + 4, sy, treadW - 8, Math.max(1, Math.floor(segH * 0.15)))
    }

    ctx.fillStyle = bodyColor
    ctx.fillRect(x - bodyW / 2, top + 1, bodyW, tankH - 2)

    ctx.strokeStyle = detailColor
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(x - bodyW / 2 + 2, top + tankH * 0.35)
    ctx.lineTo(x + bodyW / 2 - 2, top + tankH * 0.35)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(x - bodyW / 2 + 2, top + tankH * 0.6)
    ctx.lineTo(x + bodyW / 2 - 2, top + tankH * 0.6)
    ctx.stroke()

    let tcx = x
    let tcy = top + tankH * 0.2 + turretH / 2
    ctx.fillStyle = turretBase
    ctx.fillRect(tcx - turretW / 2, tcy - turretH / 2, turretW, turretH)
    ctx.strokeStyle = stripeColor
    ctx.lineWidth = Math.max(1, Math.floor(tileSize * 0.02))
    ctx.strokeRect(tcx - turretW / 2, tcy - turretH / 2, turretW, turretH)
    ctx.fillStyle = bodyColor
    ctx.fillRect(tcx - turretW / 2 - 1, tcy, turretH, 1)

    ctx.fillStyle = barrelColor
    if (direction === 0) {
      ctx.fillRect(x - bW / 2, tcy - turretH / 2 - bL, bW, bL)
    } else {
      ctx.fillRect(x - bW / 2, tcy + turretH / 2, bW, bL)
    }
  } else {
    let left = x - tankW / 2

    ctx.fillStyle = treadColor
    ctx.fillRect(left, y - tankW / 2, tankH, treadW)
    ctx.fillRect(left, y + tankW / 2 - treadW, tankH, treadW)

    let segW = (tankH - 1) / segs
    ctx.fillStyle = detailColor
    for (let s = 1; s < segs; s++) {
      let sx = left + Math.floor(s * segW)
      ctx.fillRect(sx, y - tankW / 2 + 1, 1, treadW - 2)
      ctx.fillRect(sx, y + tankW / 2 - treadW + 1, 1, treadW - 2)
    }
    ctx.fillStyle = stripeColor
    for (let s = 0; s < segs; s++) {
      let sx = left + Math.floor(s * segW) + Math.floor(segW * 0.35)
      ctx.fillRect(sx, y - tankW / 2 + 4, Math.max(1, Math.floor(segW * 0.15)), treadW - 8)
      ctx.fillRect(sx, y + tankW / 2 - treadW + 4, Math.max(1, Math.floor(segW * 0.15)), treadW - 8)
    }

    ctx.fillStyle = bodyColor
    ctx.fillRect(left + 1, y - bodyW / 2, tankH - 2, bodyW)

    ctx.strokeStyle = detailColor
    ctx.lineWidth = 1
    ctx.beginPath()
    ctx.moveTo(left + tankH * 0.35, y - bodyW / 2 + 2)
    ctx.lineTo(left + tankH * 0.35, y + bodyW / 2 - 2)
    ctx.stroke()
    ctx.beginPath()
    ctx.moveTo(left + tankH * 0.6, y - bodyW / 2 + 2)
    ctx.lineTo(left + tankH * 0.6, y + bodyW / 2 - 2)
    ctx.stroke()

    let tcx = left + tankH * 0.2 + turretW / 2
    let tcy = y
    ctx.fillStyle = turretBase
    ctx.fillRect(tcx - turretW / 2, tcy - turretH / 2, turretW, turretH)
    ctx.strokeStyle = stripeColor
    ctx.lineWidth = Math.max(1, Math.floor(tileSize * 0.02))
    ctx.strokeRect(tcx - turretW / 2, tcy - turretH / 2, turretW, turretH)
    ctx.fillStyle = bodyColor
    ctx.fillRect(tcx, tcy - turretH / 2 - 1, 1, turretH)

    ctx.fillStyle = barrelColor
    if (direction === 2) {
      ctx.fillRect(tcx - turretW / 2 - bL, y - bW / 2, bL, bW)
    } else {
      ctx.fillRect(tcx + turretW / 2, y - bW / 2, bL, bW)
    }
  }
}

function drawMuzzleFlash(ctx: CanvasRenderingContext2D, x: number, y: number, direction: number, tileSize: number): void {
  let half = tileSize * 0.4
  let fx = x
  let fy = y
  let fw = Math.max(4, Math.floor(tileSize / 12))
  let fh = Math.max(8, Math.floor(tileSize / 5))
  if (direction === 0) {
    fy = y - half - fh
  } else if (direction === 1) {
    fy = y + half
  } else if (direction === 2) {
    fx = x - half - fh
    let temp = fw
    fw = fh
    fh = temp
  } else {
    fx = x + half
    let temp = fw
    fw = fh
    fh = temp
  }
  ctx.fillStyle = '#FFEB3B'
  ctx.globalAlpha = 0.8
  ctx.fillRect(fx - fw / 2, fy - fh / 2, fw, fh)
  ctx.globalAlpha = 1
}

function drawShield(ctx: CanvasRenderingContext2D, x: number, y: number, tileSize: number): void {
  ctx.strokeStyle = COLOR_SHIELD
  ctx.lineWidth = 2
  ctx.globalAlpha = 0.5
  let r = tileSize * 0.5
  ctx.beginPath()
  ctx.arc(x, y, r, 0, Math.PI * 2)
  ctx.stroke()
  ctx.globalAlpha = 1
}

function drawExplosion(ctx: CanvasRenderingContext2D, x: number, y: number, frame: number, tileSize: number): void {
  let colors: string[] = [COLOR_EXPLOSION_1, COLOR_EXPLOSION_2, COLOR_EXPLOSION_3, COLOR_EXPLOSION_4]
  let size = (frame + 1) * tileSize * 0.3
  ctx.fillStyle = colors[frame]
  ctx.globalAlpha = 1 - frame * 0.2
  ctx.beginPath()
  ctx.arc(x, y, size, 0, Math.PI * 2)
  ctx.fill()
  ctx.globalAlpha = 1
}

function drawSpawnAnimation(ctx: CanvasRenderingContext2D, x: number, y: number, frame: number, tileSize: number): void {
  if (frame < 0 || frame > 60) {
    return
  }
  let size = (frame / 60) * tileSize * 0.4
  ctx.strokeStyle = '#4FC3F7'
  ctx.lineWidth = 2
  ctx.globalAlpha = 1 - frame / 60
  ctx.beginPath()
  ctx.arc(x, y, size, 0, Math.PI * 2)
  ctx.stroke()
  ctx.globalAlpha = 1
}

function drawGrenadeShape(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
  let bodyR = r * 0.65
  let fuseW = r * 0.18
  let fuseH = r * 0.45
  ctx.fillStyle = '#1A0A0A'
  ctx.beginPath()
  ctx.arc(cx, cy, bodyR, 0, Math.PI * 2)
  ctx.fill()
  ctx.strokeStyle = '#FF5722'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.arc(cx, cy, bodyR, 0, Math.PI * 2)
  ctx.stroke()
  ctx.fillStyle = '#FF7043'
  ctx.fillRect(cx - fuseW / 2, cy - bodyR - fuseH, fuseW, fuseH)
  ctx.fillRect(cx - r * 0.55, cy - r * 0.2, r * 1.1, r * 0.06)
  ctx.fillRect(cx - r * 0.06, cy - r * 0.55, r * 0.06, r * 1.1)
  ctx.strokeStyle = '#FFAB91'
  ctx.lineWidth = 1
  ctx.beginPath()
  ctx.moveTo(cx - r * 0.12, cy - bodyR - fuseH - r * 0.1)
  ctx.lineTo(cx - r * 0.22, cy - bodyR - fuseH - r * 0.2)
  ctx.moveTo(cx, cy - bodyR - fuseH - r * 0.1)
  ctx.lineTo(cx, cy - bodyR - fuseH - r * 0.2)
  ctx.moveTo(cx + r * 0.12, cy - bodyR - fuseH - r * 0.1)
  ctx.lineTo(cx + r * 0.22, cy - bodyR - fuseH - r * 0.2)
  ctx.stroke()
}

function drawHelmetShape(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
  ctx.beginPath()
  ctx.moveTo(cx - r * 0.75, cy - r * 0.5)
  ctx.quadraticCurveTo(cx - r * 0.75, cy - r * 0.9, cx, cy - r * 0.9)
  ctx.quadraticCurveTo(cx + r * 0.75, cy - r * 0.9, cx + r * 0.75, cy - r * 0.5)
  ctx.lineTo(cx + r * 0.55, cy - r * 0.2)
  ctx.lineTo(cx + r * 0.5, cy + r * 0.7)
  ctx.lineTo(cx - r * 0.5, cy + r * 0.7)
  ctx.lineTo(cx - r * 0.55, cy - r * 0.2)
  ctx.closePath()
  ctx.fillStyle = '#0D2028'
  ctx.fill()
  ctx.strokeStyle = '#00E5FF'
  ctx.lineWidth = 1.5
  ctx.stroke()
  ctx.fillStyle = '#00E5FF'
  ctx.font = 'bold ' + Math.max(8, Math.floor(r * 0.5)) + 'px sans-serif'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText('S', cx, cy + r * 0.05)
}

function drawClockShape(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
  let faceR = r * 0.75
  ctx.fillStyle = '#E0E0E0'
  ctx.beginPath()
  ctx.arc(cx, cy, faceR, 0, Math.PI * 2)
  ctx.fill()
  ctx.strokeStyle = '#78909C'
  ctx.lineWidth = 2
  ctx.stroke()
  let tickLen = faceR * 0.2
  ctx.strokeStyle = '#546E7A'
  ctx.lineWidth = 2
  for (let i = 0; i < 4; i++) {
    let angle = -Math.PI / 2 + i * Math.PI / 2
    let x1 = cx + (faceR - tickLen) * Math.cos(angle)
    let y1 = cy + (faceR - tickLen) * Math.sin(angle)
    let x2 = cx + faceR * Math.cos(angle)
    let y2 = cy + faceR * Math.sin(angle)
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.stroke()
  }
  let smallTickLen = faceR * 0.1
  ctx.lineWidth = 1
  for (let i = 1; i < 12; i++) {
    if (i % 3 === 0) {
      continue
    }
    let angle = -Math.PI / 2 + i * Math.PI / 6
    let x1 = cx + (faceR - smallTickLen) * Math.cos(angle)
    let y1 = cy + (faceR - smallTickLen) * Math.sin(angle)
    let x2 = cx + faceR * Math.cos(angle)
    let y2 = cy + faceR * Math.sin(angle)
    ctx.beginPath()
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)
    ctx.stroke()
  }
  let hAngle = -Math.PI / 2 + Math.PI / 3
  let hLen = faceR * 0.45
  ctx.strokeStyle = '#37474F'
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.moveTo(cx, cy)
  ctx.lineTo(cx + hLen * Math.cos(hAngle), cy + hLen * Math.sin(hAngle))
  ctx.stroke()
  let mAngle = -Math.PI / 2 - Math.PI / 6
  let mLen = faceR * 0.6
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(cx, cy)
  ctx.lineTo(cx + mLen * Math.cos(mAngle), cy + mLen * Math.sin(mAngle))
  ctx.stroke()
  ctx.fillStyle = '#E53935'
  ctx.beginPath()
  ctx.arc(cx, cy, faceR * 0.08, 0, Math.PI * 2)
  ctx.fill()
}

function drawShovelShape(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
  let handleW = r * 0.15
  let handleH = r * 0.7
  ctx.fillStyle = '#3E2723'
  ctx.fillRect(cx - handleW / 2, cy - r * 0.5 - handleH, handleW, handleH)
  ctx.beginPath()
  ctx.moveTo(cx - r * 0.55, cy - r * 0.5)
  ctx.lineTo(cx - r * 0.35, cy + r * 0.15)
  ctx.quadraticCurveTo(cx, cy + r * 0.4, cx + r * 0.35, cy + r * 0.15)
  ctx.lineTo(cx + r * 0.55, cy - r * 0.5)
  ctx.quadraticCurveTo(cx, cy - r * 0.7, cx - r * 0.55, cy - r * 0.5)
  ctx.closePath()
  ctx.fillStyle = '#4E342E'
  ctx.fill()
  ctx.strokeStyle = '#FFD740'
  ctx.lineWidth = 2
  ctx.stroke()
}

function drawTankLifeShape(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number): void {
  let s = r * 0.7
  ctx.fillStyle = '#1A2510'
  ctx.beginPath()
  ctx.moveTo(cx, cy + s * 0.35)
  ctx.bezierCurveTo(cx - s * 1.4, cy - s * 0.4, cx - s * 0.9, cy - s, cx, cy - s * 0.3)
  ctx.bezierCurveTo(cx + s * 0.9, cy - s, cx + s * 1.4, cy - s * 0.4, cx, cy + s * 0.35)
  ctx.fill()
  ctx.strokeStyle = '#00FF41'
  ctx.lineWidth = 2
  ctx.beginPath()
  ctx.moveTo(cx, cy + s * 0.35)
  ctx.bezierCurveTo(cx - s * 1.4, cy - s * 0.4, cx - s * 0.9, cy - s, cx, cy - s * 0.3)
  ctx.bezierCurveTo(cx + s * 0.9, cy - s, cx + s * 1.4, cy - s * 0.4, cx, cy + s * 0.35)
  ctx.stroke()
  ctx.fillStyle = '#00FF41'
  ctx.font = 'bold ' + Math.max(8, Math.floor(r * 0.4)) + 'px sans-serif'
  ctx.textAlign = 'center'
  ctx.textBaseline = 'middle'
  ctx.fillText('+', cx, cy - r * 0.08)
}

function drawPowerUpIcon(ctx: CanvasRenderingContext2D, x: number, y: number, puType: number, tileSize: number): void {
  let cx = x * tileSize + tileSize / 2
  let cy = y * tileSize + tileSize / 2
  let r = tileSize * 0.3

  if (puType === 1) {
    drawGrenadeShape(ctx, cx, cy, r)
  } else if (puType === 2) {
    drawHelmetShape(ctx, cx, cy, r)
  } else if (puType === 3) {
    drawClockShape(ctx, cx, cy, r)
  } else if (puType === 4) {
    drawShovelShape(ctx, cx, cy, r)
  } else {
    drawTankLifeShape(ctx, cx, cy, r)
  }
}

export { drawBullet, drawTankSprite, drawMuzzleFlash, drawShield, drawExplosion, drawSpawnAnimation, drawPowerUpIcon }
