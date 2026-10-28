# 系统设计文档：Battle City 1985 复刻

## Context

本项目需要在 HarmonyOS DevEco Studio 6.02 环境下，使用 ArkTS 语言和原生 Canvas 2D + ArkUI 技术栈，从零复刻 1985 年 Namco 经典游戏 Battle City。项目已具备 Stage 模式的项目骨架（API 22 target, API 9+ compatible），需要通过 OpenSpec 规范驱动开发流程完成完整的工程化交付。

## Goals / Non-Goals

**Goals:**
- 实现 60 FPS 稳定游戏循环，目标帧率不低于 30 FPS
- 完整实现原版 Battle City 1985 前 3 关的地形布局和敌人配置
- 实现 8 方向触摸控制、4 种敌人 AI、AABB 碰撞检测、6 种道具系统
- 提供 HarmonyOS 原生风格的完整 UI（菜单/HUD/暂停/结束/设置/触摸控制）
- 交付完整的 OpenSpec 规范文档（proposal + specs + design + tasks）
- 使用纯代码绘制（Canvas 2D），无外部图片/精灵图依赖

**Non-Goals:**
- 不使用第三方游戏引擎（Unity、Cocos2d-x 等）
- 不实现双人合作模式（P1，可预留 P2 接口）
- 不实现在线排行榜
- 不实现关卡编辑器（P2 加分项预留）
- 不追求音频系统的完整实现（可以是简化版本）

## Decisions

### 决策 1: 渲染方式 — Canvas 2D 纯代码绘制

**选择**: 使用 HarmonyOS Canvas 2D API (`CanvasRenderingContext2D`)，所有游戏元素通过 `fillRect`/`strokeRect`/`arc`/`lineTo` 等原生 API 绘制，不依赖外部图片资源。

**理由**: 作业明确禁止第三方游戏引擎，且纯代码绘制避免资源管理复杂度、完美缩放不失真、色彩统一。

**替代方案**: ArkUI 组件化绘制（每个 tile 一个 `@Component`）—— 性能不足以支撑 60 FPS 的游戏循环。

### 决策 2: 游戏循环 — setInterval 驱动

**选择**: 使用 `setInterval(fn, 16)` (约 60 FPS) 驱动游戏主循环，每帧执行 `update()` → `render()`。

**理由**: ArkTS 严格模式下不支持 `requestAnimationFrame`（该 API 在非浏览器环境中行为不确定）。`setInterval` 是 HarmonyOS 中稳定的定时器方案。

**风险缓解**: 在 `update()` 中使用 delta-time 补偿，避免帧率波动导致游戏速度不一致。

### 决策 3: 关卡数据 — 13×13 数字数组

**选择**: 使用 `number[][]` 二维数组存储每关 13×13 地形数据，每元素为 0-5 枚举值。关卡数据编译为 TypeScript 常量文件。

**理由**: 直接映射原版 NES ROM 编码方式（4-bit nibble），简洁高效，易于手动编码和验证。

### 决策 4: 坦克移动 — 8px 网格对齐

**选择**: 坦克位置更新时对齐到 8px（在原版中为 8 NES px）网格，移动速度以 px/frame 为单位，4 方向移动前检查前缘碰撞。

**理由**: 原版 Battle City 的 `MoveGridSnap` 机制保证了平整的碰撞检测和视觉对齐。

### 决策 5: AI 系统 — 规则驱动有限状态机

**选择**: 不使用复杂寻路算法（如 A*），采用原版的简单规则：随机方向选择 + 15 帧 1/16 概率改变方向 + 受阻后重选方向 + 30% 概率朝向玩家。

**理由**: 原版 AI 就是基于规则的，关卡设计本身就是"引导牌"让敌人按预定路径行动。复杂寻路反而破坏游戏性。

### 决策 6: 碰撞检测 — AABB 包围盒

**选择**: 使用轴对齐包围盒（AABB），每个实体有 `x, y, width, height`，检测两个矩形是否重叠。坦克移动时使用前缘角探测。

