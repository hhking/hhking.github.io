---
title: Git 分支开发规范
subtitle: Git Branch Guideline
issue: 47
date: 2019-12-28 11:30:39
categories: ['Git']
tags: ['Git']
---

## 前言
最近在整理文档和一些团队规范，整理了一下团队中使用 Git 的一些规范。

> 规范的制定，要根据不同团队和场景

## 分支命名

### master 分支
- `master` 是主分支，用于部署线上生产环境
- `master` 分支由 `release`、`hotfix` 分支合并，禁止直接修改

### release 分支
- `release` 是预发布分支，对应部署预发布环境
- `release` 分支一般由 `develop` 分支合并
- `release` 分支完成测试上线时，要分别合并到 `master` 和 `develop` 分支

### develop 分支
- `develop` 为开发分支，对应部署测试环境
- `develop` 分支需要保持最新和 bug 修复后的代码

### feature 分支
- 开发新功能时，从 `develop` 分支创建新的功能分支
- 功能分支都以 `feature/` 开头，命名规则：`feature/** `，例如：`feature/user-center`
- 功能完成后合并到 `develop` 分支测试，并删除对应的功能分支

### hotfix 分支
- 紧急修复 bug 分支，从 `master` 分支创建
- 命名以 `hotfix/` 开头，例如：`hotfix/user-bug`
- bug 修复完成后，要分别合并到 `master` 和 `develop` 分支


### 注意点
- 为了保证 `develop` 分支是最新的，develop 在合并到 release 时，先合并一下 master 分支，可以避免之前忘记 release 或者 hotfix 合并到 develop
- 设置 master 为保护分支，控制权限
- 上线要合并到 master 时，通过在 gitlab 上提 Merge Request 给对应的管理员来操作
- 分支命名以 `/` 划分可以在 GUI 工具中分成一个目录分类
- 具体的操作流程要根据团队来调整


## 提交规范

### 日志规范
编写清晰良好的 commit message ，可以提高可读性，方便查看提交历史记录

业界广泛采用的一种规范是 [ Angular Git Commit Guidelines](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)

在实际使用中，我们可以根据团队的情况来使用，例如简化使用：

```
<type>: <subject>
```

type的类别说明:
- feat: 添加新特性
- fix: 修复bug
- docs: 仅仅修改了文档
- style: 仅仅修改了空格、格式缩进、都好等等，不改变代码逻辑
- refactor: 代码重构，没有加新功能或者修复bug
- perf: 增加代码进行性能测试
- test: 增加测试用例
- chore: 改变构建流程、或者增加依赖库、工具等

subject 主要写清楚这次更新或者修改的内容

### commit
完成一个功能点或者完成一次完整的修改后，再提交 commit。

