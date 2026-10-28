let currentScore: number = 0
let highScore: number = 0
let lives: number = 3
let stageProgress: number = 0

function initScore(startLives: number): void {
  currentScore = 0
  lives = startLives
}

function addScore(points: number): void {
  currentScore += points
  let prevBonus = Math.floor((currentScore - points) / 20000)
  let nowBonus = Math.floor(currentScore / 20000)
  if (nowBonus > prevBonus) {
    lives += nowBonus - prevBonus
  }
}

function loseLife(): void {
  lives -= 1
}

function getLives(): number {
  return lives
}

function getScore(): number {
  return currentScore
}

function getHighScore(): number {
  return highScore
}

function setHighScore(s: number): void {
  if (s > highScore) {
    highScore = s
  }
}

function checkGameOver(): boolean {
  return lives <= 0
}

function setStageProgress(stage: number): void {
  stageProgress = stage
}

function getStageProgress(): number {
  return stageProgress
}

function getLivesDisplay(): number[] {
  let arr: number[] = []
  for (let i = 0; i < lives; i++) {
    arr[i] = 1
  }
  return arr
}

function addLife(): void {
  lives += 1
}

export {
  initScore, addScore, loseLife, addLife,
  getLives, getScore, getHighScore, setHighScore,
  checkGameOver, setStageProgress, getStageProgress,
  getLivesDisplay
}
