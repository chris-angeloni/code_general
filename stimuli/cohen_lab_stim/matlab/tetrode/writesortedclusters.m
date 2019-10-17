function writesortedclusters(clufilename,datfiledir,sortedfiledir)
%e.g. 'CATICC07PFF7Block10Tetrode1.clu.1'

if nargin<2
    datfiledir='/Users/Chen/Research/TetrodeAnalysis/Data/MClustData';
    sortedfiledir='/Users/Chen/Research/TetrodeAnalysis/Data/SortedData';
end

data=load([datfiledir '/FD/' clufilename]);
data=data(2:end);

datfilename=[clufilename(1:end-6) '.dat'];
s=['load ' datfiledir '/' datfilename ' -mat'];
eval(s);

m=max(data);
for i=1:m
    index=find(data==i);
    ClusterData(i).spet=TetrodeData.SpetAligned(index);
    ClusterData(i).snip=TetrodeData.SnipAligned(index,:,:);
end    


sortedfilename=[clufilename(1:end-6) 'Sorted.mat'];
save([sortedfiledir '/' sortedfilename], 'ClusterData')