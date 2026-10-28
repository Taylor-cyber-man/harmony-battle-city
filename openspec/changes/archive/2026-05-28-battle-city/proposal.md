# 项目提案：Battle City 1985 复刻

## Why

本项目是"鸿蒙应用开发与实践"课程（2025-2026 学年第二学期）的工程化作业。Battle City（坦克大战）是1985年Namco发行的经典坦克射击游戏，以简单的操作、丰富的关卡设计和独特的双人合作模式闻名。本作业要求使用 HarmonyOS DevEco Studio 6.02 + ArkTS 语言完整复刻这款经典游戏，并通过 OpenSpec 进行规范驱动的工程化开发。这是将游戏开发基本原理（游戏循环、碰撞检测、AI行为）与 HarmonyOS 原生开发能力结合的绝佳实践机会。

## What Changes

- 新建完整的 DevEco Studio 项目，采用 Stage 模式 + ArkUI 声明式 UI 架构
- 实现基于 Canvas 2D 的 60 FPS 游戏渲染引擎
- 实现玩家坦克 8 方向触摸控制与射击系统
- 实现 4 种敌方坦克（轻型、装甲车、速射炮、重型）及基于规则的 AI 行为
- 实现 13×13 网格关卡系统，至少 10 关，前 3 关完整可玩
- 实现 5 种地形类型（空地、砖墙、钢墙、森林、水域）及砖墙子象限破坏模型
- 实现 AABB 碰撞检测系统（坦克-子弹-地形三方碰撞）
- 实现得分计算、生命管理、关卡进度保存/读档系统
- 实现 6 种能量提升道具（火力增强、全灭、护盾、冻结、基地加固、额外生命）
- 实现完整 UI 界面（主菜单、HUD、暂停/结束面板、触摸控制）
- 创建 OpenSpec 规范文档（spec.md / proposal.md / design.md / tasks.md）
- 交付 UI_Demo 设计文档（UI_Design.pdf + UI_Interaction_Flow.md）
- 录制 1080p 游戏演示视频（3-5 分钟）

## Capabilities

### New Capabilities

- `game-engine-core`: 60 FPS 游戏循环、有限状态机（FSM）状态管理、Canvas 2D 渲染管线、资源加载与内存管理
- `player-tank-control`: 8 方向触摸/手势移动、射击冷却与子弹轨迹、与障碍物和敌人子弹的碰撞响应
- `enemy-ai-system`: 4 种敌人类型（轻型/装甲车/速射炮/重型）、基于规则的状态机 AI、方向序列与目标寻向、难度递进的射击精度、3 个固定出兵点的生成与重生机制
- `level-design-system`: 13×13 metatile 关卡网格、5 种地形类型编码、砖墙 4 象限子破坏模型、鹰基地 Π 形围墙保护、至少 10 关数据（前 3 关完整可玩）
- `collision-detection-system`: AABB 坦克-子弹-地形三方碰撞检测、边界检测、碰撞响应（伤害计算、地形破坏、子弹互抵）
- `score-progression-system`: 4 档敌人分数（100/200/300/400）、生命值管理（初始 3 条命，每 20000 分加命）、关卡进度保存与读档（Preferences）
- `power-up-system`: 6 种道具（星/雷/盾/钟/铲/命）、第 4/11/18 辆道具坦克机制、临时效果计时与过期处理
- `ui-ux-components`: HarmonyOS 原生风格主菜单/设置/暂停/结束界面、游戏 HUD（分数/生命/关卡/敌人计数）、虚拟摇杆 + 射击按钮触摸控制、浅色/深色主题支持

### Modified Capabilities

（无现有能力需修改，本项目为全新构建）

## Impact

- **开发环境**: DevEco Studio 6.02, ArkTS, API 22 (target), API 9+ (compatible)
- **依赖**: 无第三方游戏引擎，仅使用 HarmonyOS 原生 Canvas 2D + ArkUI
- **项目结构**: entry 模块下新增 game/ (core/entities/systems/levels/utils)、managers/、data/ 目录
- **资源**: 纯代码绘制（无外部精灵图依赖），Canvas 离屏预渲染缓存
- **测试**: 使用 HarmonyOS 模拟器或真机测试，目标 60 FPS 稳定运行
- **约束**: 禁止使用 any/unknown 类型，遵守 ArkTS 严格模式全部语法约束
