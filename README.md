
## Project Template (Vivado)

这个仓库是一个 Vivado 工程模板，用于快速创建一个包含空 Block Design 的工程。

### 目录结构

- `scripts/`
  - `create_project.tcl`：创建工程，清理并重建 `build/`，然后调用 `src/create_bd.tcl`
- `src/`
  - `create_bd.tcl`：创建并保存空的 `block_design`
- `constraint/`
  - 预留给 `.xdc` 约束文件
- `ip_core/`
  - 预留给自定义 IP 或 IP 打包输出
- `build/`
  - Vivado 自动生成的工程目录（运行脚本后生成）

### 当前默认配置

- `project_name`: `my_project`
- `project_part`: `xc7a100tftg256-2`
- `bd_name`: `block_design`

### 使用方法

在 Vivado Tcl Console 中执行：

```tcl
cd <repo>/scripts
source create_project.tcl
```

或命令行批处理运行：

```powershell
vivado -mode batch -source .\scripts\create_project.tcl
```

执行后会：

1. 删除并重建 `build/`
2. 创建工程 `my_project`
3. 创建空 Block Design `block_design`

### 注意事项

- `create_project.tcl` 每次运行都会清空 `build/`，不要把未备份结果放在该目录。
- 该模板当前不自动添加 HDL 源码/约束文件，需要后续手动添加或扩展 Tcl。