**理由**: 俯视角 2D 游戏的标准方案，计算简单（仅需比较坐标范围），完全满足 13×13 网格场景需求。

### 决策 7: 渲染缓存 — 离屏 Canvas 预渲染

**选择**: 每个地形 tile 类型和坦克朝向在首次渲染时绘制到离屏 Canvas（`OffscreenCanvas`），后续帧通过 `drawImage()` 贴到主 Canvas。

**理由**: 大幅减少每帧绘制调用次数，从 169+ 次精细绘制降低为 169+ 次贴图操作，对帧率稳定性至关重要。

### 决策 8: 数据持久化 — Preferences

**选择**: 使用 `@ohos.data.preferences` 存储关卡进度（当前已解锁关卡编号）和历史最高分。

**理由**: HarmonyOS 原生轻量 KV 存储，无需权限申请，API 简单，适合游戏存档场景。

### 决策 9: 色彩方案 — 探索中定义的调色板

**选择**: 使用探索阶段确定的 MASTER COLOR PALETTE（战场底色 #1A1A2E、砖墙 #C45B3C、钢墙 #6A7B8B 等），所有颜色定义为常量。

**理由**: 统一的色彩体系保证视觉一致性，深海军蓝底色比纯黑更有质感，暖色砖墙与冷色钢墙形成清晰材质对比。

### 决策 10: 键盘输入 — WASD 移动 + Space 射击

**选择**: 使用 ArkUI 通用事件 `onKeyEvent` 捕获物理键盘输入，W/A/S/D 控制 8 方向移动，Space 空格键触发射击。采用 `Set<number>` 记录当前按下的键，每帧读取 Set 计算方向向量。键盘输入与触摸控制共存，键盘优先。

**理由**: ArkUI 的 `onKeyEvent` 从 API 7 开始支持，无需额外导入、无需权限申请。游戏 Canvas 组件没有输入框，按键事件不会被输入法拦截，直接到达 onKeyEvent 回调。HarmonyOS 模拟器和 DevEco Studio 均支持键盘桥接。

**替代方案**: `@kit.InputKit` 底层 API（`@ohos.multimodalInput.keyEvent`）— 需要 `ohos.permission.INPUT_MONITORING` 权限且 API 更复杂，对于简单的 WASD 控制过度设计。

**KeyCode 映射**:
| 按键 | 枚举 | 数值 | 作用 |
|------|------|------|------|
| W | KEYCODE_W | 2039 | 向上移动 |
| A | KEYCODE_A | 2017 | 向左移动 |
| S | KEYCODE_S | 2035 | 向下移动 |
| D | KEYCODE_D | 2020 | 向右移动 |
| Space | KEYCODE_SPACE | 2050 | 发射子弹 |

**输入优先级**: 键盘 pressedKeys 非空时使用键盘方向，为空时回退到虚拟摇杆方向。射击按钮和空格均可触发射击。

### 决策 11: 横屏布局 + 动态画布尺寸

**选择**: 游戏使用固定横屏 LANDSCAPE 模式（`window.Orientation.LANDSCAPE`），布局为左方向键 (~18%) + 中间地图 (layoutWeight 填充) + 右侧开火/暂停 (~12%)。Canvas 画布尺寸由 `onAreaChange` 动态计算：`TILE_SIZE = min(availW / 13, availH / 13)`，总画布 = `TILE_SIZE × 13`，全地图始终可见，不做任何缩放裁剪。

**理由**: 横屏更适合双手操作游戏（左拇指方向、右拇指射击）。动态 TILE 尺寸适配不同设备分辨率，全地图显示保证 13×13 地形一览无余。`layoutWeight` 自动填充剩余空间，避免硬编码。

**替代方案**: 
- 竖屏 + 固定画布 1040×1040 → 兼容性差，不同设备可能裁切或留白过大
- `display.getDefaultDisplaySync()` 获取物理分辨率再计算 → 不如 `onAreaChange` 精确，因为后者反映的是实际可用布局区域（排除系统栏、方向键区域等）

