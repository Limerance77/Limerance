%% batchTest.m - 批量自测（验证系统准确率，无需手动选图）
% 生成标准测试图自动跑一遍，确认准确率 >= 90% 后再手动选自己的图片
clear; clc; close all;

fprintf('===== 系统自测（生成标准测试图）=====\n\n');

%% 构建训练库
fprintf('构建训练库...\n');
[trainData, trainLabels] = buildTrainDatabase();

%% 生成干净测试图（不含旋转噪声）
testDir = 'auto_test';
if exist(testDir,'dir'), rmdir(testDir,'s'); end
mkdir(testDir);

maps = getTestMaps();
IMG_SIZE = [28,28];
for d = 0:9
    raw = logical(maps{d+1});
    big = logical(imresize(double(raw),IMG_SIZE,'nearest'));
    big = imdilate(big,strel('disk',1));
    % 白底黑字保存
    imwrite(uint8(~big)*255, fullfile(testDir,sprintf('digit_%d.png',d)));
end
fprintf('已生成10张标准测试图到 ./%s/\n\n',testDir);

%% 识别
correct=0; total=0;
fprintf('%-20s  真实  识别  正确?\n','文件名');
fprintf('%s\n',repmat('-',1,40));
for d = 0:9
    fp = fullfile(testDir,sprintf('digit_%d.png',d));
    [pred,conf,~] = recognizeDigit(fp, trainData, trainLabels);
    ok = (pred==d);
    if ok, correct=correct+1; flag='✓'; else, flag='✗'; end
    total=total+1;
    fprintf('digit_%d.png          %d     %d     %s  (%.0f%%)\n',d,d,pred,flag,conf*100);
end
fprintf('%s\n',repmat('-',1,40));
fprintf('自测准确率: %d/10 = %.0f%%\n\n',correct,correct/total*100);

if correct/total >= 0.9
    fprintf('✓ 系统准确率达标，可以运行 main.m 手动选图识别了！\n');
else
    fprintf('✗ 准确率未达标，请联系调试。\n');
end
end

function maps = getTestMaps()
maps = {
[0,1,1,1,0; 1,0,0,0,1; 1,0,0,1,1; 1,0,1,0,1; 1,1,0,0,1; 1,0,0,0,1; 0,1,1,1,0];
[0,1,1,1,0; 0,1,1,1,0; 0,0,1,1,0; 0,0,1,1,0; 0,0,1,1,0; 0,0,1,1,0; 1,1,1,1,1];
[0,1,1,1,0; 1,0,0,0,1; 0,0,0,0,1; 0,0,0,1,0; 0,0,1,0,0; 0,1,0,0,0; 1,1,1,1,1];
[1,1,1,1,0; 0,0,0,0,1; 0,0,0,0,1; 0,1,1,1,0; 0,0,0,0,1; 0,0,0,0,1; 1,1,1,1,0];
[0,0,0,1,0; 0,0,1,1,0; 0,1,0,1,0; 1,0,0,1,0; 1,1,1,1,1; 0,0,0,1,0; 0,0,0,1,0];
[1,1,1,1,1; 1,0,0,0,0; 1,0,0,0,0; 1,1,1,1,0; 0,0,0,0,1; 0,0,0,0,1; 1,1,1,1,0];
[0,1,1,1,0; 1,0,0,0,0; 1,0,0,0,0; 1,1,1,1,0; 1,0,0,0,1; 1,0,0,0,1; 0,1,1,1,0];
[1,1,1,1,1; 0,0,0,0,1; 0,0,0,1,0; 0,0,0,1,0; 0,0,1,0,0; 0,0,1,0,0; 0,0,1,0,0];
[0,1,1,1,0; 1,0,0,0,1; 1,0,0,0,1; 1,1,1,1,1; 1,0,0,0,1; 1,0,0,0,1; 0,1,1,1,0];
[0,1,1,1,0; 1,0,0,0,1; 1,0,0,0,1; 0,1,1,1,1; 0,0,0,0,1; 0,0,0,0,1; 0,1,1,1,0];
};
end
