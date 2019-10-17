function batchtetrodedata(List,Thresh,T,fl,fh,US,DeadTime,AlignWindow,path,outpath)

%Example: batchtetrodedata(dir('CATICC07PFF7*.mat'))
if nargin<10
    outpath='F:\Chen\FTCData\TetrodeData\';
end
if nargin<9
    path='F:\Chen\FTCData\';
end
if nargin<8
    AlignWindow=0.2;
end
if nargin<7
    DeadTime=0.5;
end
if nargin<6
    US=4;
end
if nargin<5
    fh=5000;
end
if nargin<4
    fl=300;
end

if nargin<3
    T=2;
end
if nargin<2
    Thresh=5;
end
if nargin<1
    List=dir('CATICC*.mat');
end



for i=1:length(List)
    disp(['processing ' int2str(i) 'th file out of total ' int2str(length(List))]);
    filename=List(i).name
    tetrodedatafilename=[outpath '\' filename(1:length(filename)-4) '.dat'];
    if ~exist(tetrodedatafilename,'file')
        save temp.mat List filename tetrodedatafilename i Thresh T fl fh US DeadTime AlignWindow path outpath
        !matlab -nodesktop -nosplash -nojvm -r batchtetrodedatasub
        %!/Applications/MATLAB74/bin/matlab -nodesktop -nosplash -nojvm -r batchtetrodedatasub; exit;

    end
end
