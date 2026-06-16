function [trainData, trainLabels] = buildTrainDatabase()
%% buildTrainDatabase - 构建训练库
% 对1和8各生成80个变体（其他30个），并使用更有区分度的点阵

IMG_SIZE = [28, 28];

% 每个数字的变体数量（1和8大幅加密）
variantCount = [30,80,30,30,30,30,30,30,80,30]; % 0-9

totalN = sum(variantCount);
trainData   = zeros(totalN, prod(IMG_SIZE));
trainLabels = zeros(totalN, 1);

idx = 0;
for digit = 0:9
    N = variantCount(digit + 1);
    baseImg = getDigitBase(digit, IMG_SIZE);
    for v = 1:N
        rng(digit * 10000 + v);
        aug  = augment(baseImg, v, N);
        flat = double(aug(:))';
        idx  = idx + 1;
        trainData(idx, :) = flat;
        trainLabels(idx)  = digit;
    end
end

% 截断到实际行数
trainData   = trainData(1:idx, :);
trainLabels = trainLabels(1:idx);
end

% -------------------------------------------------------
function img = getDigitBase(digit, sz)
maps = getDigitMaps();
raw  = logical(maps{digit + 1});
big  = logical(imresize(double(raw), sz, 'nearest'));
% 1单独加粗更多（原始点阵太细）
if digit == 1
    big = imdilate(big, strel('disk', 2));
else
    big = imdilate(big, strel('disk', 1));
end
img = big;
end

% -------------------------------------------------------
function out = augment(img, v, totalV)
%% 均匀覆盖各类变换，v从1到totalV
% totalV越大，角度/缩放覆盖越密集

out = img;
seg = ceil(totalV / 6);  % 分6段

if v == 1
    % 原图，不变

elseif v <= seg
    % 段1：小角度旋转 -10~+10，均匀步进
    angles = linspace(-10, 10, max(seg,2));
    angle  = angles(min(v-1, numel(angles)-1)+1);
    out    = imrotate(img, angle, 'bilinear', 'crop');
    out    = logical(out > 0.3);

elseif v <= 2*seg
    % 段2：中等角度旋转 -20~+20
    angles = linspace(-20, 20, max(seg,2));
    angle  = angles(min(v-seg, numel(angles)-1)+1);
    out    = imrotate(img, angle, 'bilinear', 'crop');
    out    = logical(out > 0.3);

elseif v <= 3*seg
    % 段3：缩放 0.75~1.25
    scales = linspace(0.75, 1.25, max(seg,2));
    s      = scales(min(v-2*seg, numel(scales)-1)+1);
    tform  = affine2d([s 0 0; 0 s 0; 0 0 1]);
    out    = imwarp(img, tform, 'OutputView', imref2d(size(img)));
    out    = logical(out > 0.3);

elseif v <= 4*seg
    % 段4：旋转 + 缩放组合
    angle = (rand() - 0.5) * 24;
    scale = 0.82 + rand() * 0.36;
    tform = affine2d([scale 0 0; 0 scale 0; 0 0 1]);
    out   = imwarp(img, tform, 'OutputView', imref2d(size(img)));
    out   = imrotate(logical(out > 0.3), angle, 'bilinear', 'crop');
    out   = logical(out > 0.3);

elseif v <= 5*seg
    % 段5：旋转 + 椒盐噪声
    angle = (rand() - 0.5) * 20;
    out   = imrotate(img, angle, 'bilinear', 'crop');
    out   = logical(out > 0.3);
    nm    = rand(size(out));
    out(nm > 0.97) = true;
    out(nm < 0.03) = false;

else
    % 段6：平移 ±4像素（水平+垂直组合）
    dr  = round((rand() - 0.5) * 8);
    dc  = round((rand() - 0.5) * 8);
    out = circshift(img, [dr, dc]);
end

% 统一尺寸到28×28
if ~isequal(size(out), [28, 28])
    out = logical(imresize(double(out), [28, 28]) > 0.3);
end

% 填孔（对8/0/6/9封闭区域特别重要）
out = imfill(out, 'holes');

% 笔画过细时增粗（防止极端缩小后断裂，特别保护"1"）
if sum(out(:)) < 35
    out = imdilate(out, strel('disk', 1));
end
end

% -------------------------------------------------------
function maps = getDigitMaps()
maps = {
% 0 - 椭圆轮廓
[0,1,1,1,0;
 1,0,0,0,1;
 1,0,0,0,1;
 1,0,0,0,1;
 1,0,0,0,1;
 1,0,0,0,1;
 0,1,1,1,0];
% 1 - 粗竖笔+明显底座（上下各有水平特征，与其他数字区别更大）
[0,1,1,1,0;
 0,1,1,1,0;
 0,0,1,1,0;
 0,0,1,1,0;
 0,0,1,1,0;
 0,0,1,1,0;
 1,1,1,1,1];
% 2
[0,1,1,1,0;
 1,0,0,0,1;
 0,0,0,0,1;
 0,0,0,1,0;
 0,0,1,0,0;
 0,1,0,0,0;
 1,1,1,1,1];
% 3
[1,1,1,1,0;
 0,0,0,0,1;
 0,0,0,0,1;
 0,1,1,1,0;
 0,0,0,0,1;
 0,0,0,0,1;
 1,1,1,1,0];
% 4
[0,0,0,1,0;
 0,0,1,1,0;
 0,1,0,1,0;
 1,0,0,1,0;
 1,1,1,1,1;
 0,0,0,1,0;
 0,0,0,1,0];
% 5
[1,1,1,1,1;
 1,0,0,0,0;
 1,0,0,0,0;
 1,1,1,1,0;
 0,0,0,0,1;
 0,0,0,0,1;
 1,1,1,1,0];
% 6
[0,1,1,1,0;
 1,0,0,0,0;
 1,0,0,0,0;
 1,1,1,1,0;
 1,0,0,0,1;
 1,0,0,0,1;
 0,1,1,1,0];
% 7
[1,1,1,1,1;
 0,0,0,0,1;
 0,0,0,1,0;
 0,0,0,1,0;
 0,0,1,0,0;
 0,0,1,0,0;
 0,0,1,0,0];
% 8 - 上环略小、下环略大，增强与0/6/9的区分度
[0,1,1,1,0;
 1,0,0,0,1;
 1,0,0,0,1;
 1,1,1,1,1;
 1,0,0,0,1;
 1,0,0,0,1;
 0,1,1,1,0];
% 9
[0,1,1,1,0;
 1,0,0,0,1;
 1,0,0,0,1;
 0,1,1,1,1;
 0,0,0,0,1;
 0,0,0,0,1;
 0,1,1,1,0];
};
end
