function [pList, kList] = buildOEPath(root,mouseList)

%% function [pList, kList] = buildOEPath(root,mouseList)

kcnt = 1;
pcnt = 1;
for m = 1:length(mouseList)
    
    % sorted files
    ksList = dir(fullfile(root,mouseList{m},'**','cluster_KSLabel.tsv'));
    ksList = ksList(~[ksList.isdir]);
    for i = 1:length(ksList)
        kList{kcnt} = fullfile(ksList(i).folder,'..','..');
        kcnt = kcnt + 1;
    end
    
    % curated files
    phyList = dir(fullfile(root,mouseList{m},'**','cluster_group.tsv'));
    phyList = phyList(~[phyList.isdir]);
    for i = 1:length(phyList)
        pList{pcnt} = fullfile(phyList(i).folder,'..','..');
        pcnt = pcnt + 1;
    end
    
end
