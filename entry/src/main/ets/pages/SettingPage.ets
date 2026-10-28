import router from '@ohos.router'
import { getAudioManager } from '../managers/AudioManager'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct SettingPage {
  @State bgmVol: number = 70
  @State sfxVol: number = 70
  @State showHeader: boolean = false
  @State showCard: boolean = false
  @State showSection1: boolean = false
  @State showSection2: boolean = false
  @State showSection3: boolean = false
  private ctx: common.UIAbilityContext | null = null

  aboutToAppear(): void {
    let ctx = getContext(this) as common.UIAbilityContext
    this.ctx = ctx
    getAudioManager().init(ctx)
    getAudioManager().playBGM('bgm_menu.wav')
    this.bgmVol = Math.floor(getAudioManager().getBgmVolume() * 100)
    this.sfxVol = Math.floor(getAudioManager().getSfxVolume() * 100)

    setTimeout(() => { this.showHeader = true }, 200)
    setTimeout(() => { this.showCard = true }, 500)
    setTimeout(() => { this.showSection1 = true }, 900)
    setTimeout(() => { this.showSection2 = true }, 1200)
    setTimeout(() => { this.showSection3 = true }, 1500)
  }

  onPageShow(): void {
    getAudioManager().playBGM('bgm_menu.wav')
  }

  @Builder sectionHeader(icon: string, title: string, accent: string, show: boolean) {
    Row() {
      Text(icon)
        .fontSize(14)
        .margin({ right: 8 })
      Text('══ ' + title + ' ══')
        .fontSize(15)
        .fontWeight(FontWeight.Bold)
        .fontColor(accent)
        .letterSpacing(2)
    }
    .margin({ top: 28, bottom: 12 })
    .width('100%')
    .opacity(show ? 1 : 0)
    .translate({ x: show ? 0 : 30 })
    .animation({ duration: 500, curve: Curve.FastOutSlowIn })
  }

  @Builder infoRow(label: string, value: string) {
    Row() {
      Text('  ' + label)
        .fontSize(13)
        .fontColor('#00E5FF')
        .fontWeight(FontWeight.Bold)
        .width(80)
      Text('::')
        .fontSize(12)
        .fontColor('#37474F')
        .margin({ left: 4, right: 8 })
      Text(value)
        .fontSize(13)
        .fontColor('#B0BEC5')
        .layoutWeight(1)
    }
    .width('100%')
    .margin({ top: 3, bottom: 3 })
  }

  @Builder settingCard() {
    Column() {
      Row() {
        Row()
          .width(2)
          .height(40)
          .backgroundColor('#00FF41')
        Column() {
          Text('BGM  VOLUME')
            .fontSize(11)
            .fontColor('#546E7A')
            .letterSpacing(3)
          Row() {
            Slider({
              value: this.bgmVol,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width('65%')
              .onChange((value: number) => {
                this.bgmVol = value
                getAudioManager().setBgmVolume(value / 100)
              })
            Text('[' + this.bgmVol.toString() + '%' + ']')
              .fontSize(13)
              .fontColor('#00FF41')
              .fontWeight(FontWeight.Bold)
              .width(56)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')

      Row() {
        Row()
          .width(2)
          .height(40)
          .backgroundColor('#00E5FF')
        Column() {
          Text('SFX  VOLUME')
            .fontSize(11)
            .fontColor('#546E7A')
            .letterSpacing(3)
          Row() {
            Slider({
              value: this.sfxVol,
              min: 0,
              max: 100,
              step: 1,
              style: SliderStyle.OutSet
            })
              .width('65%')
              .onChange((value: number) => {
                this.sfxVol = value
                getAudioManager().setSfxVolume(value / 100)
              })
            Text('[' + this.sfxVol.toString() + '%' + ']')
              .fontSize(13)
              .fontColor('#00E5FF')
              .fontWeight(FontWeight.Bold)
              .width(56)
              .textAlign(TextAlign.Center)
          }
          .width('100%')
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .width('100%')
    .backgroundColor('#0A1020')
    .border({
      width: { left: 1, right: 1, top: 1, bottom: 1 },
      color: '#1A2A3A'
    })
    .borderRadius(2)
    .padding(16)
    .opacity(this.showCard ? 1 : 0)
    .translate({ y: this.showCard ? 0 : 20 })
    .animation({ duration: 500, curve: Curve.FastOutSlowIn })
  }

  @Builder introText(text: string) {
    Text('>  ' + text)
      .fontSize(13)
      .fontColor('#90A4AE')
      .width('100%')
      .margin({ top: 2, bottom: 5 })
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
          .fontColor('#FF00FF')
          .opacity(this.showHeader ? 1 : 0)
          .animation({ duration: 400 })

        Text('  SETTINGS  ')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FF00FF')
          .letterSpacing(4)
          .opacity(this.showHeader ? 1 : 0)
          .translate({ y: this.showHeader ? 0 : -12 })
          .animation({ duration: 400, curve: Curve.FastOutSlowIn })

        Text('─┐')
          .fontSize(14)
          .fontColor('#FF00FF')
          .opacity(this.showHeader ? 1 : 0)
          .animation({ duration: 400 })
      }
      .width('100%')
      .padding({ left: 24, right: 24, top: 8, bottom: 16 })

      Scroll() {
        Column() {
          this.sectionHeader('█', 'ΛUDIO', '#00FF41', this.showCard)

          this.settingCard()

          this.sectionHeader('▓', 'RULES', '#00E5FF', this.showSection1)

          this.introText('消灭关卡中所有敌方坦克，保护下方的基地（鹰）')
          this.introText('基地被敌方子弹摧毁或玩家生命归零 → GΛME OVER')
          this.introText('每关 20 辆敌方坦克，初始 3 条生命')
          this.introText('每获得 20000 分，额外奖励 1 条生命')
          this.introText('通关全部 10 个关卡完成挑战')

          this.sectionHeader('◈', 'CONTROLS', '#FF00FF', this.showSection2)

          this.infoRow('移动 ↑', 'KEY_W / ↑')
          this.infoRow('移动 ↓', 'KEY_S / ↓')
          this.infoRow('移动 ←', 'KEY_A / ←')
          this.infoRow('移动 →', 'KEY_D / →')
          this.infoRow('开 火', 'KEY_J / SPACE')
          this.infoRow('暂 停', 'KEY_ESC')

          Text('>  TOUCH PANEL')
            .fontSize(13)
            .fontColor('#00E5FF')
            .fontWeight(FontWeight.Bold)
            .margin({ top: 10, bottom: 4 })

          this.introText('左侧虚拟方向键移动 · 右侧 A 按钮开火 · 下方暂停')

          this.sectionHeader('◆', 'POWER-UPS', '#FFD740', this.showSection3)

          this.infoRow('[  💣  ]', '手雷 · 全灭场上所有敌人')
          this.infoRow('[  🛡  ]', '头盔 · 10 秒无敌护盾')
          this.infoRow('[  ⏱  ]', '时钟 · 冻结敌人 8 秒')
          this.infoRow('[  🚧  ]', '铲子 · 基地加固 15 秒')
          this.infoRow('[  ❤️  ]', '坦克 · 额外生命 +1')

          Text('>  道具由红色闪烁道具坦克掉落或随机出现在地图上')
            .fontSize(12)
            .fontColor('#546E7A')
            .width('100%')
            .margin({ top: 12, bottom: 32 })
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

export default SettingPage
