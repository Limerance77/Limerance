function showResults(results, trainData, trainLabels)
%% showResults - 可视化识别结果（只显示，不保存）

n = length(results);
if n == 0, return; end

%% 图1：原图 + 预处理后28×28
cols = min(n, 4);
rows = ceil(n / cols);

figure('Name','识别结果','Position',[50 50 min(n,4)*320 rows*420]);
for i = 1:n
    r = results{i};
    subplot(rows*2, cols, (floor((i-1)/cols))*cols*2 + mod(i-1,cols) + 1);
    if size(r.debug.img_raw,3)==3
        imshow(r.debug.img_raw);
    else
        imshow(r.debug.img_raw,[]);
    end
    title(sprintf('识别结果: %d (%.0f%%)', r.label, r.conf*100),...
        'FontSize',12,'FontWeight','bold','Color',[0.1 0.5 0.1]);

    subplot(rows*2, cols, (floor((i-1)/cols))*cols*2 + mod(i-1,cols) + 1 + cols);
    imshow(r.debug.img28,[]);
    title('预处理28×28','FontSize',9);
end
sgtitle('手动选图识别结果','FontSize',13,'FontWeight','bold');

%% 图2：KNN投票得分（第一张图）
r1 = results{1};
figure('Name','投票得分','Position',[500 50 600 380]);
colors = repmat([0.5 0.7 1.0],10,1);
[~,bi] = max(r1.debug.votes);
colors(bi,:) = [0.2 0.85 0.3];
hb = bar(0:9, r1.debug.votes, 'FaceColor','flat');
hb.CData = colors;
xlabel('数字类别'); ylabel('加权投票得分');
title(sprintf('KNN投票得分分布（识别结果: %d）', r1.label),'FontWeight','bold');
xticks(0:9); grid on;

%% 图3：训练样本示例
figure('Name','训练样本库','Position',[50 500 900 120]);
for d = 0:9
    idx = find(trainLabels==d, 1);
    subplot(1,10,d+1);
    imshow(reshape(trainData(idx,:),[28,28]),[]);
    title(num2str(d),'FontSize',13,'FontWeight','bold');
end
sgtitle('训练样本示例（每个数字取第1个）','FontSize',11);

end
