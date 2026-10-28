# 碰撞检测系统 (collision-detection-system)

## ADDED Requirements

### Requirement: AABB 坦克-子弹-地形三方碰撞检测
系统 SHALL 使用 AABB（Axis-Aligned Bounding Box）算法实现坦克与子弹、子弹与地形、坦克与地形之间的碰撞检测，每帧对所有活动实体进行检测。

#### Scenario: 子弹击中坦克
- **WHEN** 子弹的 AABB 包围盒与坦克的 AABB 包围盒重叠
- **THEN** 子弹被销毁，触发对应坦克的受击逻辑（玩家损命/敌人扣 HP）

#### Scenario: 子弹击中地形
- **WHEN** 子弹的 AABB 包围盒与砖墙或钢墙 tile 的 AABB 包围盒重叠
- **THEN** 根据子弹威力等级和墙体类型执行破坏或销毁逻辑

#### Scenario: 坦克与地形碰撞
- **WHEN** 坦克移动时其前缘 AABB 与不可通过的墙体 tile 重叠
- **THEN** 坦克在该方向上停止移动

#### Scenario: 子弹互抵
- **WHEN** 玩家子弹与敌方子弹的 AABB 包围盒重叠（中心距离 < 8px）
- **THEN** 两枚子弹互相销毁

### Requirement: 边界检测
系统 SHALL 检测所有实体是否超出游戏区边界（1040×1040 px），超出边界的实体进行相应处理。

#### Scenario: 坦克不出界
- **WHEN** 坦克移动时前缘 AABB 超出游戏区边界
- **THEN** 坦克在该方向上停止移动

#### Scenario: 子弹出界销毁
- **WHEN** 子弹中心坐标超出游戏区边界
- **THEN** 子弹被销毁，释放对应子弹槽位

### Requirement: 碰撞响应
系统 SHALL 在碰撞发生时执行正确的响应逻辑：伤害计算（重型坦克 HP 递减）、地形破坏（砖墙象限掩码更新）、爆炸动画播放。

#### Scenario: 重型坦克 HP 递减
- **WHEN** 玩家子弹击中重型坦克
- **THEN** 重型坦克 HP 减 1，播放受击闪烁（2 帧白屏），若 HP=0 播放爆炸动画并计分

#### Scenario: 砖墙破坏动画
- **WHEN** 子弹击中砖墙某象限
- **THEN** 该象限立即变为空地，播放简短碎片粒子效果（4 帧），更新砖墙 tile 渲染缓存

#### Scenario: 爆炸动画播放
- **WHEN** 任意坦克 HP 归零
- **THEN** 播放 4 帧扩散爆炸动画（橙→红→黄→灰），动画结束后移除此实体
