function batchclusteranalysis(globfn,Tresh,path,outpath,forcerun)

if nargin<5
    forcerun=0;
end    
if nargin<4
    outpath='/Users/Chen/Research/TetrodeAnalysis/Data/FinalCluster/PNBSpline';
end
if nargin<3
    path='/Users/Chen/Research/TetrodeAnalysis/Data/SortedData/PNBSpline';
end
if nargin<2
    Tresh=.9;
end    
if nargin<1
    globfn='*Sorted.mat';
end    
files=dir([path '/' globfn])
for i=1:length(files)
    i
    filename=files(i).name
    clusterfilename=[outpath '/' filename(1:end-10) 'Clusters.mat'];
    if exist(clusterfilename,'file')==0 || forcerun==1
        s=['load ' path '/' filename ' -mat'];
        eval(s)
        [Cluster,SIbar]=clusteranalysis(ClusterData,Tresh);
        [Dprime]=clusterDprime(Cluster);
        save(clusterfilename,'Cluster','Tresh','SIbar','Dprime');
    end
end    

