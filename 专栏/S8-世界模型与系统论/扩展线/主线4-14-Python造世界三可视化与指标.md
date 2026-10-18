---
title: "Python 造世界（三）：观察你的世界——可视化与指标"
column: "S8-世界模型与系统论"
series: "扩展线"
order: 414
label: "主线4-14-Python造世界三可视化与指标"
date: 2026-10-19
source: "系统论世界模型产物包·扩展线"
status: published
tags: ['Python', '世界模型', '可视化', '指标', '可观测性']
description: "能跑、能跳变还不够。你造的世界模型，得能被\"看见\"、被\"度量\"，才知道它守没守系统论的规矩。这篇给最小系统加上指标与可视化——把\"守没守规矩……"
---

# Python 造世界（三）：观察你的世界——可视化与指标

能跑、能跳变还不够。你造的世界模型，得能被"看见"、被"度量"，才知道它守没守系统论的规矩。这篇给最小系统加上**指标**与**可视化**——把"守没守规矩"变成能一眼读出的数字和曲线。

## 一、名-实对应

- **指标（metric）**：把"守规矩没"翻译成可量化数字。例：总知识（整体性）、基尼系数（分布均衡＝反馈律是否生效）、熵（无序/多样性＝涨落是否健康）、收敛度（是否到稳态＝稳定性）。
- **可视化**：把演化画成曲线/热图。相变、稳态、发散，肉眼一扫就懂。
- 一句话：**可观测，才谈得上可验证。** 你先"看见"系统越没越界，才谈得上去"证明"它不越界（主线3）。

## 二、代码：指标 + 可选可视化

```python
def metrics(self):
    k = self.k
    total = sum(k)
    mean = total / len(k)
    # 基尼系数：衡量知识分布是否均衡（反馈律的体检）
    sorted_k = sorted(k)
    n = len(k)
    cum = sum((i + 1) * x for i, x in enumerate(sorted_k))
    gini = (2 * cum) / (n * total) - (n + 1) / n if total > 0 else 0
    # 熵：衡量无序/多样性（涨落是否健康）
    ps = [x / total for x in k if x > 0]
    entropy = -sum(p * math.log(p) for p in ps)
    return {"total": total, "gini": gini, "entropy": entropy, "mean": mean}

def snapshot(self, steps=80, plot=True):
    totals, ginis = [], []
    for _ in range(steps):
        self.step()
        m = self.metrics()
        totals.append(m["total"]); ginis.append(m["gini"])
    if plot:
        try:
            import matplotlib.pyplot as plt
            plt.plot(totals, label="总知识"); plt.plot(ginis, label="基尼")
            plt.legend(); plt.title("世界演化观测"); plt.show()
        except ImportError:
            print("totals:", [round(x, 1) for x in totals[::10]])
    return totals, ginis
```

## 三、逐行解读：三个关键仪表

**总知识（`total`）**——整体性的体温计。它稳步上升后趋平，说明系统进入了自组织稳态（上篇 S 曲线）；若它一路飙升不回头，说明 `capacity` 约束失效，系统发散。

**基尼系数（`gini`）**——反馈律的体检单。基尼高，说明"强的越强、弱的越弱"，局部反馈没把分布拉平；基尼低且稳，说明信息反馈律在好好干活。想看反馈有没有效，盯它就行。

**熵（`entropy`）**——涨落健康度。熵太低，系统僵死（没有多样性）；熵太高，系统乱成一锅粥（涨落失控）。健康的活系统，熵在"有结构但不死板"的区间波动。

**可视化降级**：`matplotlib` 是可选依赖。没装也能跑——`except ImportError` 会降级成打印抽样点。这样代码零强制依赖，复制即运行。

## 四、为什么"观察"是验证的前哨

主线3 讲验证：把关键性质写成不变式，用 TLA+/Coq 去证。但**证之前，你得先知道系统大概长什么样**。指标和曲线就是这个"先知道"：

- 曲线显示系统发散 → 你立刻去查 `capacity` 约束（稳定性公理）；
- 基尼持续走高 → 你怀疑局部反馈增益不够（信息反馈机制）；
- 一次 shock 后曲线永久跳到新平台 → 你确认相变发生了（突变性原理）。

观察帮你**定位该验证哪条**，验证帮你**坐实那条真的守住**。两者接力，才构成闭环。

## 五、落点：四条主线在此合拢

- **主线4（代码）**：让世界**能跑**；
- **本篇（观测）**：让世界**能被看见**；
- **主线3（验证）**：让世界**不乱跑**；
- **主线2（骨架）**：让世界**有形状**。

一个可验证世界模型 = 能跑 + 能看 + 不乱跑 + 有形状。对照今天的大模型：它"能跑能聊"，却极度缺乏**对内的观测与指标**——它不知道自己"知识分布多不均衡""是否悄悄发散"。不可观测，就谈不上可验证。

下一篇进主线5 跨域：把这套方法真正用到场景里——OBE 教育世界模型、科研团队知识演进仿真、超稳定结构 2.0。

---

**版权声明**

© 2026 彭老师 · 首发于 [baibashi-jishu](https://github.com/phxjchina/baibashi-jishu)

本文采用 [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) 许可协议：
可自由阅读与转发（须署名并注明出处），**禁止商业使用、禁止改写与演绎**。
