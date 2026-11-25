# architecture/module-boundaries Specification

## Purpose

为应用模块建立稳定且可自动检查的依赖方向，避免 UI 组件与业务功能反向绑定应用组合根，并确保跨模块调用通过明确的公共入口发生。

## Requirements

### Requirement: 下层模块不得依赖应用组合根

components、features、foundation、network、routing 与 utils 中的代码 MUST NOT 直接 import app_shell 或 app_runtime；所需能力 SHALL 通过下层公共契约、参数或回调注入。

#### Scenario: 扫描现有模块依赖

- **WHEN** 维护者运行仓库结构 import 检查
- **THEN** 检查不报告上述模块指向 app_shell 或 app_runtime 的受限 import

#### Scenario: 下层模块需要工作区能力

- **WHEN** components 或 features 中的实现需要导航、窗口或工作区能力
- **THEN** 该实现通过公共契约或注入能力获得对应行为，而不是引用组合根实现

### Requirement: 跨模块调用使用 feature 公共入口

一个模块调用另一个 feature 暴露的页面或能力时 SHALL 使用该 feature 声明的公共入口，MUST NOT 绕过入口直接 import 其实现文件。

#### Scenario: 工作区打开搜索页面

- **WHEN** app_shell 或 favorites 引用 search feature 的搜索页面、聚合搜索页面或搜索结果页面
- **THEN** 引用通过 search feature 公共入口完成

#### Scenario: 扫描 feature 入口

- **WHEN** 维护者运行仓库结构 import 检查
- **THEN** 检查不报告 search feature 的入口违规

### Requirement: 库文件边界 inventory 保持完整

`lib/` 下每个 Dart 库文件 MUST 在架构基线中恰好登记为 business、UI 或 pending review 之一；新增、移动或删除库文件时 SHALL 同步更新 inventory。inventory MUST NOT 通过忽略规则、修改检查脚本或把业务文件归入 pending review 来规避既有违规。

#### Scenario: 扫描库文件分类

- **WHEN** 维护者运行架构依赖检查
- **THEN** 每个库文件都有唯一分类且没有未分类文件
- **AND** 新增 feature 之间的依赖边必须已在允许列表中登记

#### Scenario: 搬迁共享 UI 文件

- **WHEN** 一个已被分类的库文件移动到新目录
- **THEN** inventory 同步登记新路径，旧路径不残留
