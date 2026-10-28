# 游戏引擎核心 (game-engine-core)

## ADDED Requirements

### Requirement: 稳定的 60 FPS 游戏循环
系统 SHALL 实现一个稳定的游戏主循环，以 60 帧/秒的目标帧率运行，使用 `setInterval` 实现约 16ms 间隔的定时更新。

#### Scenario: 游戏循环正常运行
- **WHEN** 游戏状态为 "运行中"
- **THEN** 系统每约 16ms 执行一次 update + render 循环，帧率不低于 30 FPS

#### Scenario: 游戏暂停时循环停止更新
- **WHEN** 游戏状态切换为 "暂停"
- **THEN** 游戏循环停止执行 update 逻辑，仅维持当前帧的 render 输出

### Requirement: 有限状态机（FSM）状态管理
系统 SHALL 使用有限状态机管理以下游戏状态：菜单（MENU）、加载（LOADING）、运行（RUNNING）、暂停（PAUSED）、关卡切换（STAGE_TRANSITION）、结束（GAME_OVER）。

#### Scenario: 状态转换流程
- **WHEN** 玩家在主菜单点击"开始游戏"
- **THEN** 状态从 MENU 转换至 LOADING，加载关卡数据后自动转换至 RUNNING

#### Scenario: 暂停与恢复
- **WHEN** 玩家在 RUNNING 状态下点击暂停按钮
- **THEN** 状态转换至 PAUSED，游戏循环暂停更新；再次点击恢复至 RUNNING

#### Scenario: 关卡完成自动切换
- **WHEN** 当前关卡 20 辆敌人全部被消灭
- **THEN** 状态转换至 STAGE_TRANSITION，显示过关动画，2 秒后自动切换至下一关 RUNNING

#### Scenario: 游戏结束判定
- **WHEN** 玩家生命值为 0 或鹰基地被摧毁
- **THEN** 状态转换至 GAME_OVER，显示最终得分和重试选项

### Requirement: Canvas 2D 渲染管线
系统 SHALL 使用 HarmonyOS Canvas 2D API 实现分层渲染管线，Canvas 画布尺寸由 `onAreaChange` 动态计算（`TILE_SIZE = min(availW/13, availH/13)`, canvasSize = TILE_SIZE × 13），包含 11 个渲染层（背景→地形→基地→道具→坦克→子弹→爆炸→生成→森林→HUD→特效）。

#### Scenario: 分层渲染顺序
- **WHEN** 每帧执行渲染
- **THEN** 严格按 Z-order 从低到高渲染，森林层在坦克层之上绘制以产生遮挡效果

#### Scenario: 离屏预渲染缓存
- **WHEN** 首次渲染一个地形 tile 或坦克朝向
- **THEN** 渲染结果缓存到离屏 Canvas，后续帧直接 drawImage 复用

### Requirement: 资源加载与内存管理
系统 SHALL 在 LOADING 状态下初始化所有资源，并在游戏退出时释放 Canvas 缓存和定时器资源。

#### Scenario: 资源初始化
- **WHEN** 应用启动或新游戏开始
- **THEN** 在 LOADING 状态完成时，所有预渲染缓存已就绪

#### Scenario: 内存释放
- **WHEN** 退出游戏或应用被销毁
- **THEN** 清除所有 setInterval 定时器，释放离屏 Canvas 引用
