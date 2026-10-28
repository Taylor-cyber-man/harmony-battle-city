import { GameState } from '../utils/Constants'

class GameStateManager {
  private currentState: GameState = GameState.MENU
  private previousState: GameState = GameState.MENU
  private pauseRequested: boolean = false
  private resumeRequested: boolean = false

  getState(): GameState {
    return this.currentState
  }

  getPreviousState(): GameState {
    return this.previousState
  }

  startGame(): void {
    if (this.currentState === GameState.MENU || this.currentState === GameState.GAME_OVER) {
      this.previousState = this.currentState
      this.currentState = GameState.LOADING
    }
  }

  onLoadComplete(): void {
    if (this.currentState === GameState.LOADING) {
      this.previousState = this.currentState
      this.currentState = GameState.RUNNING
    }
  }

  onPauseRequested(): void {
    this.pauseRequested = true
  }

  onResumeRequested(): void {
    this.resumeRequested = true
  }

  processPauseResume(): void {
    if (this.pauseRequested && this.currentState === GameState.RUNNING) {
      this.previousState = this.currentState
      this.currentState = GameState.PAUSED
      this.pauseRequested = false
    }
    if (this.resumeRequested && this.currentState === GameState.PAUSED) {
      this.previousState = this.currentState
      this.currentState = GameState.RUNNING
      this.resumeRequested = false
    }
  }

  onStageClear(): void {
    if (this.currentState === GameState.RUNNING) {
      this.previousState = this.currentState
      this.currentState = GameState.STAGE_TRANSITION
    }
  }

  onTransitionComplete(): void {
    if (this.currentState === GameState.STAGE_TRANSITION) {
      this.previousState = this.currentState
      this.currentState = GameState.LOADING
    }
  }

  onGameOver(): void {
    if (this.currentState === GameState.RUNNING || this.currentState === GameState.PAUSED) {
      this.previousState = this.currentState
      this.currentState = GameState.GAME_OVER
    }
  }

  returnToMenu(): void {
    if (this.currentState === GameState.GAME_OVER || this.currentState === GameState.PAUSED) {
      this.previousState = this.currentState
      this.currentState = GameState.MENU
    }
  }

  restartGame(): void {
    if (this.currentState === GameState.GAME_OVER) {
      this.previousState = this.currentState
      this.currentState = GameState.LOADING
    }
  }

  canUpdate(): boolean {
    return this.currentState === GameState.RUNNING
  }

  canRender(): boolean {
    return this.currentState !== GameState.MENU
  }

  isRunning(): boolean {
    return this.currentState === GameState.RUNNING
  }

  isPaused(): boolean {
    return this.currentState === GameState.PAUSED
  }

  isGameOver(): boolean {
    return this.currentState === GameState.GAME_OVER
  }

  isLoading(): boolean {
    return this.currentState === GameState.LOADING
  }

  isInMenu(): boolean {
    return this.currentState === GameState.MENU
  }

  isTransitioning(): boolean {
    return this.currentState === GameState.STAGE_TRANSITION
  }
}

let stateManager: GameStateManager = new GameStateManager()

function getStateManager(): GameStateManager {
  return stateManager
}

export { GameStateManager, getStateManager }
