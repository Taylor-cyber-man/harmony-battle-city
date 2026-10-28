# 鸿蒙应用开发课程升级工程化作业：Battle City 1985 复刻

**课程名称**：鸿蒙应用开发与实践  
**学期**：2025-2026 学年第二学期  
**截止日期**：2026年5月28日 23:59  
**提交方式**：课程平台 / GitHub（可选）
**总分**：100分

## 一、作业背景

Battle City（坦克大战）是1985年由Namco发行的经典坦克射击游戏，以其简单的操作、丰富的关卡设计和双人合作模式而闻名。本作业要求使用 HarmonyOS DevEco Studio 6.02 和 ArkTS 语言，完整复刻这款经典游戏，并采用工程化的开发流程。

通过本次作业，你将：
1. 掌握 HarmonyOS 应用开发的核心技术
2. 实践游戏开发的基本原理（游戏循环、碰撞检测、AI行为等）
3. 学习使用 OpenSpec 进行规范驱动的开发
4. 体验完整的软件工程流程（需求分析、设计、实现、测试、文档）

## 二、作业目标

使用 HarmonyOS DevEco Studio 6.02 开发环境，基于 ArkTS 语言，工程化实现 Battle City 1985 版本的核心功能，包括：

1. 玩家坦克控制（8方向移动、射击）
2. 敌人AI系统（不同类型坦克、智能行为）
3. 关卡系统（可破坏地形、基地保护）
4. 碰撞检测系统
5. 得分和生命值系统
6. 能量提升系统
7. 完整的UI界面（菜单、HUD、控制）
8. 头三关玩法

## 三、技术要求

### 3.1 开发环境
- **必须使用**：DevEco Studio 6.02（最新稳定版）
- **编程语言**：ArkTS（TypeScript for HarmonyOS）
- **目标API版本**：API 22
- **测试设备**：HarmonyOS 模拟器或真机

### 3.2 OpenSpec 配置要求
- 安装 OpenSpec 工具并配置到 DevEco Studio 项目中
- 使用 OpenSpec 管理项目规范文档
- 按照 OpenSpec 的规范结构组织需求、设计和任务
- 提交完整的 OpenSpec 文件结构

### 3.3 功能要求（参考 OpenSpec 规范）

#### 3.3.1 游戏引擎核心
- 实现稳定的游戏循环（60 FPS）
- 游戏状态管理（初始化、运行、暂停、结束）
- 资源加载和内存管理

#### 3.3.2 玩家坦克控制
- 支持触摸/手势控制的8方向移动
- 坦克射击系统（冷却时间、子弹轨迹）
- 碰撞响应（与障碍物、敌人子弹）

#### 3.3.3 敌人AI系统
- 至少3种不同类型的敌人坦克
- 智能寻路和避障
- 基于难度的射击精度
- 敌人生成和重生机制

#### 3.3.4 关卡设计系统
- 至少实现10个不同关卡
- 可破坏地形系统（砖墙、钢墙）
- 玩家基地保护机制
- 关卡进度保存

#### 3.3.5 碰撞检测系统
- 高效的坦克-子弹-地形碰撞检测
- 边界检测和处理
- 碰撞响应（伤害计算、地形破坏）

#### 3.3.6 得分和进度系统
- 分数计算（基于敌人类型）
- 生命值管理系统
- 关卡完成和进度保存
- 游戏存档/读档功能

#### 3.3.7 能量提升系统
- 至少4种不同的能量提升（加速、护盾、增强火力等）
- 能量提升生成和收集机制
- 临时效果和过期处理

#### 3.3.8 UI/UX组件
- HarmonyOS原生风格的UI设计
- 完整的游戏HUD（分数、生命值、关卡、能量状态）
- 主菜单、设置界面、游戏暂停/结束界面
- 直观的触摸控制界面

## 四、工程化进阶要求

### 4.1 方便批改（20分）
- 代码结构清晰，模块化设计良好
- 遵循 HarmonyOS 开发规范
- 关键函数和类有清晰的注释
- 代码可读性强，命名规范

### 4.2 提交工程文件（20分）
- 完整的 DevEco Studio 项目文件
- 所有源代码（.ets、.ts、.json 等）
- 资源文件（图片、音效、配置文件）
- 构建配置文件（build-profile.json5、module.json5 等）
- 测试文件和测试数据

### 4.3 设计UI DEMO（20分）
- 提供完整的UI设计稿或原型
- 说明UI组件的布局和交互逻辑
- 展示不同状态下的UI表现（游戏进行、暂停、结束等）
- 符合 HarmonyOS 设计语言规范

### 4.4 完成的视频效果（20分）
- 录制游戏运行视频（必须为屏幕录制，禁止手机拍摄）
- 视频内容需展示：
  - 游戏启动和主菜单
  - 玩家坦克控制
  - 敌人AI行为
  - 关卡切换
  - 能量提升效果
  - 游戏结束和得分显示
- 视频时长：3-5分钟
- 视频格式：MP4 或 MOV
- 视频分辨率：不低于 1080p

