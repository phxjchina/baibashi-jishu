---
title: "Python 造世界（二）：给世界加上反馈与涨落"
column: "S8-世界模型与系统论"
series: "扩展线"
order: 413
label: "主线4-13-Python造世界二反馈与涨落"
date: 2026-10-19
source: "系统论世界模型产物包·扩展线"
status: published
tags: ['Python', '世界模型', '负反馈', '相变', '自组织']
description: "上篇的 60 行最小系统其实\"偷偷\"带了反馈和涨落：0.2diff 让 Agent 向邻居靠拢、noise 是高斯扰动。但那只是局部规则、温……"
---

# Python 造世界（二）：给世界加上反馈与涨落

上篇的 60 行最小系统其实"偷偷"带了反馈和涨落：`0.2*diff` 让 Agent 向邻居靠拢、`noise` 是高斯扰动。但那只是局部规则、温和扰动。这篇把**反馈**和**涨落**升级成显式、可调的机制——让世界更像一个"活系统"，而不是一个碰巧会动的程序。

## 一、名-实对应

- **显式反馈环**：不只局部向邻居靠拢，而是设一个"全局设定点（setpoint）"——系统被一股力持续拉向某个目标状态。这是**负反馈**的强版，也是"目的性原理"的工程化身：系统有了"想去的 attractor（吸引子）"。
- **涨落放大**：把"小噪声"升级为"偶发大冲击"——平时温和扰动，偶尔来一下够强的 shock，可能把系统从旧稳态**推过阈值**翻到新稳态。这正是"涨落有序律"的强版：秩序能从一次大波动里长出来（相变）。

## 二、扩展代码（在最小系统上加两个机制）

```python
import random, math

class WorldModelV2:
    def __init__(self, n=8, inflow=1.0, decay=0.05, synergy=0.3,
                 capacity=80.0, setpoint=60.0, fb_gain=0.05,
                 shock_prob=0.03, shock_mag=15.0):
        self.n = n; self.inflow = inflow; self.decay = decay
        self.synergy = synergy; self.capacity = capacity
        self.setpoint = setpoint      # 目的性：系统趋向的全局目标
        self.fb_gain = fb_gain        # 负反馈增益
        self.shock_prob = shock_prob  # 涨落放大：大冲击概率
        self.shock_mag = shock_mag    # 冲击强度
        self.k = [random.uniform(1.0, 3.0) for _ in range(n)]

    def step(self):
        new_k = self.k[:]
        total = sum(self.k)
        for i in range(self.n):
            # 1) 开放性：环境输入 + 温和涨落
            noise = random.gauss(0, 0.1)
            new_k[i] += self.inflow + noise

            # 2) 显式负反馈：向全局设定点拉（目的性 / 信息反馈律）
            new_k[i] += self.fb_gain * (self.setpoint - total / self.n)

            # 3) 局部交换（沿用上篇）
            left  = self.k[(i - 1) % self.n]
            right = self.k[(i + 1) % self.n]
            new_k[i] += 0.2 * ((left + right) / 2.0 - self.k[i])

            # 4) 自组织协同（沿用上篇）
            if self.k[i] > 5.0:
                new_k[i] += self.synergy * math.log1p(self.k[i])

            # 5) 涨落放大：偶发大冲击，可能触发相变
            if random.random() < self.shock_prob:
                new_k[i] += random.choice([-1, 1]) * self.shock_mag

            # 6) 稳定性：非负 + 有界
            new_k[i] = max(0.0, new_k[i])
            new_k[i] = min(new_k[i], self.capacity)
            new_k[i] -= self.decay * new_k[i]
        self.k = new_k
```

## 三、逐行解读：两个新机制

**显式负反馈（`fb_gain * (setpoint - 均值)`）**

上篇的反馈是"向邻居均值靠拢"，没有全局目标。这里加了一个**全局设定点**：系统被持续拉向 `setpoint`。`fb_gain` 越大，拉得越急。`setpoint` 就是"目的性原理"落地的样子——系统不再是随机游走，而是有个"想去的地方"（吸引子）。调大 `setpoint`，整个世界的饱和值会整体抬升。

**涨落放大（`shock_prob` / `shock_mag`）**

`shock_prob` 控制"多大概率来一下大冲击"，`shock_mag` 控制"冲击有多狠"。平时温和，偶尔狠一下——这一下如果够强，可能把某个 Agent 从旧稳态**推过阈值**，触发协同项的复利增长，翻到全新的更高稳态。这正是 A 专题讲的"稳态盆地"与"突变性（跳变）"：系统平时在盆地里晃，一次大冲击把它甩进隔壁盆地。

## 四、为什么这步重要

加了显式反馈与涨落，世界从"会动"变成"**有目标、能跳变**"：

- **有目标** → 对应目的性、信息反馈律（主线2-05 五机制里的"信息反馈机制"）；
- **能跳变** → 对应突变性、涨落有序律（五机制里的"涨落有序机制"）；
- 两者合起来，你才真正拥有一个"活系统"，而不是一个收敛到死点的程序。

对照真实世界：一个组织、一种文化，也是在"被目标吸引"和"被偶然冲击改写"之间摆动的——金观涛的超稳定结构，本质就是"反馈太强、冲击进不去"的极端态（见主线5-17）。

## 五、落点

本篇让最小系统长出了"目的"与"突变"两条生命特征。下一篇，我们讲怎么**看**这个会跳变的世界——可视化与指标，把"守没守规矩"变成能一眼读出的曲线。

（扩展代码零外部依赖，可接上篇 `WorldModel` 直接运行对比。）

---

**版权声明**

© 2026 彭老师 · 首发于 [baibashi-jishu](https://github.com/phxjchina/baibashi-jishu)

本文采用 [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) 许可协议：
可自由阅读与转发（须署名并注明出处），**禁止商业使用、禁止改写与演绎**。