**横屏锁定实现**:
- `module.json5`: `"orientation": "landscape"`（静态声明）
- `EntryAbility.onWindowStageCreate`: `mainWindow.setPreferredOrientation(window.Orientation.LANDSCAPE)`（运行时锁定）

**Tile 尺寸计算**:
```
onAreaChange(oldArea, newArea) →
  availW = newArea.width   // 中间 Column 实际可用宽度
  availH = newArea.height  // 中间 Column 实际可用高度
  TILE_SIZE = floor(min(availW / 13, availH / 13))
  canvasSize = TILE_SIZE × 13   // 全地图像素
```

## 总体架构

```
┌─────────────────────────────────────────────────────────────┐
│                     MyApplication                           │
│  ┌──────────────────────────────────────────────────────┐  │
│  │                   entry 模块                          │  │
│  │                                                       │  │
│  │  pages/             components/        managers/      │  │
│  │  ┌──────────┐    ┌──────────────┐    ┌────────────┐  │  │
│  │  │MainPage  │    │DPad            │    │AudioManager│  │  │
│  │  │GamePage  │    │FireButton    │    │StorageMgr  │  │  │
│  │  │SettingPg │    │HudOverlay    │    │ResourceMgr │  │  │
│  │  └──────────┘    │GameCanvas    │    └────────────┘  │  │
│  │                  └──────────────┘                     │  │
│  │                                                       │  │
│  │  game/                                                │  │
│  │  ┌─────────────────────────────────────────────────┐ │  │
│  │  │ core/                                            │ │  │
│  │  │  GameEngine.ts  ← 协调所有系统                    │ │  │
│  │  │  GameLoop.ts    ← setInterval 16ms 定时器        │ │  │
│  │  │  GameState.ts   ← FSM 枚举 (MENU→LOADING→...)   │ │  │
│  │  ├─────────────────────────────────────────────────┤ │  │
│  │  │ entities/                                        │ │  │
│  │  │  Tank.ts       ← 坦克基类 (position/direction/HP) │ │  │
│  │  │  Bullet.ts     ← 子弹 (owner/speed/damage)       │ │  │
│  │  │  Terrain.ts    ← 地形 tile (type/brickBits)       │ │  │
│  │  │  PowerUp.ts    ← 道具 (type/duration/timer)       │ │  │
│  │  ├─────────────────────────────────────────────────┤ │  │
│  │  │ systems/                                         │ │  │
│  │  │  CollisionSystem.ts ← AABB 碰撞检测              │ │  │
│  │  │  AISystem.ts        ← 敌方行为 AI               │ │  │
│  │  │  SpawnSystem.ts     ← 敌人生成/出兵管理          │ │  │
│  │  │  RenderSystem.ts    ← 11 层渲染管线              │ │  │
│  │  ├─────────────────────────────────────────────────┤ │  │
│  │  │ levels/                                          │ │  │
│  │  │  LevelData.ts    ← 13×13 数组关卡数据            │ │  │
│  │  │  LevelManager.ts ← 加载/切换关卡逻辑             │ │  │
│  │  ├─────────────────────────────────────────────────┤ │  │
│  │  │ utils/                                           │ │  │
│  │  │  Constants.ts   ← 游戏常量/枚举/色彩调色板         │ │  │
│  │  │  MathUtils.ts   ← AABB 检测/网格对齐工具函数      │ │  │
│  │  └─────────────────────────────────────────────────┘ │  │
│  │                                                       │  │
│  │  data/                                                │  │
│  │   ScoreData.ts      ← 分数/生命值/关卡进度数据模型    │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## 模块划分

| 模块路径 | 职责 | 关键类/文件 |
|---------|------|------------|
| `game/core/` | 游戏引擎核心：主循环、状态管理、子系统协调 | GameEngine, GameLoop, GameState |
| `game/entities/` | 游戏实体数据模型：坦克、子弹、地形、道具 | Tank, Bullet, Terrain, PowerUp |
| `game/systems/` | 游戏逻辑系统：碰撞、AI、生成、渲染、输入 | CollisionSystem, AISystem, SpawnSystem, RenderSystem, InputSystem |
| `game/levels/` | 关卡数据定义与关卡切换管理 | LevelData, LevelManager |
| `game/utils/` | 工具函数：常量、数学工具 | Constants, MathUtils |
| `managers/` | 跨模块管理器：音频、存储、资源 | AudioManager, StorageManager, ResourceManager |
| `components/` | ArkUI `@Component` 组件 | GameCanvas, DPad, FireButton, HudOverlay |
| `pages/` | 页面级组件 | MainPage, GamePage, SettingPage |
| `data/` | 数据模型和持久化接口 | ScoreData |

## 数据流设计

```
┌─────────────┐  触摸事件   ┌──────────────────────────────────────┐
│  DPad       │────────────▶│                                      │
│  FireButton │             │          GameEngine                  │
│  (ArkUI)    │             │                                      │
└─────────────┘             │  ┌──────────┐    ┌───────────────┐  │
                            │  │ Input    │───▶│ PlayerSystem  │  │
                            │  │ (方向/射击)│    │ (移动/射击)    │  │
                            │  └──────────┘    └───────┬───────┘  │
                            │                          │          │
                            │  ┌──────────┐    ┌───────▼───────┐  │
                            │  │ AISystem │───▶│ Enemy Tanks   │  │
                            │  │ (行为决策)│    │ (移动/射击)    │  │
                            │  └──────────┘    └───────┬───────┘  │
                            │                          │          │
                            │  ┌──────────────┐  ┌─────▼───────┐  │
                            │  │CollisionSystem│─▶│Bullets+     │  │
                            │  │ (AABB 检测)   │  │Terrain Hit  │  │
                            │  └──────┬───────┘  └─────┬───────┘  │
                            │         │                │          │
                            │  ┌──────▼────────────────▼───────┐  │
                            │  │        GameState Update       │  │
                            │  │ (分数/生命/关卡/道具计时器)     │  │
                            │  └──────────────┬───────────────┘  │
                            │                 │                  │
                            └─────────────────┼──────────────────┘
                                              │
                            ┌─────────────────▼──────────────────┐
                            │         RenderSystem               │
                            │  Layer 0: 空地背景                  │
                            │  Layer 1: 地形 tile                 │
                            │  Layer 2: 鹰基地                    │
                            │  Layer 3: 道具图标                  │
                            │  Layer 4: 坦克实体                  │
                            │  Layer 5: 子弹                      │
                            │  Layer 6: 爆炸动画                  │
                            │  Layer 7: 生成动画                  │
                            │  Layer 8: 森林遮挡                  │
                            │  Layer 9: HUD 覆盖                  │
                            │  Layer 10: 触控覆盖                 │
                            │  Layer 11: 特效覆盖                 │
                            └──────────────┬─────────────────────┘
                                           │
                            ┌──────────────▼─────────────────────┐
                            │       GameCanvas (Canvas 2D)        │
                            │        1260 × 2720 px               │
                            └────────────────────────────────────┘
