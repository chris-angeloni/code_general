function batchaligntetrodedata(List)
if nargin<2
    List=dir('*.dat')
end    
for i=1:length(List) i
load(List(i).name,'-mat')
[TetrodeDataAligned]=tetrodewaveformalign(TetrodeData);
save ([List(i).name(1:end-4) 'Aligned.dat'],'TetrodeDataAligned');
end