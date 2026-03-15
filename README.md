
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

```powershell
vivado -mode batch -source .\scripts\package_ip.tcl
vivado -mode batch -source .\scripts\create_project.tcl
```


