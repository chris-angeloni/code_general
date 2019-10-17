function batchwritesortedclusters(globfn,datfiledir,sortedfiledir)

if nargin<2
    datfiledir='/Users/Chen/Research/TetrodeAnalysis/Data/TetrodeData/PNBSpline';
    sortedfiledir='/Users/Chen/Research/TetrodeAnalysis/Data/SortedData/PNBSpline';
end    

if nargin<1
    globfn='*';
end    
files=dir([datfiledir '/FD/' globfn '.clu.1']);

for i=1:length(files)
    clufilename=files(i).name
    writesortedclusters(clufilename,datfiledir,sortedfiledir);
end    
    
