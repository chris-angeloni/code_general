function  [featuredata]=getfeaturedata(tetrodename,unitnumber,feature)

if exist([tetrodename '.dat'],'file');
    load ([tetrodename '_' feature '.fd'], '-mat');
    load ([tetrodename '.clu.1']);
    SortCode=eval(tetrodename);
    SortCode=SortCode(2:end);
else    
    load ([tetrodename 'Aligned_' feature '.fd'], '-mat');
    load ([tetrodename 'Aligned.sortcode'],'-mat');
end    


index=find(SortCode==unitnumber);
featuredata=FeatureData(index,:);



