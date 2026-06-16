function [predictedLabel, confidence, debugInfo] = recognizeDigit(imgPath, trainData, trainLabels)
%% recognizeDigit - KNN分类器（K=5）
% 1. 预处理图像到28x28
% 2. 展平为784维向量
% 3. 计算与所有训练样本的欧氏距离
% 4. 取最近K个邻居投票

K = 5;

%% 预处理
raw  = imread(imgPath);
img28 = preprocessImage(imgPath);
flat  = double(img28(:))';   % 1×784

%% KNN：计算欧氏距离
dists = sqrt(sum((trainData - flat).^2, 2));   % N×1

%% 取最近K个邻居
[sortedDists, sortedIdx] = sort(dists);
kIdx    = sortedIdx(1:K);
kDists  = sortedDists(1:K);
kLabels = trainLabels(kIdx);

%% 投票（距离加权：权重=1/dist）
weights = 1 ./ (kDists + 1e-6);
votes   = zeros(1, 10);
for i = 1:K
    votes(kLabels(i)+1) = votes(kLabels(i)+1) + weights(i);
end
[bestVote, bestIdx] = max(votes);
predictedLabel = bestIdx - 1;
confidence     = bestVote / sum(votes);

%% 调试信息
debugInfo.img_raw   = raw;
debugInfo.img28     = img28;
debugInfo.votes     = votes;
debugInfo.kLabels   = kLabels;
debugInfo.kDists    = kDists;
end
