import router from '@ohos.router'
import { getAudioManager } from '../managers/AudioManager'
import { common } from '@kit.AbilityKit'

@Entry
@Component
struct MainPage {
  @State showHeader: boolean = false
  @State showBattle: boolean = false
  @State showCity: boolean = false
  @State showSubtitle: boolean = false
  @State showBtn1: boolean = false
  @State showBtn2: boolean = false
  @State showBtn3: boolean = false
  @State showVersion: boolean = false

  aboutToAppear(): void {
    let ctx = getContext(this) as common.UIAbilityContext
    getAudioManager().init(ctx)
    getAudioManager().playBGM('bgm_menu.wav')

    setTimeout(() => { this.showHeader = true }, 300)
    setTimeout(() => { this.showBattle = true }, 600)
    setTimeout(() => { this.showCity = true }, 750)
    setTimeout(() => { this.showSubtitle = true }, 1400)
    setTimeout(() => { this.showBtn1 = true }, 1800)
    setTimeout(() => { this.showBtn2 = true }, 2100)
    setTimeout(() => { this.showBtn3 = true }, 2400)
    setTimeout(() => { this.showVersion = true }, 2800)
  }

  onPageShow(): void {
    getAudioManager().playBGM('bgm_menu.wav')
  }

  build() {
    Column() {
      Column() {
        Row() {
          Divider()
            .color('#00E676')
            .width(this.showHeader ? 56 : 0)
            .height(2)
            .strokeWidth(2)
            .animation({ duration: 400, curve: Curve.EaseOut })

          Text('TΛNK  WΛRFΛRE')
            .fontSize(10)
            .fontColor('#00E676')
            .letterSpacing(6)
            .margin({ left: 10, right: 10 })
            .opacity(this.showHeader ? 1 : 0)
            .animation({ duration: 300 })

          Divider()
            .color('#00E676')
            .width(this.showHeader ? 56 : 0)
            .height(2)
            .strokeWidth(2)
            .animation({ duration: 400, curve: Curve.EaseOut })
        }
        .margin({ bottom: 20 })

        Row() {
          Text('BΛTTLE')
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD54F')
            .letterSpacing(6)
            .opacity(1)
            .translate({ x: this.showBattle ? 0 : -60, y: 0 })
            .animation({ duration: 900, curve: Curve.FastOutSlowIn })

          Text('  CITY')
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFD54F')
            .letterSpacing(6)
            .opacity(1)
            .translate({ x: this.showCity ? 0 : 60, y: 0 })
            .animation({ duration: 900, curve: Curve.FastOutSlowIn })
        }
        .margin({ bottom: 4 })

        Text('TΛNK  ·  1985')
          .fontSize(13)
          .fontColor('#78909C')
          .letterSpacing(8)
          .opacity(this.showSubtitle ? 1 : 0)
          .animation({ duration: 500, curve: Curve.EaseOut })
      }
      .margin({ top: 0, bottom: 0 })

      Column() {
        Row() {
          Column()
            .width(4)
            .height(48)
            .backgroundColor('#00E676')
            .borderRadius(2)
          Column() {
            Text('开始游戏')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E0E0E0')
            Text('STΛRT  GΛME')
              .fontSize(11)
              .fontColor('#546E7A')
              .letterSpacing(4)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16, top: 2 })
          .layoutWeight(1)
          Text('>')
            .fontSize(16)
            .fontColor('#37474F')
        }
        .width('100%')
        .height(60)
        .backgroundColor('#0D1525')
        .borderRadius(4)
        .padding({ right: 16 })
        .margin({ bottom: 12 })
        .opacity(this.showBtn1 ? 1 : 0)
        .translate({ x: this.showBtn1 ? 0 : 40 })
        .animation({ duration: 600, curve: Curve.FastOutSlowIn })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/GamePage' }) } catch (e) {}
        })

        Row() {
          Column()
            .width(4)
            .height(48)
            .backgroundColor('#29B6F6')
            .borderRadius(2)
          Column() {
            Text('关卡选择')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E0E0E0')
            Text('SELECT  STΛGE')
              .fontSize(11)
              .fontColor('#546E7A')
              .letterSpacing(4)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16, top: 2 })
          .layoutWeight(1)
          Text('>')
            .fontSize(16)
            .fontColor('#37474F')
        }
        .width('100%')
        .height(60)
        .backgroundColor('#0D1525')
        .borderRadius(4)
        .padding({ right: 16 })
        .margin({ bottom: 12 })
        .opacity(this.showBtn2 ? 1 : 0)
        .translate({ x: this.showBtn2 ? 0 : 40 })
        .animation({ duration: 600, curve: Curve.FastOutSlowIn })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/LevelSelectPage' }) } catch (e) {}
        })

        Row() {
          Column()
            .width(4)
            .height(48)
            .backgroundColor('#AB47BC')
            .borderRadius(2)
          Column() {
            Text('设置')
              .fontSize(17)
              .fontWeight(FontWeight.Bold)
              .fontColor('#E0E0E0')
            Text('SETTINGS')
              .fontSize(11)
              .fontColor('#546E7A')
              .letterSpacing(4)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 16, top: 2 })
          .layoutWeight(1)
          Text('>')
            .fontSize(16)
            .fontColor('#37474F')
        }
        .width('100%')
        .height(60)
        .backgroundColor('#0D1525')
        .borderRadius(4)
        .padding({ right: 16 })
        .margin({ bottom: 12 })
        .opacity(this.showBtn3 ? 1 : 0)
        .translate({ x: this.showBtn3 ? 0 : 40 })
        .animation({ duration: 600, curve: Curve.FastOutSlowIn })
        .onClick(() => {
          try { router.pushUrl({ url: 'pages/SettingPage' }) } catch (e) {}
        })
      }
      .width('100%')
      .padding({ left: 32, right: 32 })

      Text('V 1.0  ·  BΛTTLE  CITY')
        .fontSize(10)
        .fontColor('#37474F')
        .letterSpacing(4)
        .margin({ top: 0 })
        .opacity(this.showVersion ? 1 : 0)
        .animation({ duration: 600, curve: Curve.EaseOut })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .padding({ top: 24, bottom: 24 })
    .backgroundColor('#060B14')
  }
}

export default MainPage
