%% 单数字图像识别系统 main.m
% 运行后弹出文件选择框，选择包含单个数字的图片即可识别
clear; clc; close all;

fprintf('==============================================\n');
fprintf('     单数字图像识别系统（简易OCR）\n');
fprintf('     支持手动选择图片文件\n');
fprintf('==============================================\n\n');

%% 步骤1：构建训练库
fprintf('[1/3] 构建数字样本库...\n');
[trainData, trainLabels] = buildTrainDatabase();
fprintf('      完成：共 %d 个训练样本（每个数字%d个变体）\n\n', ...
    length(trainLabels), length(trainLabels)/10);

%% 步骤2：选择图片并识别
fprintf('[2/3] 请选择要识别的图片...\n');
[fname, fpath] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp','图像文件'},'选择包含单个数字的图片（可多选）','MultiSelect','on');

if isequal(fname, 0)
    fprintf('未选择文件，退出。\n');
    return;
end

% 统一转为cell
if ischar(fname), fname = {fname}; end

fprintf('\n[3/3] 开始识别...\n');
fprintf('%-30s  %s\n', '文件名', '识别结果');
fprintf('%s\n', repmat('-',1,45));

results = {};
for i = 1:length(fname)
    imgPath = fullfile(fpath, fname{i});
    [label, conf, dbg] = recognizeDigit(imgPath, trainData, trainLabels);
    fprintf('%-30s  数字 %d  (置信度: %.1f%%)\n', fname{i}, label, conf*100);
    results{end+1} = struct('file',fname{i},'path',imgPath,'label',label,'conf',conf,'debug',dbg);
end

fprintf('\n识别完成！\n');

%% 步骤3：可视化结果
showResults(results, trainData, trainLabels);
