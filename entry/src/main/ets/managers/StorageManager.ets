import { preferences } from '@kit.ArkData'

class StorageManager {
  private prefs: preferences.Preferences | null = null

  async init(context: Context): Promise<void> {
    try {
      this.prefs = preferences.getPreferencesSync(context, { name: 'battle_city_data' })
    } catch (e) {
    }
  }

  getStageProgress(): number {
    if (this.prefs === null) {
      return 0
    }
    try {
      return this.prefs.getSync('stage_progress', 0) as number
    } catch (e) {
      return 0
    }
  }

  saveStageProgress(progress: number): void {
    if (this.prefs === null) {
      return
    }
    try {
      this.prefs.putSync('stage_progress', progress)
      this.prefs.flush()
    } catch (e) {
    }
  }

  getHighScore(): number {
    if (this.prefs === null) {
      return 0
    }
    try {
      return this.prefs.getSync('high_score', 0) as number
    } catch (e) {
      return 0
    }
  }

  saveScore(score: number): void {
    let current = this.getHighScore()
    if (score > current) {
      if (this.prefs !== null) {
        try {
          this.prefs.putSync('high_score', score)
          this.prefs.flush()
        } catch (e) {
        }
      }
    }
  }
}

let storageMgr: StorageManager = new StorageManager()

function getStorage(): StorageManager {
  return storageMgr
}

export { StorageManager, getStorage }
