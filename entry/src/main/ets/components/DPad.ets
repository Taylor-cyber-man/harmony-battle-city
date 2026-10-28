import { onDPadDown, onDPadUp } from '../game/systems/InputSystem'
import { DPadKey } from '../game/utils/Constants'

@Builder
export function DPadBuilder() {
  Column() {
    Row() {
      Button('▲')
        .width(60)
        .height(60)
        .fontSize(24)
        .fontColor('#FFF')
        .backgroundColor('#333')
        .borderRadius(8)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            onDPadDown(DPadKey.UP)
          } else if (event.type === TouchType.Up) {
            onDPadUp(DPadKey.UP)
          }
        })
    }

    Row() {
      Button('◀')
        .width(60)
        .height(60)
        .fontSize(24)
        .fontColor('#FFF')
        .backgroundColor('#333')
        .borderRadius(8)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            onDPadDown(DPadKey.LEFT)
          } else if (event.type === TouchType.Up) {
            onDPadUp(DPadKey.LEFT)
          }
        })

      Button('●')
        .width(60)
        .height(60)
        .fontSize(12)
        .fontColor('#666')
        .backgroundColor('#222')
        .borderRadius(30)
        .onTouch(() => {
        })

      Button('▶')
        .width(60)
        .height(60)
        .fontSize(24)
        .fontColor('#FFF')
        .backgroundColor('#333')
        .borderRadius(8)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            onDPadDown(DPadKey.RIGHT)
          } else if (event.type === TouchType.Up) {
            onDPadUp(DPadKey.RIGHT)
          }
        })
    }

    Row() {
      Button('▼')
        .width(60)
        .height(60)
        .fontSize(24)
        .fontColor('#FFF')
        .backgroundColor('#333')
        .borderRadius(8)
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            onDPadDown(DPadKey.DOWN)
          } else if (event.type === TouchType.Up) {
            onDPadUp(DPadKey.DOWN)
          }
        })
    }
  }
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}
