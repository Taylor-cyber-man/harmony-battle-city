# Battle City 1985 — HarmonyOS 复刻版

![Platform](https://img.shields.io/badge/Platform-HarmonyOS%20NEXT-blue)
![API](https://img.shields.io/badge/API%20Level-22-green)
![Language](https://img.shields.io/badge/Language-ArkTS-orange)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

**TANK WARFARE — BATTLE CITY 1985** 是经典 NES 游戏《坦克大战》(Battle City) 的 HarmonyOS NEXT 完整复刻。项目采用 ArkTS + Canvas 2D 纯代码绘制架构，实现 60 FPS 流畅游戏体验、10 个完整关卡、4 种敌人 AI、6 种道具系统、完整的菜单/HUD/暂停/设置/关卡选择页面、双操作模式（键盘 + 触摸）。

---

## 项目截图

> 使用 DevEco Studio 运行项目即可在模拟器或真机上体验完整效果。

---

## 技术栈

| 类别 | 技术 |
|------|------|
| **语言** | ArkTS (HarmonyOS TypeScript 方言) |
| **UI 框架** | ArkUI 声明式 UI (`@Component` + `@Builder`) |
| **渲染引擎** | Canvas 2D (`CanvasRenderingContext2D`) 纯代码绘制 |
| **应用模式** | Stage 模式 (HarmonyOS NEXT) |
| **路由导航** | `@ohos.router` (pushUrl / back) |
| **数据持久化** | `@ohos.data.preferences` (KV 存储) |
| **音频系统** | `@ohos.multimedia.media` (SoundPool) |
| **构建工具** | hvigor (HarmonyOS 原生构建系统) |
| **目标 SDK** | API 22 (HarmonyOS 6.0.2) |
| **最低兼容** | API 22 |
| **设备类型** | phone (手机) |
| **屏幕方向** | landscape (横屏) |

---

## 快速开始

### 环境要求

- **DevEco Studio**: 6.0.2 或更高版本
- **HarmonyOS SDK**: API 22+
- **设备**: 支持 HarmonyOS NEXT 的模拟器或真机

### 运行步骤

1. **克隆 / 打开项目**
   ```
   使用 DevEco Studio 打开本目录
   File → Open → 选择 MyApplication20 文件夹
   ```

2. **同步依赖**
   ```
   DevEco Studio 会自动检测 oh_modules 并同步依赖
   或手动执行: hvigorw --sync
   ```

3. **选择设备**
   ```
   在 DevEco Studio 顶部工具栏选择目标设备:
   - 模拟器: 创建或启动 Phone 模拟器（横屏，API 22）
   - 真机: USB 连接 HarmonyOS NEXT 手机
   ```

4. **运行项目**
   ```
   点击 Run 按钮 (绿色三角形) 或按 Shift+F10
   等待编译安装完成，应用将自动启动
   ```

---

## 操作指南

### 键盘操作

| 按键 | 功能 |
|------|------|
| **W** / **↑** | 向上移动 |
| **A** / **←** | 向左移动 |
| **S** / **↓** | 向下移动 |
| **D** / **→** | 向右移动 |
| **Space** | 发射子弹 |
| **J** | 暂停 / 继续 |
| **ESC** | 暂停 / 继续 / Game Over 后返回 |

### 触摸操作

| 区域 | 手势 | 功能 |
|------|------|------|
| 左侧十字键 | 点击上/下/左/右 | 控制坦克移动方向 |
| 右侧 FIRE 按钮 | 点击 | 发射子弹 |
| 右侧暂停按钮 | 点击 | 暂停 / 继续 |

---

## 项目结构

```
MyApplication20/
├── AppScope/                  # 应用全局配置
│   ├── app.json5              # 应用名、包名、版本号、SDK
│   └── resources/base/        # 全局资源（图标等）
├── entry/                     # 主模块
│   └── src/main/
│       ├── ets/
│       │   ├── components/    # 可复用 UI 组件
│       │   │   ├── DPad.ets           # 虚拟十字键
│       │   │   ├── FireButton.ets     # 开火按钮
│       │   │   ├── GameOverPanel.ets  # 游戏结束面板
│       │   │   ├── PausePanel.ets     # 暂停面板
│       │   │   └── StageClearOverlay.ets  # 通关覆盖层
│       │   ├── data/
│       │   │   └── GameTypes.ets      # 数据类型定义
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets   # 应用入口 Ability
│       │   ├── game/
│       │   │   ├── core/              # 核心引擎层
│       │   │   │   ├── GameEngine.ets     # 输入调度
│       │   │   │   ├── GameLoop.ets       # 游戏循环
│       │   │   │   ├── GameState.ets      # 状态管理器
│       │   │   │   ├── ScoreManager.ets   # 分数系统
│       │   │   │   └── StageRouter.ets    # 关卡路由
│       │   │   ├── entities/          # 实体层
│       │   │   │   ├── Bullet.ets         # 子弹实体
│       │   │   │   ├── PowerUp.ets        # 道具实体
│       │   │   │   └── Tank.ets           # 坦克实体
│       │   │   ├── levels/            # 关卡层
│       │   │   │   ├── Eagle.ets          # 基地鹰
│       │   │   │   ├── LevelData.ets      # 10关地形数据
│       │   │   │   └── LevelManager.ets   # 关卡管理器
│       │   │   ├── systems/           # 系统层
│       │   │   │   ├── AISystem.ets       # AI 系统
│       │   │   │   ├── BulletSystem.ets   # 子弹系统
│       │   │   │   ├── CollisionSystem.ets # 碰撞系统
│       │   │   │   ├── DrawHelper.ets     # 绘制辅助
│       │   │   │   ├── InputSystem.ets    # 输入系统
│       │   │   │   └── RenderSystem.ets   # 渲染系统
│       │   │   └── utils/
│       │   │       ├── Constants.ets      # 全局常量/颜色
│       │   │       └── MathUtils.ets      # 数学工具
│       │   ├── managers/
│       │   │   ├── AudioManager.ets   # 音频管理
│       │   │   └── StorageManager.ets # 持久化存储
│       │   └── pages/              # 页面
│       │       ├── GamePage.ets         # 游戏主页面
│       │       ├── Index.ets            # 占位索引
│       │       ├── LevelSelectPage.ets  # 关卡选择
│       │       ├── MainPage.ets         # 主菜单
│       │       └── SettingPage.ets      # 设置页
│       └── resources/
│           ├── base/                 # 主资源
│           │   ├── element/          # 颜色/字符串/浮点常量
│           │   ├── media/            # 图标资源
│           │   └── profile/
│           │       └── main_pages.json  # 路由注册
│           ├── dark/element/         # 暗色主题颜色
│           └── rawfile/              # 音频资源 (wav)
├── openspec/                   # 规范驱动开发文档
│   └── changes/battle-city/
│       ├── design.md           # 系统设计文档
│       ├── proposal.md         # 项目提案
│       ├── tasks.md            # 任务分解
│       └── specs/              # 8 个子系统规格
└── UI_Demo/                   # UI 设计文档
    ├── UI_Design.docx          # UI 设计规格
    └── UI_Interaction_Flow.md  # 交互流程文档
```

---

## 功能特性

### 核心玩法
- 消灭关卡中所有敌方坦克，保护下方基地（鹰）
- 10 个完整关卡，每关独立地形布局和敌人序列
- 初始 3 条生命，每 20000 分奖励 1 条生命

### 敌人 AI（4 种类型）
| 类型 | 名称 | 特征 | 分值 |
|------|------|------|------|
| LIGHT | 轻型坦克 | 基础速度，1 HP | 100 |
| ARMORED_CAR | 装甲车 | 快速移动 | 200 |
| FAST_SHOT | 速射型 | 高开火频率 | 300 |
| HEAVY | 重甲坦克 | 4 HP，颜色随血量变化 | 400 |

### 道具系统（6 种）
| 道具 | 效果 |
|------|------|
| ⭐ 星 | 火力升级（最高双发） |
| 💣 手雷 | 全灭场上所有敌人 |
| 🛡 头盔 | 10 秒无敌护盾 |
| ⏱ 时钟 | 冻结所有敌人 8 秒 |
| 🚧 铲子 | 基地加固为钢墙 15 秒 |
| ❤️ 坦克 | 额外生命 +1 |

### 6 种地形
- 空地 (EMPTY) — 可自由通行
- 砖墙 (BRICK) — 可被子弹摧毁
- 钢墙 (STEEL) — 仅穿甲弹可摧毁
- 树木 (TREES) — 坦克可通行（视觉遮挡）
- 水域 (WATER) — 不可通行
- 冰面 (ICE) — 滑行效果

### UI 与操作
- 主菜单 / 关卡选择 / 设置 3 个独立页面
- 游戏内暂停面板（继续 / 返回主菜单）
- 开场关卡动画（STAGE XX → READY? → GO!）
- 关卡通关过渡动画（STAGE CLEAR）
- 游戏结束画面（GAME OVER）
- 键盘 + 触摸双操作模式
- HUD 信息栏（剩余敌人数、生命数）

### 视听效果
- BGM（菜单 / 战斗）循环播放
- SFX（开火 / 爆炸 / 拾取道具 / 通关 / 游戏结束）
- 独立 BGM / SFX 音量控制
- 爆炸粒子特效
- 护盾波纹环特效
- 道具拾取彩色粒子爆发
- 赛博朋克暗色军事美学设计

### 数据持久化
- 关卡进度保存
- 最高分记录

---

## 设计主题

整体采用 **赛博朋克暗色军事风格**：

| 页面 | 主背景 | 强调色 |
|------|--------|--------|
| 主菜单 | `#060B14` | `#00E676` (绿) / `#FFD54F` (金) |
| 关卡选择 | `#050B14` | 10 关独立颜色 |
| 设置 | `#050B14` | `#FF00FF` (品红) |
| 游戏页面 | `#0D0D1A` / `#D6EAF8` | `#00E5FF` (青) |

---

## 设计文档

- [UI 设计规格](UI_Demo/UI_Design.docx) — 含 6 种界面状态设计、布局尺寸标注、浅色/深色双版本
- [交互流程文档](UI_Demo/UI_Interaction_Flow.md) — 状态流转图、交互路径、手势说明
- [系统设计文档](openspec/changes/battle-city/design.md) — 架构决策记录
- [项目提案](openspec/changes/battle-city/proposal.md) — 项目概述

---

## 许可证

MIT License — 仅供学习与展示使用。

---

**TΛNK WΛRFΛRE · BΛTTLE CITY 1985** · HarmonyOS NEXT
