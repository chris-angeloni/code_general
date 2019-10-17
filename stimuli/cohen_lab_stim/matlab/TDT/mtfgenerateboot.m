%
% function [MTF] = mtfgenerateboot(RASTER,FMAxis,OnsetT,Ncyc,Mcyc,NB,Disp)
%
%   FILE NAME   : MTF GENERATE BOOT
%   DESCRIPTION : Generates a MTF on the TDT system. Each SAM can contain a
%                 variable number of trials. The programs breaks up the
%                 trials into cycles and bootstraps the data across cycles.
%                 Also generates cycle histogram for all modulation
%                 frequncies. 
%
%   RASTER      : Rastergram array of data structure, spet format
%                 RASTER(k).spet - Spike event time array
%                 RASTER(k).Fs   - Sampling Frequency (Hz)
%                 RASTER(k).T    - Stimulus duration
%                 RASTER(k).Fm   - Modulation Frequency (Hz)
%
%   FMAxis      : Modulation Rate Axis Array (Hz)
%   OnsetT      : Time to remove at onset (sec)
%   Ncyc        : Number of cycles for cycle histogram
%   Mcyc        : Number of samples per cycle for cycle histogram
%   NB          : Number of bootstraps (Default == 100)
%   Disp        : Display output (Default=='n')
%
% RETURNED DATA
%   MTF         : MTF Data Structure
%                 .FMAxis       - Modulation Frequency Axis
%                 .Rate         - Rate MTF
%                 .VS           - Vector Strength MTF
%                 .CycleHist    - Cycle Histogram matrix
%                 .Rateb        - Bootstrapped rate MTF 
%                 .VSb          - Bootstrapped vector Strength MTF
%                 .CycleHistb   - Bootstrapped cycle histogram matrix
%                 .RateSE       - Rate MTF standard error
%                 .VSSE         - Vector Strength MTF standard error
%                 .CycleHistSE  - Cycle Histogram matrix standard error
%
%   (C) Monty A. Escabi, Feb 2012
%
function [MTF] = mtfgenerateboot(RASTER,FMAxis,OnsetT,Ncyc,Mcyc,NB,Disp)

%Input Arguments
if nargin<6
    NB=100;
end
if nargin<7
    Disp='n';
end

%Generating Cycle Raster
[RASTERc]=raster2cycleraster(RASTER,FMAxis,1,OnsetT,0);

%Generating Rate and VS MTF
MTF.FMAxis=FMAxis;
MTF.Rate=zeros(size(MTF.FMAxis));
for k=1:length(MTF.FMAxis)
 
    %Computing Rate MTF
    i=find(FMAxis(k)==[RASTER.Fm]);
    SpikeTime=[RASTER(i).spet]/RASTER(1).Fs;
    index=find(SpikeTime<RASTER(i(1)).T & SpikeTime>OnsetT);
    MTF.Rate(k)=length(index)/RASTER(i(1)).T/length(i);
    
    %Vector Strength - Golberg & Brown
    Phase=[SpikeTime*MTF.FMAxis(k)*2*pi];
    MTF.VS(k)=sqrt( sum(sin(Phase)).^2 + sum(cos(Phase)).^2 )/length(Phase);
    
end

%Generaging Cycle Histogram
CycleHist=[];
for k=1:length(FMAxis)
    i=find(FMAxis(k)==[RASTER.Fm]);
    [RASc]=raster2cyclerastermatrix(RASTER(i),FMAxis(k),Ncyc,0,FMAxis(k)*Mcyc,0);
    CycleHist=[CycleHist; mean(RASc)];
end
MTF.CycleHist=CycleHist';
MTF.P=(0:Mcyc*Ncyc-1)/(Mcyc-1);

%Bootstrapping and computing standard error on Rate and VS
MTF.Rateb=zeros(length(MTF.FMAxis),NB);
MTF.VSb=zeros(length(MTF.FMAxis),NB);
for n=1:NB
        
    %Display Progress
    clc
    disp(['Bootstrapping VS and Rate: ' num2str(n/NB*100,3) ' %' ])
    
    %Generating Rate and VS MTF
    MTF.FMAxis=FMAxis;
    for k=1:length(MTF.FMAxis)

        %Resampling data with replacement
        i=find(FMAxis(k)==[RASTERc.Fm]);
        j=randsample(i,length(i),'true');
        
        %Computing Rate MTF
        SpikeTime=[RASTERc(j).spet]/RASTERc(1).Fs;
        index=find(SpikeTime<RASTERc(j(1)).T & SpikeTime>OnsetT);
        MTF.Rateb(k,n)=length(index)/RASTERc(j(1)).T/length(j);

        %Vector Strength - Golberg & Brown
        Phase=[SpikeTime*MTF.FMAxis(k)*2*pi];
        MTF.VSb(k,n)=sqrt( sum(sin(Phase)).^2 + sum(cos(Phase)).^2 )/length(Phase);
        
    end
end

%Bootstrapping Cycle Histogram
for n=1:NB
    %Display Progress
    clc
    disp(['Bootstrapping Cycle Histogram: ' num2str(n/NB*100,3) ' %' ])
    
    CycleHist=[];
    for k=1:length(FMAxis)
        i=find(FMAxis(k)==[RASTER.Fm]);
        [RASc]=raster2cyclerastermatrix(RASTER(i),FMAxis(k),Ncyc,0,FMAxis(k)*Mcyc,0);
        i=randsample(size(RASc,1),size(RASc,1),'true');
        CycleHist=[CycleHist; mean(RASc(i,:))];
    end
    MTF.CycleHistb(:,:,n)=CycleHist';
end

%Computing Standard Errors
MTF.RateSE=std([MTF.Rateb],[],2)';
MTF.VSSE=std([MTF.VSb],[],2)';
MTF.CycleHistSE=std([MTF.CycleHistb],[],3);

%Displaying Output
if strcmp(Disp,'y')
    
    subplot(221)
    semilogx(MTF.FMAxis,MTF.Rate,'k')
    ylabel('Rate (Hz)')
    set(gca,'XTick',[2 4 8 16 32 64 128 256 512])
    xlim([2 512])
    
    subplot(222)
    semilogx(MTF.FMAxis,MTF.VS,'k')
    ylabel('Vector Strength')
    set(gca,'XTick',[2 4 8 16 32 64 128 256 512])
    xlim([2 512])
    
    subplot(223)
    semilogx(MTF.FMAxis,MTF.Rate.*MTF.VS,'k')
    ylabel('Sync Rate (Hz)')
    set(gca,'XTick',[2 4 8 16 32 64 128 256 512])
    xlim([2 512])
    xlabel('Mod. Freq. (Hz)')
    
    subplot(224)
    imagesc(log2(MTF.FMAxis/2),MTF.P,MTF.CycleHist)
    set(gca,'XTick',[0:8])
    set(gca,'XTickLabel',[2 4 8 16 32 64 128 256 512])
    set(gca,'YDir','normal')
    
end