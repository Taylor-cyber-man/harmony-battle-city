import {
  TileType, COLOR_FIELD_BG, COLOR_GRID_LINE,
  COLOR_BRICK_MAIN, COLOR_BRICK_GAP, COLOR_BRICK_HIGHLIGHT,
  COLOR_STEEL_MAIN, COLOR_STEEL_RIVET, COLOR_STEEL_GROOVE,
  COLOR_TREES_OUTER, COLOR_TREES_INNER, COLOR_TREES_TRUNK,
  COLOR_WATER_MAIN, COLOR_WATER_RIPPLE,
  COLOR_ICE_MAIN, COLOR_ICE_CRACK
} from '../utils/Constants'

let tileSize: number = 80
let canvasSize: number = 1040
let mainCtx: CanvasRenderingContext2D | null = null

function init(ctx: CanvasRenderingContext2D, w: number, h: number, ts: number): void {
  mainCtx = ctx
  canvasSize = w
  tileSize = ts
}

function updateRenderSystem(ctx: CanvasRenderingContext2D, w: number, h: number, ts: number): void {
  mainCtx = ctx
  canvasSize = w
  tileSize = ts
}

function render(terrain: number[][], brickMasks: number[][]): void {
  if (mainCtx === null) {
    return
  }
  let ts = tileSize
  mainCtx.fillStyle = COLOR_FIELD_BG
  mainCtx.fillRect(0, 0, canvasSize, canvasSize)

  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      let tileType = terrain[y][x]
      let px = x * ts
      let py = y * ts
      if (tileType === TileType.BRICK) {
        drawBrick(mainCtx, px, py, ts)
      } else if (tileType === TileType.STEEL) {
        drawSteel(mainCtx, px, py, ts)
      } else if (tileType === TileType.WATER) {
        drawWater(mainCtx, px, py, ts)
      } else if (tileType === TileType.ICE) {
        drawIce(mainCtx, px, py, ts)
      }
    }
  }
}

function renderTrees(terrain: number[][]): void {
  if (mainCtx === null) {
    return
  }
  let ts = tileSize
  for (let y = 0; y < 16; y++) {
    for (let x = 0; x < 16; x++) {
      if (terrain[y][x] === TileType.TREES) {
        drawTrees(mainCtx, x * ts, y * ts, ts)
      }
    }
  }
}

function drawBrick(ctx: CanvasRenderingContext2D, x: number, y: number, ts: number): void {
  ctx.fillStyle = COLOR_BRICK_MAIN
  ctx.fillRect(x, y, ts, ts)

  let hs = Math.floor(ts / 2)
  let border = Math.floor(ts * 0.04)

  ctx.strokeStyle = COLOR_BRICK_GAP
  ctx.lineWidth = Math.max(1, Math.floor(ts * 0.03))
  ctx.strokeRect(x + border, y + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + hs + border, y + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + border, y + hs + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + hs + border, y + hs + border, hs - border * 2, hs - border * 2)

  ctx.fillStyle = COLOR_BRICK_HIGHLIGHT
  let d = Math.floor(ts * 0.06)
  ctx.fillRect(x + hs - d, y + hs - d, d * 2, d * 2)
}

function drawPartialBrick(ctx: CanvasRenderingContext2D, x: number, y: number, mask: number, ts: number): void {
  let hs = Math.floor(ts / 2)
  ctx.fillStyle = COLOR_FIELD_BG
  ctx.fillRect(x, y, ts, ts)
  let quads: number[][] = [[0, 0], [hs, 0], [0, hs], [hs, hs]]
  let border = Math.floor(ts * 0.04)
  for (let i = 0; i < 4; i++) {
    if ((mask & (1 << i)) !== 0) {
      let qx = x + quads[i][0]
      let qy = y + quads[i][1]
      ctx.fillStyle = COLOR_BRICK_MAIN
      ctx.fillRect(qx, qy, hs, hs)
      ctx.strokeStyle = COLOR_BRICK_GAP
      ctx.lineWidth = Math.max(1, Math.floor(ts * 0.03))
      ctx.strokeRect(qx + border, qy + border, hs - border * 2, hs - border * 2)
    }
  }
}

