# TidyFriday统计程序软件归档

> 正在开发中！请谨慎使用！

这里存放在 ssc 上所有的 Stata 命令以及我从 GitHub 上搜集的各种 Stata 命令，另外也托管用户自编的 Stata 命令（带中文帮助文档的也可以），欢迎大家关注“Stata中文社区”获取最新资讯和动态！

<div align="center">
	<img src="https://czxa.github.io/tssc/assets/qrcode_for_gh_97f81c8af6d6_258.jpg" width="30%"/>
</div>

## 安装 tssc 命令

> 暂时没有编写！

```stata
* 从 GitHub 上安装：
* net install tssc.pkg, from("https://czxa.github.io/tssc/")
```

## 安装 tssc 部署的 Stata 外部命令

以 spmap 为例：

```stata
* 从 Gitee 上安装：
net install spmap.pkg, from("https://tidyfriday.gitee.io/tssc/ssc/spmap/") replace force
* 如果提示 Web Error 可以尝试从 GitHub 上安装：
net install spmap.pkg, from("https://czxa.github.io/tssc/ssc/spmap/") replace force
```

------------

<h4 align="center">License</h4>
<h6 align="center">MIT © tidyfriday.cn</h6>