```

组件间通信方式：
- **触摸事件 → GameEngine**: ArkUI 的 `onTouch` 事件通过回调传递方向向量和射击布尔值
- **键盘事件 → GameEngine**: ArkUI 的 `onKeyEvent` 通过 `Set<number>` 实时记录按下的 WASD/Space 键码，每帧读取计算方向
- **GameEngine → RenderSystem**: 每帧 GameEngine 将实体数据传给 RenderSystem 进行绘制
- **GameEngine → StorageManager**: 过关/游戏结束时调用 `saveProgress()` 写入 Preferences
- **State 驱动 UI 切换**: 使用 `@State gameState: GameState` 驱动 ArkUI 条件渲染（菜单/游戏/暂停面板）
- **输入模式共存**: 键盘 pressedKeys 非空时使用键盘方向，为空时回退到虚拟摇杆方向，无需 UI 切换

## 游戏引擎设计

### 主循环时序

```
每一帧 (~16ms):
┌─────────┐    ┌──────────────┐    ┌──────────┐    ┌──────────┐
│ readInput│───▶│ updateSystems│───▶│ checkWin │───▶│ render   │
│ ()       │    │ ()           │    │ /Lose () │    │ ()       │
└─────────┘    └──────────────┘    └──────────┘    └──────────┘
                    │
    ┌───────────────┼───────────────┐
    ▼               ▼               ▼
