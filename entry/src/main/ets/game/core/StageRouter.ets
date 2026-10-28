let pendingStage: number = 0

function setPendingStage(stage: number): void {
  pendingStage = stage
}

function getPendingStage(): number {
  let s = pendingStage
  pendingStage = 0
  return s
}

export { setPendingStage, getPendingStage }
