---
title: "Arduino + RC522：10 分钟做个会认人的门禁"
column: "S1-物联网概论"
series: 10
date: 2026-10-19
source: "教学专栏成稿（第 10 篇）"
status: published
tags: ["物联网"]
description: "理由很实在：它是你能做的最小完整闭环——刷卡（感知）→ 比对（决策）→ 开门（执行）→ 关门（再感知的雏形），四格全能填上，一百块以内搞定……"
---


# Arduino + RC522：10 分钟做个会认人的门禁

## 一、为什么第一个项目选它

动手篇第一个项目，我带学生做门禁。

理由很实在：它是你能做的**最小完整闭环**——刷卡（感知）→ 比对（决策）→ 开门（执行）→ 关门（再感知的雏形），四格全能填上，一百块以内搞定。而且它天天在你眼前转（宿舍门禁、实验室门禁），做完有体感。

## 二、材料清单

| 零件 | 干啥用 | 备注 |
| --- | --- | --- |
| Arduino UNO 开发板 | 大脑 | 最普通的那种就行 |
| RC522 RFID 读卡模块 | 眼睛 | 认卡的 |
| 门禁卡 / 公交卡 | 被认的卡 | 手里有啥卡用啥卡 |
| SG90 舵机 | 手 | 模拟开门，5～9 元 |
| 面包板 + 杜邦线若干 | 神经 | 接线用 |
| （可选）继电器模块 | 大力手 | 真想控电磁锁再上 |

## 三、原理：三句话讲清 RFID

很多教程一上来就 SPI 协议、13.56MHz，听着头大。其实门禁的原理，大白话就三句：

1. **每张卡有个独一无二的身份证号（UID）。** 你的卡、我的卡，号不一样；
2. **读卡器是个保安。** 你把卡递过去（靠近），它问："编号多少？"卡答："我是 12:34:56:78"；
3. **保安拿这个号去对名单。** 名单上有，开门；没有，靠边站。

对，就这么简单。所谓"读卡"，就是把卡的编号读出来；所谓"验证"，就是拿它跟一个"白名单"比一比。RC522 这个模块，把上面这些无线电的弯弯绕全包了，你只管要编号。

## 四、接线：就五根线

RC522 用的是 SPI 通信，但你先别管 SPI 是啥，记住"照图插"就行：

| RC522 引脚 | 接到 Arduino |
| --- | --- |
| SDA（有的标 SS） | D10 |
| SCK | D13 |
| MOSI | D11 |
| MISO | D12 |
| RST | D9 |
| VCC | 3.3V（**别接 5V，会烧**） |
| GND | GND |

舵机更省事：信号线接 D3，红线接 5V，棕线接 GND。

## 五、代码：复制就能跑

Arduino IDE 里，先装两个库：**MFRC522**（sketch → include library → manage libraries 里搜）和自带的 **Servo**。

```cpp
#include <SPI.h>
#include <MFRC522.h>
#include <Servo.h>

#define SS_PIN   10      // RC522 的 SDA
#define RST_PIN  9       // RC522 的 RST
#define SERVO_PIN 3      // 舵机信号线

MFRC522 rfid(SS_PIN, RST_PIN);
Servo doorServo;

// 白名单：先随便填一个，下一步教你读自己的卡号替换它
byte allowedCard[4] = {0xDE, 0xAD, 0xBE, 0xEF};

void setup() {
  Serial.begin(9600);
  SPI.begin();
  rfid.PCD_Init();
  doorServo.attach(SERVO_PIN);
  doorServo.write(0);              // 舵机归零 = 门关着
  Serial.println("门禁就绪，请刷卡");
}

void loop() {
  // 1. 感知：附近有没有新卡？
  if (!rfid.PICC_IsNewCardPresent()) return;
  if (!rfid.PICC_ReadCardSerial()) return;

  // 2. 把卡号打到串口看看（第一次用先读号）
  Serial.print("读到卡号：");
  for (byte i = 0; i < rfid.uid.size; i++) {
    Serial.print(rfid.uid.uidByte[i] < 0x10 ? " 0" : " ");
    Serial.print(rfid.uid.uidByte[i], HEX);
  }
  Serial.println();

  // 3. 决策：这号在白名单上吗？
  if (isAllowed(rfid.uid.uidByte, rfid.uid.size)) {
    Serial.println("自己人，开门！");
    doorServo.write(90);           // 4. 执行：舵机转 90 度 = 开门
    delay(5000);                   //    开 5 秒
    doorServo.write(0);            //    再关上
  } else {
    Serial.println("陌生人，不放行。");
  }

  rfid.PICC_HaltA();               // 这张卡处理完，休眠，等下一张
}

bool isAllowed(byte *uid, byte len) {
  for (byte i = 0; i < len; i++) {
    if (uid[i] != allowedCard[i]) return false;
  }
  return true;
}
```

## 六、第一次运行：先"读号"，再"设名单"

第一次烧录完，打开串口监视器（右上角选 9600 波特率），拿卡靠近读卡器。你会看到：

```
读到卡号： DE AD BE EF
门禁就绪，请刷卡
```

（前面几行是示意，你屏幕上会打出你那张卡的**真实编号**。）

现在，把这个真实编号填到代码里的 `allowedCard` 那行。比如读到的是 `A3 7C 12 5F`，就改成：

```cpp
byte allowedCard[4] = {0xA3, 0x7C, 0x12, 0x5F};
```

重新烧录。再刷这张卡——舵机"咔"地转过去，5 秒后回来。刷别的卡——没反应。

**一个会认人的门禁，成了。**

## 七、翻车点：我学生踩过的坑

1. **RC522 的 VCC 接了 5V，冒烟了。** 这模块是 3.3V 伺候的，接错直接烧，别抱侥幸；
2. **刷卡没反应，串口也静默。** 九成是线接错了，重点查 SDA 是不是 D10、RST 是不是 D9；
3. **每次读到的卡号都不一样。** 检查是不是把 `PICC_ReadCardSerial` 的返回值漏判了，或者卡贴太近/太远；
4. **舵机抖、没劲、带不动门。** SG90 力气小，演示可以；真要带动机械锁，得上继电器 + 独立电源，别指望开发板那口 5V。

## 八、留个作业：环还没全闭上

做完你肯定特高兴。但我得泼点冷水：这个门禁，环还差一格。

它"看"了（刷卡）、"想"了（比对）、"做"了（开门），可**它不知道门最后关没关**——万一舵机卡住、门被东西挡住，它以为关好了，其实一直敞着。

差的那格叫"再感知"。补法很简单：加一个**门磁开关**（两片，贴上/分开就通断），门关上时给 Arduino 一个信号，这才叫"确认关好了"。用什么加，留给你想。

下一篇，咱们给这个环装上"神经"：《**ESP8266 + MQTT：把温度计搬上云，手机随时看**》。
---

*我是彭老师，一个在大学教计算机的过来人。这个专栏叫《白话计算机科普专栏》——不装懂，只聊我当年怎么没想通、又是怎么想通的。这个"白话物联网"系列的动手做篇，代码都经过课堂验证，直接复制就能跑。如果哪篇让你"哦"了一声，欢迎转发给同样困惑的朋友。*

---

**版权声明**

© 2026 彭老师 · 首发于 [baibashi-jishu](https://github.com/phxjchina/baibashi-jishu)

本文采用 [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/) 许可协议：
可自由阅读与转发（须署名并注明出处），**禁止商业使用、禁止改写与演绎**。