┌────────┐    ┌──────────┐    ┌──────────────┐
│Player  │    │Enemy AI  │    │Collision     │
│Move+   │    │Move+     │    │Detection     │
│Shoot   │    │Shoot     │    │              │
└────────┘    └──────────┘    └──────┬───────┘
                                     │
                          ┌──────────▼──────────┐
                          │Tank-Bullet  Bullet- │
                          │Terrain      Bullet  │
                          │Bullet-Bullet         │
                          └─────────────────────┘
```

### 有限状态机

```
                 ┌─────────────────────┐
                 │       MENU          │
                 └─────────┬───────────┘
                           │ 点击"开始"
                           ▼
                 ┌─────────────────────┐
                 │      LOADING        │
                 └─────────┬───────────┘
                           │ 关卡加载完成
                           ▼
          ┌──────────────────────────────────┐
          │            RUNNING               │◀─────────────┐
          └────┬─────────┬──────────┬───────┘              │
               │         │          │                      │
        点击暂停     20敌全灭    基地被毁/生命0            │
               │         │          │                      │
               ▼         ▼          ▼                      │
     ┌──────────┐ ┌────────────┐ ┌──────────┐             │
     │ PAUSED   │ │STAGE_      │ │GAME_OVER │             │
     │          │ │TRANSITION  │ │          │             │
     └────┬─────┘ └─────┬──────┘ └────┬─────┘             │
          │             │             │                   │
    点击继续      2秒后自动      点击重新开始 ──────────────┘
          │             │
          ▼             ▼
    回到 RUNNING   下一关 LOADING
```

## 渲染系统设计

### 11 层渲染管线和绘制方式

| 层级 | 内容 | 绘制方式 |
|------|------|---------|
| 0 | 空地背景 + 2px 网格线 | 全屏 fillRect + 循环 strokeRect |
| 1 | 地形 tile（砖墙/钢墙/水域/冰面） | 离屏缓存 drawImage |
| 2 | 鹰基地（鹰图标 + Π 形围墙） | 预定义坐标像素绘制 |
| 3 | 道具图标（6 种 + 旋转光晕） | 当前活跃道具直接绘制 |
| 4 | 坦克实体（玩家 + 敌人） | 4 朝向离屏缓存 drawImage |
| 5 | 子弹 | fillRect 直接绘制 |
| 6 | 爆炸动画（4 帧扩散） | 当前帧索引切换绘制 |
| 7 | 生成动画（4 帧闪光） | 当前帧索引切换绘制 |
| 8 | 森林 tile（覆盖坦克之上） | 离屏缓存 drawImage |
| 9 | HUD 覆盖层 | fillText + fillRect + 图标 |
| 10 | 触摸控制覆盖层（虚拟摇杆 + 按钮） | ArkUI 组件层（非 Canvas） |
| 11 | 特效覆盖（护盾光晕、冻结雪花、全屏闪白） | 半透明遮罩绘制 |

### 预渲染缓存策略

```
初始化阶段 (LOADING):
  terrainCache: Map<number, OffscreenCanvas>     // tile 类型 → 离屏 canvas
  tankCache: Map<string, OffscreenCanvas>        // "player_up" "enemy_light_down" 等
  bulletCache: OffscreenCanvas[3]                // 玩家/敌人/穿甲
  explosionCache: OffscreenCanvas[4]             // 4 帧
  eagleCache: OffscreenCanvas                    // 鹰图标