function drawSteel(ctx: CanvasRenderingContext2D, x: number, y: number, ts: number): void {
  ctx.fillStyle = COLOR_STEEL_MAIN
  ctx.fillRect(x, y, ts, ts)

  let border = Math.floor(ts * 0.04)
  let hs = Math.floor(ts / 2)
  let rivet = Math.max(2, Math.floor(ts * 0.06))

  ctx.strokeStyle = COLOR_STEEL_GROOVE
  ctx.lineWidth = Math.max(1, Math.floor(ts * 0.03))
  ctx.strokeRect(x + border, y + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + hs + border, y + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + border, y + hs + border, hs - border * 2, hs - border * 2)
  ctx.strokeRect(x + hs + border, y + hs + border, hs - border * 2, hs - border * 2)

  ctx.fillStyle = COLOR_STEEL_RIVET
  ctx.fillRect(x + hs - rivet, y + hs - rivet, rivet * 2, rivet * 2)
  ctx.fillRect(x + hs - rivet, y - rivet + border * 2, rivet, rivet)
  ctx.fillRect(x + ts - rivet - border, y + hs - rivet, rivet, rivet)
  ctx.fillRect(x + hs - rivet, y + ts - rivet - border, rivet, rivet)
  ctx.fillRect(x + border, y + hs - rivet, rivet, rivet)
}

function drawWater(ctx: CanvasRenderingContext2D, x: number, y: number, ts: number): void {
  ctx.fillStyle = COLOR_WATER_MAIN
  ctx.fillRect(x, y, ts, ts)

  ctx.strokeStyle = COLOR_WATER_RIPPLE
  ctx.lineWidth = 1
  let step = Math.floor(ts / 5)
  for (let r = 0; r < 3; r++) {
    let ry = y + Math.floor(ts * 0.2) + r * step
    ctx.beginPath()
    ctx.moveTo(x + 2, ry)
    ctx.lineTo(x + ts - 2, ry)
    ctx.stroke()
  }

  ctx.setLineDash([Math.floor(ts * 0.15), Math.floor(ts * 0.1)])
  ctx.beginPath()
  ctx.moveTo(x + Math.floor(ts * 0.1), y + Math.floor(ts * 0.2))
  ctx.lineTo(x + Math.floor(ts * 0.85), y + Math.floor(ts * 0.8))
  ctx.stroke()
  ctx.setLineDash([])
}

function drawIce(ctx: CanvasRenderingContext2D, x: number, y: number, ts: number): void {
  ctx.fillStyle = COLOR_ICE_MAIN
  ctx.fillRect(x, y, ts, ts)

  ctx.strokeStyle = COLOR_ICE_CRACK
  ctx.lineWidth = Math.max(1, Math.floor(ts * 0.025))
  let w4 = Math.floor(ts / 4)
  ctx.beginPath()
  ctx.moveTo(x + w4, y + 2)
  ctx.lineTo(x + w4, y + w4)
  ctx.lineTo(x + w4 * 2, y + w4 * 2)
  ctx.lineTo(x + w4 * 2, y + ts - 2)
  ctx.moveTo(x + w4 * 3, y + 2)
  ctx.lineTo(x + w4 * 3, y + w4)
  ctx.lineTo(x + w4 * 2, y + w4 * 2)
  ctx.stroke()
}

function drawTrees(ctx: CanvasRenderingContext2D, x: number, y: number, ts: number): void {
  ctx.fillStyle = COLOR_TREES_OUTER
  ctx.fillRect(x, y, ts, ts)

  let tw = Math.max(3, Math.floor(ts / 10))
  let th = Math.floor(ts / 4)
  ctx.fillStyle = COLOR_TREES_TRUNK
  ctx.fillRect(x + Math.floor(ts * 0.3) - tw, y + ts - th, tw, th)
  ctx.fillRect(x + Math.floor(ts * 0.7) - tw, y + ts - th, tw, th)

  let fw = Math.floor(ts * 0.3)
  let fh = ts - Math.floor(ts * 0.2)
  ctx.fillStyle = COLOR_TREES_INNER
  ctx.fillRect(x + Math.floor(ts * 0.12), y + 2, fw, fh)
  ctx.fillRect(x + Math.floor(ts * 0.55), y + 2, fw, fh)

  ctx.fillStyle = COLOR_TREES_TRUNK
  ctx.fillRect(x + Math.floor(ts * 0.14), y + 3, Math.floor(ts * 0.26), fh - 2)
  ctx.fillRect(x + Math.floor(ts * 0.57), y + 3, Math.floor(ts * 0.26), fh - 2)

  ctx.strokeStyle = COLOR_TREES_INNER
  ctx.lineWidth = 1
  let step = Math.floor(ts / 6)
  for (let r = y + step; r < y + ts - th; r += step) {
    ctx.beginPath()
    ctx.moveTo(x + 3, r)
    ctx.lineTo(x + ts - 3, r)
    ctx.stroke()
  }
}

export {
  init,
  updateRenderSystem,
  render,
  renderTrees
}
