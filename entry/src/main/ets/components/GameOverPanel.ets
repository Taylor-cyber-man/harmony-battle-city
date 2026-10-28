@Builder
export function GameOverPanelBuilder(score: number, highScore: number) {
  Column() {
    Column() {
      Text('GAME OVER')
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#F44336')
        .margin({ bottom: 16 })

      Text('SCORE: ' + score.toString())
        .fontSize(20)
        .fontColor('#FFFFFF')
        .margin({ bottom: 8 })

      Text('HIGH SCORE: ' + highScore.toString())
        .fontSize(16)
        .fontColor('#FFEB3B')
        .margin({ bottom: 24 })

      Button('重新开始')
        .width(180)
        .height(44)
        .fontSize(16)
        .fontColor('#FFF')
        .backgroundColor('#4CAF50')
        .borderRadius(8)
        .margin({ bottom: 12 })

      Button('返回主菜单')
        .width(180)
        .height(44)
        .fontSize(16)
        .fontColor('#FFF')
        .backgroundColor('#F44336')
        .borderRadius(8)
    }
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor('rgba(0,0,0,0.8)')
}
