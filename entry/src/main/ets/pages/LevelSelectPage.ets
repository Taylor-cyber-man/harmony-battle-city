import router from '@ohos.router'
import { getAudioManager } from '../managers/AudioManager'
import { common } from '@kit.AbilityKit'
import { setPendingStage } from '../game/core/StageRouter'

@Entry
@Component
struct LevelSelectPage {
  @State stages: number[] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
  @State showHeader: boolean = false
  @State cardPhase: number = 0

  aboutToAppear(): void {
    let ctx = getContext(this) as common.UIAbilityContext
    getAudioManager().init(ctx)
    getAudioManager().playBGM('bgm_menu.wav')

    setTimeout(() => { this.showHeader = true }, 200)
    for (let i = 1; i <= 10; i++) {
      setTimeout(() => { this.cardPhase = i }, 350 + i * 60)
    }
  }

  onPageShow(): void {
    getAudioManager().playBGM('bgm_menu.wav')
  }

  getStageAccent(stage: number): string {
    let colors: string[] = [
      '#00FF41', '#00E5FF', '#FF00FF', '#FF5722', '#FFD740',
      '#69F0AE', '#40C4FF', '#FF5252', '#00BFA5', '#FF9100'
    ]
    return colors[stage - 1]
  }

  formatStage(num: number): string {
    if (num < 10) {
      return '0' + num.toString()
    }
    return num.toString()
  }

  @Builder stageCard(stage: number) {
    Column() {
      Row() {
        Text('█')
          .fontSize(6)
          .fontColor(this.getStageAccent(stage))
          .margin({ right: 6 })
        Text('[  STΛGE  ' + this.formatStage(stage) + '  ]')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getStageAccent(stage))
          .letterSpacing(3)
        Text('█')
          .fontSize(6)
          .fontColor(this.getStageAccent(stage))
          .margin({ left: 6 })
      }
      .width('100%')
      .height(52)
      .justifyContent(FlexAlign.Center)

      Row()
        .width('90%')
        .height(1)
        .backgroundColor(this.getStageAccent(stage))
        .opacity(0.3)
    }
    .width('100%')
    .backgroundColor('#0A1020')
    .border({
      width: { left: 1, right: 1, top: 1, bottom: 1 },
      color: this.getStageAccent(stage)
    })
    .borderRadius(2)
    .margin({ bottom: 10 })
    .padding({ top: 4, bottom: 4 })
    .opacity(this.cardPhase >= stage ? 0.75 : 0)
    .translate({ x: this.cardPhase >= stage ? 0 : 60 })
    .animation({ duration: 400, curve: Curve.FastOutSlowIn })
    .onClick(() => {
      setPendingStage(stage - 1)
      try {
        router.pushUrl({ url: 'pages/GamePage' })
      } catch (e) {
      }
    })
  }

  build() {
    Column() {
      Row() {
        Text('←  BΛCK')
          .fontSize(14)
          .fontColor('#546E7A')
          .letterSpacing(3)
          .opacity(this.showHeader ? 1 : 0)
          .translate({ y: this.showHeader ? 0 : -12 })
          .animation({ duration: 400, curve: Curve.FastOutSlowIn })
          .onClick(() => {
            try { router.back() } catch (e) {}
          })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 12, bottom: 6 })

      Row() {
        Text('┌─')
          .fontSize(14)
          .fontColor('#00FF41')
          .opacity(this.showHeader ? 1 : 0)
          .animation({ duration: 400 })

        Text('  SELECT  STΛGE  ')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#00FF41')
          .letterSpacing(4)
          .opacity(this.showHeader ? 1 : 0)
          .translate({ y: this.showHeader ? 0 : -12 })
          .animation({ duration: 400, curve: Curve.FastOutSlowIn })

        Text('─┐')
          .fontSize(14)
          .fontColor('#00FF41')
          .opacity(this.showHeader ? 1 : 0)
          .animation({ duration: 400 })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 8, bottom: 16 })

      Scroll() {
        Column() {
          ForEach(this.stages, (stage: number) => {
            this.stageCard(stage)
          })
        }
        .width('100%')
        .padding({ left: 28, right: 28, top: 4 })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Auto)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#050B14')
  }
}

export default LevelSelectPage
