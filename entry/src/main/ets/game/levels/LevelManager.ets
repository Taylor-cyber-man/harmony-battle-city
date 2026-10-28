import {
  EAGLE_POS_X, EAGLE_POS_Y, EAGLE_WALL_POSITIONS, TileType
} from '../utils/Constants'

interface LevelState {
  stageIndex: number
  terrain: number[][]
  enemySequence: number[]
  isEagleAlive: boolean
}

class LevelManager {
  private level: LevelState

  constructor() {
    this.level = {
      stageIndex: 0,
      terrain: [],
      enemySequence: [],
      isEagleAlive: true
    }
  }

  loadStage(stageIndex: number, terrain: number[][], enemySeq: number[]): void {
    this.level.stageIndex = stageIndex
    this.level.terrain = terrain
    this.level.enemySequence = enemySeq
    this.level.isEagleAlive = true
  }

  getTerrain(): number[][] {
    return this.level.terrain
  }

  getEnemySequence(): number[] {
    return this.level.enemySequence
  }

  getStageIndex(): number {
    return this.level.stageIndex
  }

  isEagleAlive(): boolean {
    return this.level.isEagleAlive
  }

  destroyEagle(): void {
    this.level.isEagleAlive = false
  }
}

let stageManager: LevelManager = new LevelManager()

function getStageManager(): LevelManager {
  return stageManager
}

export { LevelManager, getStageManager }
