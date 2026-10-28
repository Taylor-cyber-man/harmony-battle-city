let lastTime: number = 0
let timerId: number = -1
let onTick: ((dt: number) => void) | null = null
let isRunning: boolean = false

function start(callback: (dt: number) => void): void {
  if (isRunning) {
    return
  }
  onTick = callback
  isRunning = true
  lastTime = Date.now()
  timerId = setInterval(() => {
    let now = Date.now()
    let dt = (now - lastTime) / 1000
    lastTime = now
    if (dt > 0.1) {
      dt = 0.1
    }
    if (onTick !== null) {
      onTick(dt)
    }
  }, 16)
}

function stop(): void {
  if (!isRunning) {
    return
  }
  isRunning = false
  if (timerId !== -1) {
    clearInterval(timerId)
    timerId = -1
  }
  onTick = null
}

function getIsRunning(): boolean {
  return isRunning
}

function getFPS(): number {
  if (lastTime === 0) {
    return 0
  }
  return Math.round(1000 / 16)
}

export default { start, stop, getIsRunning, getFPS }