运行时:
  brickHalfState 按需更新缓存（当砖墙子象限变化时）
```

## 碰撞检测设计

### AABB 算法

```
AABB 检测逻辑:
  function checkCollision(a: AABB, b: AABB): boolean {
    return a.x < b.x + b.width
        && a.x + a.width > b.x
        && a.y < b.y + b.height
        && a.y + a.height > b.y
  }

每帧检测顺序:
  1. 所有子弹 vs 所有地形（子弹-地形碰撞）
  2. 所有玩家子弹 vs 所有敌人坦克（玩家子弹-敌人碰撞）
  3. 所有敌人子弹 vs 玩家坦克（敌人子弹-玩家碰撞）
  4. 玩家子弹 vs 敌人子弹（子弹互抵，中心距离 < 8px）
  5. 所有坦克前缘 vs 地形（移动碰撞检查）
```

### 优化策略

- **空间分桶**: 13×13 网格天然提供空间分区，每个实体只需检测所在 tile 及其相邻 tile
- **坦克前缘探测**: 只在移动方向上检查 2 个前缘角点，避免每帧检测 4 个角
- **子弹快速路径**: 子弹每帧移动后先检查是否出界，再检查碰撞

## AI 系统设计

### 3 种敌人类型行为差异

| 行为 | 轻型坦克 | 装甲车 | 速射炮 | 重型坦克 |
|------|---------|--------|--------|---------|
| 速度 (px/frame) | 1 | 2 | 1 | 1 |
| 射击间隔 | 2 秒 | 2 秒 | 1 秒 | 2 秒 |
| 弹速 | 标准 | 标准 | 2倍 | 标准 |
| 方向改变概率 | 1/16 | 1/16 | 1/8 | 1/16 |
| 朝向玩家概率 | 20% | 20% | 40% | 30% |
| HP | 1 | 1 | 1 | 4 |

### 硬编码方向序列

```
原版 NES 使用两套 9-entry 方向循环:
  Set 0: UP → LEFT → DOWN → RIGHT → UP → LEFT → DOWN → RIGHT → UP
  Set 1: UP → RIGHT → DOWN → LEFT → UP → RIGHT → DOWN → LEFT → UP

敌人按帧交替选择 set 和随机方向，每移动 15 帧推进一次序列索引
```

## 关卡系统设计

### 关卡数据结构

```
// 一个关卡的完整数据
interface StageData {
  stageIndex: number                    // 关卡编号 (1-35)
  terrain: number[][]                   // 13×13 地形数组 (0-5)
  enemySequence: EnemyType[]            // 20 个敌人出场顺序
}

// 地形编码
enum TileType {
  EMPTY  = 0,  // 空地
  BRICK  = 1,  // 砖墙 (可被子象限破坏)
  STEEL  = 2,  // 钢墙 (只有满级火力可破坏)
  TREES  = 3,  // 森林 (遮挡坦克)
  WATER  = 4,  // 水域 (坦克不可过)
  ICE    = 5   // 冰面 (坦克滑动)
}

// Stage 1-3 不包含 WATER 和 ICE
```

### 砖墙子象限模型

```
每个 80×80 px 砖墙 tile 内的 4 象限编码:
  bit 0 = 左上 (TL), bit 1 = 右上 (TR)
  bit 2 = 左下 (BL), bit 3 = 右下 (BR)

brickMask: number (0b0000-0b1111)

破坏判定:
  子弹击中 tile → 根据子弹中心坐标判断命中哪个子象限
  → 清除对应 bit → 若 mask == 0 则 tile 变空地
  → 否则重新渲染该 tile (部分破坏外观)
