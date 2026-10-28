@Builder
export function StageClearOverlayBuilder(
  stageIndex: number, score: number,
  lightCount: number, armoredCount: number,
  fastCount: number, heavyCount: number
) {
  Column() {
    Column() {
      Text('STAGE CLEAR')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor('#4CAF50')
        .margin({ bottom: 16 })

      Text('Stage ' + stageIndex.toString())
        .fontSize(20)
        .fontColor('#FFFFFF')
        .margin({ bottom: 12 })

      Text('Score: ' + score.toString())
        .fontSize(18)
        .fontColor('#FFEB3B')
        .margin({ bottom: 12 })

      Text('轻型 ×' + lightCount.toString() + '  装甲 ×' + armoredCount.toString())
        .fontSize(14)
        .fontColor('#CCC')
        .margin({ bottom: 4 })

      Text('速射 ×' + fastCount.toString() + '  重型 ×' + heavyCount.toString())
        .fontSize(14)
        .fontColor('#CCC')
    }
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .backgroundColor('rgba(0,0,0,0.6)')
}
