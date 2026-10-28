function checkAABB(
  ax: number, ay: number, aw: number, ah: number,
  bx: number, by: number, bw: number, bh: number
): boolean {
  return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by
}

function snapToGrid(value: number, grid: number): number {
  return Math.round(value / grid) * grid
}

function randomInt(max: number): number {
  return Math.floor(Math.random() * max)
}

function randomRange(min: number, max: number): number {
  return Math.floor(Math.random() * (max - min)) + min
}

function distance(x1: number, y1: number, x2: number, y2: number): number {
  let dx = x2 - x1
  let dy = y2 - y1
  return Math.sqrt(dx * dx + dy * dy)
}

function normalizeAngle(angle: number): number {
  while (angle < 0) {
    angle += 360
  }
  return angle % 360
}

export { checkAABB, snapToGrid, randomInt, randomRange, distance, normalizeAngle }
