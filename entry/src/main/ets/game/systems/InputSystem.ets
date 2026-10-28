import { DPadKey, KEYCODE_W, KEYCODE_A, KEYCODE_S, KEYCODE_D, KEYCODE_SPACE } from '../utils/Constants'
import { setInputDirection, requestFire } from '../core/GameEngine'

let dPadKeys: Set<number> = new Set()
let pressedKeys: Set<number> = new Set()

function onDPadDown(key: DPadKey): void {
  dPadKeys.add(key)
  updateDirection()
}

function onDPadUp(key: DPadKey): void {
  dPadKeys.delete(key)
  updateDirection()
}

function onKeyDown(keyCode: number): void {
  pressedKeys.add(keyCode)
  updateDirection()
  if (keyCode === KEYCODE_SPACE) {
    requestFire()
  }
}

function onKeyUp(keyCode: number): void {
  pressedKeys.delete(keyCode)
  updateDirection()
}

function updateDirection(): void {
  if (pressedKeys.size > 0) {
    applyKeysToDirection(pressedKeys)
    return
  }
  applyKeysToDirection(dPadKeys)
}

function applyKeysToDirection(keys: Set<number>): void {
  let dx = 0
  let dy = 0
  if (keys.has(DPadKey.UP) || keys.has(KEYCODE_W)) {
    dy -= 1
  }
  if (keys.has(DPadKey.DOWN) || keys.has(KEYCODE_S)) {
    dy += 1
  }
  if (keys.has(DPadKey.LEFT) || keys.has(KEYCODE_A)) {
    dx -= 1
  }
  if (keys.has(DPadKey.RIGHT) || keys.has(KEYCODE_D)) {
    dx += 1
  }
  setInputDirection(dx, dy)
}

function onFireButtonDown(): void {
  requestFire()
}

function onFireButtonUp(): void {
}

function clearAllInputs(): void {
  dPadKeys.clear()
  pressedKeys.clear()
  setInputDirection(0, 0)
}

export {
  onDPadDown, onDPadUp, onKeyDown, onKeyUp,
  onFireButtonDown, onFireButtonUp, clearAllInputs
}