### 4.5 OpenSPEC完整文件（20分）
- 完整的 OpenSpec 规范文档，包括：
  - `specs/battle-city/spec.md`：完整的需求规范
  - `changes/battle-city/proposal.md`：项目提案
  - `changes/battle-city/design.md`：系统设计文档
  - `changes/battle-city/tasks.md`：详细的任务分解
  - `config.yaml`：OpenSpec 配置文件
- 所有规范文档需保持最新，与实现代码一致
- 规范文档需使用中文编写，格式规范

## 五、提交内容

提交一个压缩包，包含以下内容：

```
BattleCity_StudentID_Name.zip
├── BattleCity/                    # DevEco Studio 项目目录
│   ├── entry/                    # 主模块
│   ├── AppScope/                 # 应用级配置
│   ├── oh_modules/              # 依赖模块
│   ├── openspec/                 # OpenSpec 规范目录
│   │   ├── specs/
│   │   │   └── battle-city/
│   │   │       └── spec.md
│   │   ├── changes/
│   │   │   └── battle-city/
│   │   │       ├── proposal.md
│   │   │       ├── design.md
│   │   │       └── tasks.md
│   │   └── config.yaml
│   └── hvigor/                   # 构建配置
├── UI_Demo/                      # UI设计文档
│   ├── UI_Design.pdf            # UI设计稿
│   └── UI_Interaction_Flow.md   # 交互流程图
├── Video/                        # 演示视频
│   └── BattleCity_Demo.mp4      # 游戏演示视频
├── README.md                     # 项目说明文档
└── Report.pdf                    # 项目报告（可选）
```

## 六、评分标准

| 评分项 | 分值 | 评分标准 |
|--------|------|----------|
| **功能完整性** | 30分 | 所有核心功能完整实现，游戏可正常运行 |
| **代码质量** | 20分 | 代码结构清晰，注释完整，符合规范 |
| **UI/UX设计** | 15分 | 界面美观，交互流畅，符合HarmonyOS设计语言 |
| **工程化实践** | 20分 | OpenSpec使用规范，项目结构合理 |
| **演示视频** | 10分 | 视频清晰，内容完整，展示全面 |
| **文档完整性** | 5分 | 所有要求文档齐全，格式规范 |

**额外加分项（最多10分）**：
- 实现双人合作模式（+5分）
- 实现关卡编辑器（+5分）
- 实现在线排行榜（+5分）
- 性能优化优秀（帧率稳定，内存占用低）（+5分）

## 七、参考资料

### 7.1 HarmonyOS 官方文档
- [HarmonyOS 应用开发文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/start-overview-0000001478061421-V3)
- [ArkTS 语言指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkts-get-started-0000001504925041-V3)
- [ArkUI 开发指南](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/arkui-overview-0000001504924801-V3)

### 7.2 OpenSpec 使用指南
- OpenSpec 安装命令：`npm install -g openspec`
- OpenSpec 初始化：`openspec init`
- 创建规范：`openspec new battle-city`
- 查看帮助：`openspec --help`

### 7.3 Battle City 参考资料
- 原版游戏视频：https://www.youtube.com/watch?v=示例
- 游戏机制分析：https://en.wikipedia.org/wiki/Battle_City_(video_game)
- 开源实现参考：https://github.com/search?q=battle+city+clone

### 7.4 开发工具
- DevEco Studio 下载：https://developer.harmonyos.com/cn/develop/deveco-studio
- HarmonyOS 模拟器：https://developer.harmonyos.com/cn/develop/deveco-studio#download_emu
- OpenSpec 文档：https://openspec.dev/

## 八、注意事项

1. **禁止抄袭**：所有代码必须独立完成，引用第三方代码需明确注明出处
2. **按时提交**：逾期提交将按课程规定扣分
3. **代码规范**：遵循 ArkTS 编码规范，使用 ESLint 检查
4. **兼容性**：确保应用在 API 9+ 的设备上正常运行
5. **性能要求**：游戏帧率不低于 30 FPS，内存使用合理
6. **问题反馈**：遇到技术问题可在课程论坛提问，或预约助教答疑

## 九、FAQ

**Q: OpenSpec 是什么？为什么要使用它？**  
A: OpenSpec 是一个规范驱动的开发工具，可以帮助你更好地管理需求、设计和任务。通过使用 OpenSpec，你可以学习工程化的开发流程，提高代码质量和可维护性。

**Q: 游戏必须完全复刻原版吗？可以添加新功能吗？**  
A: 核心功能必须完整实现原版 Battle City 1985。在完成基本要求后，可以添加创新功能作为额外加分项。

**Q: 可以使用第三方游戏引擎吗？**  
A: 不允许使用第三方游戏引擎（如 Unity、Cocos2d-x）。必须使用 HarmonyOS 原生 Canvas 2D 或 ArkUI 实现。

**Q: 团队合作允许吗？**  
A: 本作业为个人作业，必须独立完成。如需团队合作，请提前向老师申请。

**Q: 如何确保视频是屏幕录制而非手机拍摄？**  
A: 视频中需包含 DevEco Studio 的运行界面或明显的屏幕录制特征。手机拍摄的视频将不予评分。

---

**祝各位同学顺利完成作业，在鸿蒙应用开发的道路上更进一步！**
