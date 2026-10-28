import media from '@ohos.multimedia.media'
import audio from '@ohos.multimedia.audio'
import { hilog } from '@kit.PerformanceAnalysisKit'

const TAG = 'AudioMgr'

class AudioManager {
  private soundPool: media.SoundPool | null = null
  private sfxIds: Map<string, number> = new Map()
  private bgmIds: Map<string, number> = new Map()
  private soundIdToBgm: Map<number, string> = new Map()
  private loadedBgmSoundIds: Set<number> = new Set()
  private racePendingLoads: Set<number> = new Set()
  private bgmStreamId: number = 0
  private bgmPlayId: number = 0
  private pendingBGM: string = ''
  private sfxVolume: number = 0.7
  private bgmVolume: number = 0.7
  private context: Context | null = null
  private initialized: boolean = false

  init(context: Context): void {
    if (this.initialized) {
      hilog.info(0x0000, TAG, 'init: already initialized, skip')
      return
    }
    hilog.info(0x0000, TAG, 'init: starting...')
    this.context = context
    let rm = context.resourceManager

    let audioRendererInfo: audio.AudioRendererInfo = {
      usage: audio.StreamUsage.STREAM_USAGE_MEDIA,
      rendererFlags: 0
    }

    let sfxFiles: string[] = [
      'sfx_fire.wav', 'sfx_explosion.wav', 'sfx_powerup.wav',
      'sfx_stageclear.wav', 'sfx_gameover.wav'
    ]
    let bgmFiles: string[] = ['bgm_battle.wav', 'bgm_menu.wav']

    hilog.info(0x0000, TAG, 'init: calling createSoundPool...')
    media.createSoundPool(6, audioRendererInfo).then((pool: media.SoundPool) => {
      hilog.info(0x0000, TAG, 'createSoundPool OK')
      this.soundPool = pool

      pool.on('error', (err: Error) => {
        hilog.error(0x0000, TAG, 'SoundPool error: ' + JSON.stringify(err))
      })

      pool.on('playFinishedWithStreamId', (streamId: number) => {
        if (streamId === this.bgmStreamId && this.bgmStreamId > 0 && this.bgmPlayId > 0) {
          hilog.info(0x0000, TAG, 'BGM finished, restarting...')
          this.restartBGM()
        }
      })

      pool.on('loadComplete', (soundId: number) => {
        hilog.info(0x0000, TAG, 'loadComplete: soundId=' + soundId.toString())
        let name = this.soundIdToBgm.get(soundId)
        if (name === undefined) {
          hilog.info(0x0000, TAG, 'loadComplete: soundId ' + soundId.toString() + ' not yet mapped, queuing')
          this.racePendingLoads.add(soundId)
          return
        }
        hilog.info(0x0000, TAG, 'loadComplete: BGM ' + name + ' id=' + soundId.toString())
        this.loadedBgmSoundIds.add(soundId)
        this.tryPendingBGM()
      })

      for (let i = 0; i < sfxFiles.length; i++) {
        let fileName = sfxFiles[i]
        try {
          let rawFd = rm.getRawFdSync(fileName)
          pool.load(rawFd.fd, rawFd.offset, rawFd.length).then((soundId: number) => {
            this.sfxIds.set(fileName, soundId)
          }).catch(() => {
          })
        } catch (e) {
        }
      }
      for (let i = 0; i < bgmFiles.length; i++) {
        let fileName = bgmFiles[i]
        try {
          let rawFd = rm.getRawFdSync(fileName)
          pool.load(rawFd.fd, rawFd.offset, rawFd.length).then((soundId: number) => {
            hilog.info(0x0000, TAG, 'BGM load promise: ' + fileName + ' id=' + soundId.toString())
            this.bgmIds.set(fileName, soundId)
            this.soundIdToBgm.set(soundId, fileName)
            if (this.racePendingLoads.has(soundId)) {
              hilog.info(0x0000, TAG, 'race resolved: ' + fileName + ' id=' + soundId.toString())
              this.racePendingLoads.delete(soundId)
              this.loadedBgmSoundIds.add(soundId)
              this.tryPendingBGM()
            }
          }).catch(() => {
          })
        } catch (e) {
        }
      }
    }).catch(() => {
    })

    this.initialized = true
    hilog.info(0x0000, TAG, 'init: done (async pending)')
  }

