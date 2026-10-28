# 得分和进度系统 (score-progression-system)

## ADDED Requirements

### Requirement: 分数计算
系统 SHALL 根据摧毁的敌人类型给予不同分数：轻型坦克 100 分、装甲车 200 分、速射炮坦克 300 分、重型坦克 400 分。

#### Scenario: 计分显示
- **WHEN** 玩家摧毁一辆轻型坦克
- **THEN** 分数增加 100 并在销毁位置短暂显示 "+100" 浮动文字（持续 30 帧后消失）

#### Scenario: 道具收集计分
- **WHEN** 玩家收集任意道具
- **THEN** 分数增加 500 分

### Requirement: 生命值管理
系统 SHALL 管理玩家生命值，初始 3 条命，每获得 20000 分奖励一条命，被敌弹击中失去一条命。

#### Scenario: 初始生命
- **WHEN** 新游戏开始
- **THEN** 玩家拥有 3 条命，HUD 显示 3 个红色心形图标

#### Scenario: 加分奖励生命
- **WHEN** 玩家总分每达到 20000 的整数倍
- **THEN** 生命值 +1，HUD 更新心形图标数量，播放加命音效

#### Scenario: 生命归零游戏结束
- **WHEN** 玩家生命值降为 0
- **THEN** 游戏状态转为 GAME_OVER

### Requirement: 关卡进度保存与读档
系统 SHALL 使用 HarmonyOS Preferences API 存储和读取关卡进度（当前关卡编号）和历史最高分。

#### Scenario: 进度保存
- **WHEN** 玩家完成一关
- **THEN** 将当前关卡编号 +1 存入 Preferences，键名为 "stage_progress"

#### Scenario: 最高分保存
- **WHEN** 游戏结束时当前分数大于已存储的最高分
- **THEN** 更新 Preferences 中 "high_score" 的值

#### Scenario: 读档恢复
- **WHEN** 应用启动或进入主菜单
- **THEN** 从 Preferences 读取 "stage_progress" 和 "high_score" 并在 UI 中显示

### Requirement: 关卡通关判定
系统 SHALL 在当前关卡 20 辆敌人全部被消灭时判定通关，显示过关界面，2 秒后自动进入下一关。

#### Scenario: 过关触发
- **WHEN** 本关第 20 辆敌人被摧毁
- **THEN** 关卡完成，显示 "STAGE CLEAR" 文字 + 当前总分，2 秒后加载下一关

#### Scenario: 通关后重新开始
- **WHEN** 通过最后一关（Stage 10）
- **THEN** 显示祝贺文字，循环回 Stage 1（二周目，敌人难度提高）
