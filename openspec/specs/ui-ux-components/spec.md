# UI/UX 组件 (ui-ux-components)

## ADDED Requirements

### Requirement: 主菜单界面
系统 SHALL 提供主菜单界面，包含游戏标题 "BATTLE CITY"（像素风格字体）、"开始游戏"按钮、"关卡选择"按钮、"设置"按钮，支持浅色/深色主题。

#### Scenario: 主菜单进入
- **WHEN** 应用启动
- **THEN** 显示主菜单，标题动画（字体逐行显示），3 个按钮可用

#### Scenario: 开始游戏
- **WHEN** 玩家点击"开始游戏"按钮
- **THEN** 从 Stage 1 开始加载游戏，或从存档恢复进度

#### Scenario: 关卡选择
- **WHEN** 玩家点击"关卡选择"
- **THEN** 显示已解锁关卡的网格选择界面（Stage 1-N）

### Requirement: 游戏 HUD
系统 SHALL 在横屏游戏区顶部显示 HUD 信息栏（约 50 px 高，横向排列），包含当前关卡编号、敌人剩余计数（图标矩阵）、玩家生命（心形图标）、当前分数。

#### Scenario: HUD 实时更新
- **WHEN** 敌人被摧毁
- **THEN** 敌人剩余计数图标从红色变为灰色

#### Scenario: 分数更新
- **WHEN** 玩家获得分数
- **THEN** HUD 分数数字实时递增显示

### Requirement: 横屏游戏布局
系统 SHALL 使用固定横屏 LANDSCAPE 模式，布局为三列结构：左侧 D-Pad 十字键区域 (~18%)、中间游戏地图区域 (layoutWeight 自动填充)、右侧开火 + 暂停区域 (~12%)。D-Pad 采用 4 个独立触摸按钮（↑↓←→）+ 中央死区，按下即走、松开即停，对角线 = 同时按下相邻两键。通过 `module.json5` 的 `"orientation": "landscape"` 和运行时 `setPreferredOrientation(LANDSCAPE)` 双重锁定横屏。

#### Scenario: 横屏锁定
- **WHEN** 应用启动进入游戏
- **THEN** 屏幕方向固定为横屏，不随设备旋转改变

#### Scenario: 三列布局
- **WHEN** 游戏页面渲染
- **THEN** 左侧显示 D-Pad 十字键、中间显示 Canvas 地图、右侧显示开火和暂停按钮

#### Scenario: 中间区域自适应
- **WHEN** 设备屏幕尺寸不同
- **THEN** 中间地图区域通过 `layoutWeight(1)` 自动占据方向键和开火按钮之间的全部剩余空间

### Requirement: D-Pad 十字键触摸控制
系统 SHALL 在左侧 18% 区域实现 D-Pad 十字键控制。4 个方向键（↑↓←→）各自独立绑定 `onTouch` 事件（Down=按下移动, Up=松开停止）。使用 `Set<number>` 记录当前按下的键码，每帧读取计算方向向量。对角线由同时按下相邻两键自然合成。中央设置死区防止误触。

#### Scenario: 单方向移动
- **WHEN** 玩家按下 D-Pad ↑ 键
- **THEN** 坦克开始向上移动；松开该键时停止向上

#### Scenario: 对角线移动
- **WHEN** 玩家同时按住 D-Pad ↑ 键和 → 键
- **THEN** 坦克以合成速度向右上对角线移动

#### Scenario: 即按即走
- **WHEN** 玩家触摸按下任意 D-Pad 方向键
- **THEN** 坦克立即开始移动，无需拖动动作

#### Scenario: 松手即停
- **WHEN** 玩家松开所有 D-Pad 方向键
- **THEN** 坦克立即停止移动，无惯性

#### Scenario: 死区不触发
- **WHEN** 玩家手指触摸 D-Pad 中央死区
- **THEN** 不触发任何方向，坦克保持当前状态

### Requirement: 动态画布尺寸
系统 SHALL 通过 ArkUI 通用事件 `onAreaChange` 动态计算 Canvas 画布尺寸：`TILE_SIZE = Math.floor(Math.min(availW / 13, availH / 13))`，画布总像素 = `TILE_SIZE × 13`。全 13×13 地图始终完整显示，不做任何缩放或裁剪。

#### Scenario: 动态计算 tile 尺寸
- **WHEN** 中间 Column 的 onAreaChange 回调触发
- **THEN** 取可用宽高中较小值除以 13 并取整，作为每个 metatile 的像素尺寸

#### Scenario: 全地图显示
- **WHEN** Canvas 渲染
- **THEN** 画布尺寸恰好容纳 13×13 个 tile，地图完整可见，无滚动或裁剪

### Requirement: 游戏暂停界面
系统 SHALL 提供暂停界面，半透明遮罩覆盖游戏画面，显示"PAUSED"标题、"继续"、"重新开始"、"返回主菜单"按钮。

#### Scenario: 暂停触发
- **WHEN** 玩家点击暂停按钮
- **THEN** 游戏画面变暗（50% 黑色遮罩），显示暂停面板

#### Scenario: 继续游戏
- **WHEN** 玩家在暂停界面点击"继续"
- **THEN** 遮罩消失，游戏状态恢复 RUNNING

### Requirement: 游戏结束界面
系统 SHALL 在游戏结束时显示"GAME OVER"标题、最终得分、最高分对比、"重新开始"和"返回主菜单"按钮。

#### Scenario: 游戏结束显示
- **WHEN** 游戏状态转为 GAME_OVER
- **THEN** 显示 GAME OVER 动画（文字滑入），最终得分从 0 滚动至实际值

#### Scenario: 重新开始
- **WHEN** 玩家点击"重新开始"
- **THEN** 从 Stage 1 重新开始，生命和分数重置

### Requirement: 开火按钮与暂停按钮
系统 SHALL 在右侧 12% 区域放置圆形射击按钮和暂停按钮。射击按钮绑定 `onTouch`（Down=发射，松开停止连续射击），与键盘空格键行为一致、冷却共享。暂停按钮点击切换游戏暂停/恢复。

#### Scenario: 射击按钮按下
- **WHEN** 玩家按下右侧射击按钮
- **THEN** 按钮视觉变深，坦克发射子弹

#### Scenario: 射击按钮与空格共享冷却
- **WHEN** 玩家按下射击按钮或空格键
- **THEN** 两者共享同一个冷却计时器，500ms 内无法重复发射

#### Scenario: 触控区域不遮挡地图
- **WHEN** 游戏正常运行
- **THEN** D-Pad 和射击按钮分别位于地图左右两侧，地图区域完全可见无遮挡

### Requirement: 关卡完成界面
系统 SHALL 在关卡通关时显示"STAGE CLEAR"标题、当前得分汇总（含各类型杀敌数统计），2 秒后自动过渡到下一关。

#### Scenario: 过关界面
- **WHEN** 本关 20 辆敌人全部消灭
- **THEN** 显示半透明遮罩 + "STAGE CLEAR" 大字 + 杀敌统计（轻型×N, 装甲×N, 速射×N, 重型×N），2 秒倒计时后自动切换关卡

### Requirement: 设置界面
系统 SHALL 提供设置界面，支持音量调节（滑块）、控制灵敏度调节、主题切换（浅色/深色）。

#### Scenario: 音量调节
- **WHEN** 玩家拖动音量滑块
- **THEN** 游戏音效和背景音乐音量实时变化

#### Scenario: 主题切换
- **WHEN** 玩家切换浅色/深色主题
- **THEN** 所有 UI 元素（菜单、HUD、按钮）立即切换为对应配色方案
