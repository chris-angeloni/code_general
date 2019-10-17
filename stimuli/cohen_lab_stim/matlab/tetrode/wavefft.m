List=dir('*spet.mat');
previoussitename='';
for n=1:length(List)
    n
    load(List(n).name);
    sitename=List(n).name(1:end-10);
    if ~strcmp(previoussitename,sitename)
        load([sitename '.dat'],'-mat');
    end;
    previoussitename=sitename;
    index=find(ismember(TetrodeData.SpetAligned,spet));
    wv=TetrodeData.SnipAligned(index,:,:);
    meanwv=squeeze(mean(wv));
    [M,i]=max(max(abs(meanwv')));
    wave=squeeze(meanwv(i,:));
    NFFT=5000;
    f=Fs/2*linspace(0,1,NFFT/2+1);
    y=abs(fft(wave,NFFT));y=y(1:floor(NFFT/2)+1);
    %plotwaveform(wv);figure,plot(f,y);
    [M,i]=max(y);
    index=find(y<=0.5*M);
    j=find(index>i,1);
    index2=find(y<0.1*M);
    j2=find(index2>i,1);
    %title(['Best Freq at ' num2str(f(i)) ', UpperCutoff Freq at ' num2str(f(index(j))) ', Max Freq at ' num2str(f(index2(j2)))]);
    %pause;close all
    BestFreq(n)=f(i);
    FreqUpperCutoff(n)=f(index(j));
    MaxFreq(n)=f(index2(j2));
end

save wavefft.mat BestFreq FreqUpperCutoff MaxFreq List