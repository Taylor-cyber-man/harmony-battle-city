import {
  COLOR_EAGLE_BODY, COLOR_EAGLE_WING, COLOR_EAGLE_EYE,
  EAGLE_POS_X, EAGLE_POS_Y
} from '../utils/Constants'

function drawEagle(ctx: CanvasRenderingContext2D, tileSize: number): void {
  let cx = EAGLE_POS_X * tileSize
  let cy = EAGLE_POS_Y * tileSize
  let w = tileSize * 2
  let h = tileSize * 2

  ctx.fillStyle = '#0A1020'
  ctx.fillRect(cx, cy, w, h)

  ctx.strokeStyle = COLOR_EAGLE_BODY
  ctx.lineWidth = 2
  ctx.strokeRect(cx + 2, cy + 2, w - 4, h - 4)

  ctx.strokeStyle = COLOR_EAGLE_WING
  ctx.lineWidth = 1
  ctx.setLineDash([Math.floor(tileSize * 0.12), Math.floor(tileSize * 0.06)])
  ctx.strokeRect(cx + 6, cy + 6, w - 12, h - 12)
  ctx.setLineDash([])

  let midX = cx + w / 2
  let midY = cy + h / 2
  let ds = Math.floor(tileSize * 0.55)

  ctx.strokeStyle = COLOR_EAGLE_BODY
  ctx.lineWidth = 3
  ctx.beginPath()
  ctx.moveTo(midX, midY - ds)
  ctx.lineTo(midX + ds * 0.7, midY)
  ctx.lineTo(midX, midY + ds * 0.7)
  ctx.lineTo(midX - ds * 0.7, midY)
  ctx.closePath()
  ctx.stroke()

  ctx.fillStyle = COLOR_EAGLE_BODY
  ctx.beginPath()
  ctx.moveTo(midX, midY - ds * 0.6)
  ctx.lineTo(midX + ds * 0.45, midY)
  ctx.lineTo(midX, midY + ds * 0.45)
  ctx.lineTo(midX - ds * 0.45, midY)
  ctx.closePath()
  ctx.fill()

  ctx.fillStyle = COLOR_EAGLE_EYE
  ctx.beginPath()
  ctx.arc(midX, midY, Math.floor(tileSize * 0.12), 0, Math.PI * 2)
  ctx.fill()

  ctx.strokeStyle = COLOR_EAGLE_BODY
  ctx.lineWidth = 1
  let dotR = Math.max(2, Math.floor(tileSize * 0.05))
  ctx.beginPath()
  ctx.arc(cx + w * 0.1, cy + h * 0.1, dotR, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.arc(cx + w * 0.9, cy + h * 0.1, dotR, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.arc(cx + w * 0.1, cy + h * 0.9, dotR, 0, Math.PI * 2)
  ctx.fill()
  ctx.beginPath()
  ctx.arc(cx + w * 0.9, cy + h * 0.9, dotR, 0, Math.PI * 2)
  ctx.fill()

  let antW = Math.max(2, Math.floor(tileSize * 0.06))
  let antH = Math.max(3, Math.floor(tileSize * 0.12))
  ctx.fillStyle = COLOR_EAGLE_WING
  ctx.fillRect(midX - antW / 2, midY - ds - antH * 2, antW, antH)
  ctx.fillRect(midX - antW / 2, midY - ds - antH * 3.5, Math.floor(antW * 0.6), Math.floor(antH * 1.5))
}

export { drawEagle }
