function batchwritesortcode(path)

if nargin<1
    path='.';
end    
List=dir([path '/*.clu.1']);
for i=1:length(List)
load([path '/' List(i).name]);
eval(['SortCode=' List(i).name(1:end-6) ';']);
SortCode=SortCode(2:end);
save([path '/' List(i).name(1:end-6) '.sortcode'],'SortCode');
end