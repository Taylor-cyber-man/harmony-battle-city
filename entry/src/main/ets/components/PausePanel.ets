@Component
struct PausePanel {
  @Link isPaused: boolean

  build() {
    if (this.isPaused) {
      Column() {
        Column() {
          Text('PAUSED')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFEB3B')
            .margin({ bottom: 24 })

          Button('继续')
            .width(180)
            .height(44)
            .fontSize(16)
            .fontColor('#FFF')
            .backgroundColor('#4CAF50')
            .borderRadius(8)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.isPaused = false
            })

          Button('重新开始')
            .width(180)
            .height(44)
            .fontSize(16)
            .fontColor('#FFF')
            .backgroundColor('#FF9800')
            .borderRadius(8)
            .margin({ bottom: 12 })
            .onClick(() => {
              this.isPaused = false
            })

          Button('返回主菜单')
            .width(180)
            .height(44)
            .fontSize(16)
            .fontColor('#FFF')
            .backgroundColor('#F44336')
            .borderRadius(8)
            .onClick(() => {
              this.isPaused = false
            })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .backgroundColor('rgba(0,0,0,0.7)')
    }
  }
}

export default PausePanel
