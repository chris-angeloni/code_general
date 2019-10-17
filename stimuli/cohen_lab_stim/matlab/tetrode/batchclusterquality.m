function batchclusterquality(path)
List=dir([path '/*.dat'])
for i=1:length(List)
    i
    FD=[];
    load([path '/FD/' List(i).name(1:end-4) '.clu.1']);
    eval(['SortCode=' List(i).name(1:end-4) ';']);
    SortCode=SortCode(2:end);
    load([path '/FD/' List(i).name(1:end-4) '_Peak.fd'],'-mat');
    FD=FeatureData;
    load([path '/FD/' List(i).name(1:end-4) '_Valley.fd'],'-mat');
    FD=[FD FeatureData];
    load([path '/FD/' List(i).name(1:end-4) '_WavePC1.fd'],'-mat');
    FD=[FD FeatureData];
    for n=1:max(SortCode)
        index=find(SortCode==n);
        [CluSep(n)] = Cluster_Quality(FD, index);
    end
    save ([path '/FD/' List(i).name(1:end-4) '.clusterQ'],'CluSep')
end