```

### 鹰基地布局

```
鹰基地在关卡数据中的固定位置（不在 terrain 数组内，单独绘制）:

  metatile 坐标 (相对于 13×13 网格):
    (5, 11) = 砖墙 (Π 左上)
    (6, 11) = 砖墙 (Π 上中)
    (7, 11) = 砖墙 (Π 右上)
    (5, 12) = 砖墙 (Π 左柱上)
    (8, 12) = 砖墙 (Π 右柱上)
    (5, 13) = 砖墙 (Π 左柱下)
    (8, 13) = 砖墙 (Π 右柱下)
    鹰图标位于 (6, 12) 到 (7, 12) 之间
```

## UI 系统设计

### 屏幕布局（横屏，方向键左 + 地图中 + 开火右）

```
┌─────────────── 横屏 (如 2720 × 1260 px) ────────────────────────────┐
│ ┌──────────────────────────────────────────────────────────────────┐ │
│ │  HUD BAR (~50 px)                                                │ │
│ │  [STAGE 3]  ENEMY ████████░░ 12/20  ❤❤❤  SCORE:45000           │ │
│ └──────────────────────────────────────────────────────────────────┘ │
│ ┌──────┬───────────────────────────────────────┬───────────────────┐ │
│ │ D-Pad│         GAME PLAYFIELD                │      FIRE 🔫     │ │
│ │ ~18% │         13 × 13 tiles                 │      ~12%        │ │
│ │      │         TILE = min(availW/13,         │                  │ │
│ │      │                    availH/13)         │    ⏸ PAUSE      │ │
│ │      │         CANVAS = TILE × 13            │                  │ │
│ │      │         (全地图, 不缩放)               │                  │ │
│ └──────┴───────────────────────────────────────┴───────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘

容器结构:
  Column (width: 100%, height: 100%)
  ├── Row: HUD (~50px height)
  └── Row (layoutWeight: 1)
      ├── Column: 方向键 (width: '18%', 居中)
      ├── Column (layoutWeight: 1)   ← 自动填充剩余空间
      │     └── Canvas: width=canvasSize, height=canvasSize
      │          .onAreaChange → 计算 TILE_SIZE
      └── Column: 开火+暂停 (width: '12%', 居中)

动态 Tile 计算（onAreaChange 回调):
  availW = newArea.width as number    // 实际可用 px
  availH = newArea.height as number
  TILE_SIZE = Math.floor(Math.min(availW / 13, availH / 13))
  canvasPixelSize = TILE_SIZE * 13    // always 13 tiles, no zoom

横屏锁定:
  module.json5:  abilities[0].orientation = "landscape"
  EntryAbility:  setPreferredOrientation(window.Orientation.LANDSCAPE)
```

### D-Pad 十字键触摸控制

采用 5 区域 D-Pad 布局：上、下、左、右 4 个方向键 + 中央死区。每个方向键独立绑定 `onTouch(Down/Up)`，`Set<DPadKey>` 记录当前按下的键，每帧读取计算方向。对角线 = 同时按下相邻两键。与 WASD 键盘逻辑完全统一。

```
D-Pad 布局（自适应左侧 18% Column）:

          ┌─────────┐
          │    ↑    │  W (上)  — 按下 dy=-1, 松开 dy=0
          │  ┌───┐  │
          │  │ ▲ │  │
          │  └───┘  │
  ┌─────┐ ┌───────┐ ┌─────┐
  │  ←  │ │  ●   │ │  →  │  死区: 不触发任何方向
  │ ┌─┐ │ │ (死区)│ │ ┌─┐ │
  │ │◀│ │ │       │ │ │▶│ │
  │ └─┘ │ │       │ │ └─┘ │
  └─────┘ └───────┘ └─────┘
  A (左)   deadzone  D (右)
          ┌─────────┐
          │    ↓    │  S (下)  — 按下 dy=+1, 松开 dy=0
          │  ┌───┐  │
          │  │ ▼ │  │
          │  └───┘  │
          └─────────┘