  private tryPendingBGM(): void {
    let pending = this.pendingBGM
    if (pending === '') {
      return
    }
    let soundId = this.bgmIds.get(pending)
    if (soundId === undefined || this.soundPool === null) {
      return
    }
    if (!this.loadedBgmSoundIds.has(soundId)) {
      hilog.info(0x0000, TAG, 'tryPendingBGM: ' + pending + ' not loadComplete yet, waiting')
      return
    }
    hilog.info(0x0000, TAG, 'tryPendingBGM: playing ' + pending + ' id=' + soundId.toString())
    this.pendingBGM = ''
    this.bgmStreamId = 0
    this.bgmPlayId = 0
    let params: media.PlayParameters = {
      loop: 0,
      rate: 0,
      leftVolume: this.bgmVolume,
      rightVolume: this.bgmVolume,
      priority: 0
    }
    this.bgmPlayId = soundId
    this.soundPool.play(soundId, params).then((streamId: number) => {
      hilog.info(0x0000, TAG, 'tryPendingBGM: play OK streamId=' + streamId.toString())
      this.bgmStreamId = streamId
    }).catch((err: Error) => {
      hilog.error(0x0000, TAG, 'tryPendingBGM: play FAIL ' + JSON.stringify(err))
    })
  }

  private restartBGM(): void {
    let pool = this.soundPool
    if (pool === null || this.bgmPlayId <= 0) {
      return
    }
    let params: media.PlayParameters = {
      loop: 0,
      rate: 0,
      leftVolume: this.bgmVolume,
      rightVolume: this.bgmVolume,
      priority: 0
    }
    pool.play(this.bgmPlayId, params).then((streamId: number) => {
      this.bgmStreamId = streamId
    }).catch(() => {
    })
  }

  setSfxVolume(vol: number): void {
    this.sfxVolume = Math.max(0, Math.min(1, vol))
  }

  setBgmVolume(vol: number): void {
    this.bgmVolume = Math.max(0, Math.min(1, vol))
    if (this.bgmStreamId > 0 && this.soundPool !== null) {
      try {
        this.soundPool.setVolume(this.bgmStreamId, this.bgmVolume, this.bgmVolume)
      } catch (e) {
      }
    }
  }

  getSfxVolume(): number {
    return this.sfxVolume
  }

  getBgmVolume(): number {
    return this.bgmVolume
  }

  playSfx(fileName: string): void {
    if (this.soundPool === null) {
      return
    }
    let soundId = this.sfxIds.get(fileName)
    if (soundId === undefined) {
      return
    }
    let params: media.PlayParameters = {
      loop: 0,
      rate: 0,
      leftVolume: this.sfxVolume,
      rightVolume: this.sfxVolume,
      priority: 0
    }
    try {
      this.soundPool.play(soundId, params)
    } catch (e) {
    }
  }

  playBGM(fileName: string): void {
    hilog.info(0x0000, TAG, 'playBGM: request ' + fileName + ' pool=' + (this.soundPool !== null))
    if (this.soundPool === null || this.bgmIds.get(fileName) === undefined) {
      hilog.info(0x0000, TAG, 'playBGM: deferred to pendingBGM=' + fileName)
      this.pendingBGM = fileName
      return
    }
    let soundId = this.bgmIds.get(fileName)
    if (soundId === undefined) {
      return
    }
    if (!this.loadedBgmSoundIds.has(soundId)) {
      hilog.info(0x0000, TAG, 'playBGM: ' + fileName + ' not loadComplete, deferred')
      this.pendingBGM = fileName
      return
    }
    if (this.bgmPlayId === soundId) {
      hilog.info(0x0000, TAG, 'playBGM: already playing ' + fileName)
      return
    }
    this.stopBGM()
    let params: media.PlayParameters = {
      loop: 0,
      rate: 0,
      leftVolume: this.bgmVolume,
      rightVolume: this.bgmVolume,
      priority: 0
    }
    this.bgmPlayId = soundId
    let pool = this.soundPool
    if (pool !== null) {
      pool.play(soundId, params).then((streamId: number) => {
        hilog.info(0x0000, TAG, 'playBGM: OK ' + fileName + ' streamId=' + streamId.toString())
        this.bgmStreamId = streamId
      }).catch((err: Error) => {
        hilog.error(0x0000, TAG, 'playBGM: FAIL ' + fileName + ' ' + JSON.stringify(err))
      })
    }
  }

  stopBGM(): void {
    if (this.bgmStreamId > 0 && this.soundPool !== null) {
      try {
        this.soundPool.stop(this.bgmStreamId)
      } catch (e) {
      }
    }
    this.bgmStreamId = 0
    this.bgmPlayId = 0
  }

  release(): void {
    this.stopBGM()
    this.pendingBGM = ''
    this.loadedBgmSoundIds.clear()
    this.racePendingLoads.clear()
    this.soundIdToBgm.clear()
    if (this.soundPool !== null) {
      try {
        this.soundPool.release()
      } catch (e) {
      }
      this.soundPool = null
    }
    this.sfxIds.clear()
    this.bgmIds.clear()
    this.initialized = false
    this.context = null
  }
}

let audioManager: AudioManager = new AudioManager()

function getAudioManager(): AudioManager {
  return audioManager
}

export { AudioManager, getAudioManager }
