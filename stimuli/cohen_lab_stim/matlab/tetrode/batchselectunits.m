function batchselectunits(List,SNRThresh,IsoDistThresh,LratioUpperThresh,ChannelValidity)
if nargin<5
    ChannelValidity=[1 1 1 1];
end    
if nargin<4
    LratioUpperThresh=.2;
end
if nargin<3
    IsoDistThresh=20;
end
if nargin<2
    SNRThresh=5;
end
if nargin<1
    List=dir('*.dat');
end    

if length(SNRThresh)==1
    SNRThresh=[SNRThresh 9999];
end    
count=0;
for i=1:length(List)
    i
    
    load(List(i).name, '-mat');
    id=strfind(List(i).name,'.dat');
    load([List(i).name(1:id-1) '.clu.1']);
    eval(['SortCode=' List(i).name(1:id-1) '_clu;']);
    SortCode=SortCode(2:end);
    id=strfind(List(i).name,'.dat');
    sitename=List(i).name(1:id-1);disp(sitename)
    Fet=[];
    load([sitename '_Peak.fd'],'-mat');
    Fet=[Fet FeatureData];
    load([sitename '_Valley.fd'],'-mat');
    Fet=[Fet FeatureData];
    load([sitename '_Energy.fd'],'-mat');
    Fet=[Fet FeatureData];
    load([sitename '_WavePC1.fd'],'-mat');
    Fet=[Fet FeatureData];
    for j=2:max(SortCode)
        index=find(SortCode==j);
        SNR=tetrodewaveformSNR(TetrodeData.Snip(index,:,:));
        ch=find(ChannelValidity);
        SNR=SNR(ch);
        [CluSep, m] = Cluster_Quality(Fet, index);
        IsoDist=CluSep.IsolationDist;
        Lratio=CluSep.Lratio;
        if max(SNR)>SNRThresh(1) && max(SNR)<SNRThresh(2) && IsoDist>IsoDistThresh && Lratio<LratioUpperThresh 
            count=count+1;
            spetindex=index;
            spet=TetrodeData.Spet(index);
            Fs=TetrodeData.Fs;
            waveform=TetrodeData.Snip(index,:,:);
            meanwv=squeeze(mean(waveform,1));        
            id=find(diff(spet)==0);
            index=setdiff(1:length(spet),id);
            spet=spet(index);
            save (['F:\Chen\FTCData\SpetFile\' sitename 'u' int2str(j) 'spet.mat'],'spetindex','spet','Fs');
            imagescwaveform(waveform); 
            title(['Nspike=' num2str(length(index)) ', SNR=' num2str(max(SNR),2)]);
            xlabel(['IsoDist=' num2str(IsoDist,3) ', Lratio=' num2str(Lratio,3) ]);
            [WVSTATS]=waveformstats(waveform);
            save(['F:\Chen\FTCData\SpetFile\' sitename 'u' int2str(j) 'wv.mat'],'waveform','WVSTATS','IsoDist','Lratio')
            saveas(gcf,['F:\Chen\FTCData\SpetFile\' sitename 'u' int2str(j) 'wv.jpg'],'jpeg');
%             figure,subplot(2,1,1),[R]=xcorrspikesparse(spet,spet,Fs,10000,0.015,1200);
%             load([List(i).name(1:end-19) 'Trig.mat'] );
%             Fs=Fs*4;
%             NTrig=1799;
%             TrigTimes=round(Fs*Trig);
%             [TrigA,TrigB]=trigfixstrf2(TrigTimes,400,NTrig);
%             [spetA,spetB]=spet2spetabfix(spet,TrigA,TrigB,Fs);
%             subplot(2,1,2),[R]=xcorrspikesparse(spetA,spetB,Fs,10000,0.015,600);
%             %saveas(gcf,['/Volumes/Chen2/SpetFiles/SAM/' sitename 'u' int2str(j) 'corr.jpg'],'jpeg');
        end
    end
    pause(1)
    close all
end