实现:
  // 4 个独立触摸 Button 区域
  @State dPadKeys: Set<number> = new Set()
  // UP=0, DOWN=1, LEFT=2, RIGHT=3

  Button('▲').onTouch(e => {
    if (e.type === TouchType.Down) dPadKeys.add(0)
    if (e.type === TouchType.Up)   dPadKeys.delete(0)
  })
  // ...同理 LEFT/RIGHT/DOWN

  // 每帧计算方向:
  let dx = 0, dy = 0
  if (dPadKeys.has(2)) dx -= 1  // LEFT
  if (dPadKeys.has(3)) dx += 1  // RIGHT
  if (dPadKeys.has(0)) dy -= 1  // UP
  if (dPadKeys.has(1)) dy += 1  // DOWN

  // 键盘优先: pressedKeys 非空时用键盘，否则回退 D-Pad

与 WASD 统一:
  同一个方向计算函数，输入来自 pressedKeys 或 dPadKeys
  完全一致的 8 方向体验
```

## 数据持久化设计

```
Preferences 存储结构:
  Key: "battle_city_stage_progress"  → Value: number (已解锁关卡编号)
  Key: "battle_city_high_score"      → Value: number (历史最高分)
  Key: "battle_city_theme"           → Value: "light" | "dark"

存取时机:
  写入: 关卡通关时 写入 stage_progress
        游戏结束时 写入 high_score (如果大于已有值)
        设置界面改变时 写入 theme
  读取: 应用启动时 读取所有值初始化游戏状态
```

## 性能优化策略

1. **预渲染缓存**: 地形 tile 和坦克朝向预先缓存为离屏 Canvas（尺寸 = TILE_SIZE × TILE_SIZE），运行时只做 drawImage
2. **脏矩形重绘**: 只重绘变化区域（移动的坦克、飞行的子弹、变化的砖墙），非变化 terrain 跳过重绘
3. **Canvas 尺寸动态适配**: `onAreaChange` 触发时重新计算 TILE_SIZE 并重建缓存，适配不同设备和窗口尺寸变化
4. **固定数组大小**: 敌人槽位固定 6 个（索引 2-7），子弹槽位固定 10 个，避免动态内存分配
5. **碰撞检测剪枝**: 利用 13×13 网格进行空间分桶，减少 AABB 检测对数量
6. **Canvas 上下文复用**: 全局单一 2D context 引用，避免每帧获取
7. **setInterval 替代 rAF**: HarmonyOS 中 setInterval 更可靠，delta-time 补偿帧率抖动

## Risks / Trade-offs

- **[风险] Canvas 2D 性能瓶颈**: 在低端 HarmonyOS 设备上 11 层渲染可能导致帧率下降 → **缓解**: 预渲染缓存 + 脏矩形重绘 + 最小化 Canvas API 调用次数
- **[风险] setInterval 精度不足**: 浏览器环境 setInterval 精度约 4ms，可能影响 60 FPS 稳定性 → **缓解**: 使用 delta-time 补偿，确保游戏逻辑速度不受帧率波动影响
- **[风险] ArkTS 严格模式限制**: 部分 TypeScript 惯用法不可用（如解构、any 类型）→ **缓解**: 已在 config.yaml 中列出全部 27 条 ArkTS 约束，严格遵循
- **[风险] 触摸控制误触**: 虚拟摇杆和射击按钮距离近，可能误触 → **缓解**: 设置合理的触控区域间距和死区阈值（摇杆中心 20px 半径内不触发方向）
- **[风险] 动态 tile 尺寸缓存失效**: 窗口尺寸变化时（分屏/旋转）需要重建所有离屏 Canvas → **缓解**: `onAreaChange` 检测 TILE_SIZE 变化 > 5% 时才重建缓存，避免频繁重建
- **[取舍] 音频简化**: 完整音频系统工作量大，可先实现简化版（只有开火/爆炸/过关音效）→ 不影响核心功能评分
