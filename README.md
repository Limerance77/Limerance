# 单数字图像识别系统（简易OCR）

> 《机器视觉与图像处理》课程大作业 · 方向三
> 基于 MATLAB 实现 · 图像预处理 + KNN 分类识别

-----

## 项目简介

本项目针对图片中的单个印刷体或手写数字（0–9）进行自动识别，输出识别结果与置信度。系统不依赖任何深度学习框架，完全基于经典图像处理算法与 KNN 分类器实现，适用于嵌入式端或教学演示场景。

**核心特性：**

- 支持手动选择任意图片文件（弹出文件选择框），无需提前准备素材
- 自动完成灰度化、滤波降噪、Otsu 二值化、形态学处理、ROI 定位全流程预处理
- KNN 分类器（K=5，距离加权投票），训练库含 200 个增强样本（每个数字 20 个变体）
- 运行结果以图形窗口可视化展示，不生成额外图片文件

-----

## 文件结构

```
digit_recognition/
├── main.m                # 主程序：弹窗选图 → 识别 → 可视化
├── batchTest.m           # 系统自测：自动生成标准测试图并批量识别（验证准确率用）
├── buildTrainDatabase.m  # 构建训练库（200个增强样本）
├── preprocessImage.m     # 统一图像预处理函数（灰度化→降噪→二值化→ROI→28×28）
├── recognizeDigit.m      # KNN 识别核心函数
└── showResults.m         # 可视化结果展示（图形窗口，不保存文件）
```

-----

## 实验环境

|项目  |要求                           |
|----|-----------------------------|
|软件  |MATLAB R2019b 或更高版本          |
|工具箱 |Image Processing Toolbox（必需） |
|操作系统|Windows 10/11 · macOS · Linux|
|硬件  |普通 PC，无 GPU 需求，内存 4 GB 以上    |

检查工具箱：MATLAB 命令行输入 `ver`，确认列表中有 `Image Processing Toolbox`。

-----

## 快速开始

### 第一步：验证系统（推荐先跑）

将 6 个 `.m` 文件放入同一文件夹，在 MATLAB 中切换到该目录，运行：

```matlab
batchTest
```

程序自动生成 10 张标准测试图并识别，输出应为 **10/10 = 100%**，确认环境正常。

### 第二步：识别自己的图片

```matlab
main
```

弹出文件选择框，选择包含单个数字的图片（支持 PNG / JPG / BMP，可多选），识别结果直接显示在图形窗口中。

### 第三步（可选）：代码级调用

```matlab
% 构建训练库
[trainData, trainLabels] = buildTrainDatabase();

% 识别单张图片
[label, confidence, ~] = recognizeDigit('my_digit.png', trainData, trainLabels);
fprintf('识别结果：%d，置信度：%.1f%%\n', label, confidence * 100);
```

-----

## 算法原理

### 整体流程

```
输入图片
  ↓  灰度化（rgb2gray）
  ↓  高斯滤波降噪（sigma = 1.2）
  ↓  Otsu 自适应二值化（graythresh）
  ↓  前景统一为 1（数字像素 = 白）
  ↓  形态学处理（开运算去噪 + 闭运算填孔 + imfill）
  ↓  连通域分析，裁剪最大连通域 ROI
  ↓  缩放至标准 28×28，笔画增粗（imdilate）
  ↓  展平为 784 维特征向量
  ↓  KNN（K=5）距离加权投票
  ↓  输出识别结果 + 置信度
```

### 训练库构建

每个数字从手工 7×5 像素点阵出发，生成 20 个增强变体：

|变体类型     |数量|说明                   |
|---------|--|---------------------|
|原图       |1 |标准点阵放大               |
|旋转       |5 |−12° ~ +18°，步进 6°    |
|旋转 + 缩放  |5 |±10° 旋转，0.85–1.15 倍缩放|
|旋转 + 椒盐噪声|5 |±8° 旋转，3% 噪声密度       |
|平移       |4 |±3 像素随机平移            |

共 10 × 20 = **200 个训练样本**，覆盖主要变形情况。

### KNN 分类

采用欧氏距离，K=5，距离加权投票（权重 = 1/dist）：

$$\text{score}(c) = \sum_{i \in \text{KNN}} \frac{\mathbf{1}[y_i = c]}{d_i + \varepsilon}$$

取得分最高的类别作为识别结果，归一化后的得分比例即为置信度。

-----

## 实验结果

- 对系统自动生成的标准印刷体数字（`batchTest`）：准确率 **10/10 = 100%**
- 对手动拍摄或打印的印刷体数字：准确率通常在 **85%–95%** 之间
- 常见混淆对：6 与 9（旋转对称）、3 与 8（轮廓相近）

-----

## 注意事项

- 图片中应只包含**单个数字**，背景尽量简洁
- 拍摄时保持数字清晰、不过曝，避免极端倾斜（>30°）
- 系统运行不生成任何输出文件，结果仅在图形窗口展示

-----

## 参考文献

1. Otsu N. A Threshold Selection Method from Gray-Level Histograms. *IEEE Trans. SMC*, 1979.
1. Gonzalez R C, Woods R E. *Digital Image Processing*, 4th ed. Pearson, 2018.
1. MathWorks. [Image Processing Toolbox Documentation](https://www.mathworks.com/help/images/).

-----

*《机器视觉与图像处理》课程大作业 · 方向三 · MATLAB 实现*