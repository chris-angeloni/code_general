function batchwritespetfile (List)
if nargin<1
    List=dir('*.dat');
end    
for i=1:length(List)
    i
    load(List(i).name, '-mat');
    id=strfind(List(i).name,'.dat');
    cd FD
    load([List(i).name(1:id-1) '.clu.1']);
    cd ..
    eval(['SortCode=' List(i).name(1:id-1) '_clu;']);
    SortCode=SortCode(2:end);
    id=strfind(List(i).name,'.dat');
    sitename=List(i).name(1:id-1);
    for j=2:max(SortCode)
        index=find(SortCode==j);
        spet=TetrodeData.Spet(index);
        Fs=TetrodeData.Fs;
        waveform=TetrodeData.Snip(index,:,:);
        id=find(diff(spet)==0);
        index=setdiff(1:length(spet),id);
        spetindex=index;
        spet=spet(index);
        imagescwaveform(waveform); 
        SNR=tetrodewaveformSNR(waveform)
        [WVSTATS]=waveformstats(waveform)
        if max(SNR)>2
            save (['F:\Chen\FTCData\SpetFile\' sitename 'u' int2str(j) 'spet.mat'],'spetindex','spet','Fs');
            save (['F:\Chen\FTCData\SpetFile\' sitename 'u' int2str(j) 'wv.mat'],'waveform','WVSTATS');
            pause(1)
        end    
        close          
    end
end    