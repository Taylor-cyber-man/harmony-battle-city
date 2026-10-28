import { onFireButtonDown } from '../game/systems/InputSystem'

@Builder
export function FireButtonBuilder() {
  Column() {
    Button('FIRE')
      .width(100)
      .height(100)
      .fontSize(18)
      .fontWeight(FontWeight.Bold)
      .fontColor('#FFF')
      .backgroundColor('#FF5722')
      .borderRadius(50)
      .onTouch((event: TouchEvent) => {
        if (event.type === TouchType.Down) {
          onFireButtonDown()
        }
      })
      .onClick(() => {
        onFireButtonDown()
      })

    Button('⏸')
      .width(60)
      .height(40)
      .fontSize(20)
      .fontColor('#FFF')
      .backgroundColor('#444')
      .borderRadius(8)
      .margin({ top: 16 })
      .onClick(() => {
      })
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}
