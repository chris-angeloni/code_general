%
% function [MTFb1,MTFb2] = mtfgenerateboot2(RASTER,FMAxis,OnsetT,Ncyc,Mcyc,NB,Disp)
%
%   FILE NAME   : MTF GENERATE BOOT 2
%   DESCRIPTION : Generates a MTF on the TDT system. Each SAM can contain a
%                 variable number of trials. The programs breaks up the
%                 trials into cycles and bootstraps the data across cycles.
%                 For each bootstrap, half the data is used so that we
%                 obtain pairs of MTFs for each half of the data.
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
%   MTFb1,MTFb2 : Bootstrapped MTF Data Structures. Split for each half of
%                 the data
%                 .FMAxis       - Modulation Frequency Axis
%                 .Rate         - Rate MTF
%                 .VS           - Vector Strength MTF
%                 .CycleHist    - Cycle Histogram matrix
%                 .Rateb1,2     - Bootstrapped rate MTF for trial 1 and 2
%                 .VSb1,2       - Bootstrapped vector Strength MTF for
%                                 trial 1 and 2
%                 .CycleHistb1,2- Bootstrapped cycle histogram matrix for
%                                 trial 1 and 2
%                 .RateSE       - Rate MTF standard error
%                 .VSSE         - Vector Strength MTF standard error
%                 .CycleHistSE  - Cycle Histogram matrix standard error
%
%   (C) Monty A. Escabi, Feb 2012
%
function [MTFb1,MTFb2] = mtfgenerateboot2(RASTER,FMAxis,OnsetT,Ncyc,Mcyc,NB,Disp)

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

%Generating MTF for each half of the data
MTFb1=MTF;
MTFb2=MTF;

%Bootstrapping and computing standard error on Rate and VS
MTFb1.Rateb=zeros(length(MTF.FMAxis),NB);
MTFb2.Rateb=zeros(length(MTF.FMAxis),NB);
MTFb1.VSb=zeros(length(MTF.FMAxis),NB);
MTFb2.VSb=zeros(length(MTF.FMAxis),NB);
for n=1:NB
        
    %Display Progress
    clc
    disp(['Bootstrapping VS and Rate: ' num2str(n/NB*100,3) ' %' ])
    
    %Generating Rate and VS MTF
    MTFb1.FMAxis=FMAxis;
    MTFb2.FMAxis=FMAxis;
    for k=1:length(MTFb1.FMAxis)

        %Break data into halfs and resampling data without replacement
        i=find(FMAxis(k)==[RASTERc.Fm]);
        j1=randsample(length(i),floor(length(i)/2),'false');
        x=zeros(1,length(i));           %used to find indices for second half
        x(j1)=ones(1,length(j1));      
        j2=i(find(~x));                 %complement vector - second half
        j1=i(j1);                       %First half
        
        %Computing Rate MTF for first half
        SpikeTime1=[RASTERc(j1).spet]/RASTERc(1).Fs;
        index1=find(SpikeTime1<RASTERc(j1(1)).T & SpikeTime1>OnsetT);
        MTFb1.Rateb(k,n)=length(index1)/RASTERc(j1(1)).T/length(j1);
        
        %Computing Rate MTF for second half
        SpikeTime2=[RASTERc(j2).spet]/RASTERc(1).Fs;
        index2=find(SpikeTime2<RASTERc(j2(1)).T & SpikeTime2>OnsetT);
        MTFb2.Rateb(k,n)=length(index2)/RASTERc(j2(1)).T/length(j2);

        %Vector Strength - Golberg & Brown - First half
        Phase1=[SpikeTime1*MTF.FMAxis(k)*2*pi];
        MTFb1.VSb(k,n)=sqrt( sum(sin(Phase1)).^2 + sum(cos(Phase1)).^2 )/length(Phase1);
        
        %Vector Strength - Golberg & Brown - Second half
        Phase2=[SpikeTime2*MTF.FMAxis(k)*2*pi];
        MTFb2.VSb(k,n)=sqrt( sum(sin(Phase2)).^2 + sum(cos(Phase2)).^2 )/length(Phase2);
        
    end
end

%Bootstrapping Cycle Histogram
for n=1:NB
    %Display Progress
    clc
    disp(['Bootstrapping Cycle Histogram: ' num2str(n/NB*100,3) ' %' ])
    
    CycleHist1=[];
    CycleHist2=[];
    for k=1:length(FMAxis)
        
        %Extract cycle histogram for the correct Fm
        i=find(FMAxis(k)==[RASTER.Fm]);
        [RASc]=raster2cyclerastermatrix(RASTER(i),FMAxis(k),Ncyc,0,FMAxis(k)*Mcyc,0);
        
        %Break data into halfs and resampling data without replacement
        i=1:size(RASc,1);
        j1=randsample(size(RASc,1),floor(size(RASc,1)/2),'false');
        x=zeros(1,length(i));           %used to find indices for second half
        x(j1)=ones(1,length(j1));      
        j2=i(find(~x));                 %complement vector - second half
        j1=i(j1);                       %First half
        
        %Cycle histogram for first and second half
        CycleHist1=[CycleHist1; mean(RASc(j1,:))];
        CycleHist2=[CycleHist2; mean(RASc(j2,:))];
        
    end
    MTFb1.CycleHistb(:,:,n)=CycleHist1'; %Bootstrapped cycle hist - first half
    MTFb2.CycleHistb(:,:,n)=CycleHist2'; %Bootstrapped cycle hist - second half
end

%Computing Standard Errors
MTFb1.RateSE=std([MTFb1.Rateb],[],2)';
MTFb2.RateSE=std([MTFb2.Rateb],[],2)';
MTFb1.VSSE=std([MTFb1.VSb],[],2)';
MTFb2.VSSE=std([MTFb2.VSb],[],2)';
MTFb1.CycleHistSE=std([MTFb1.CycleHistb],[],3);
MTFb2.CycleHistSE=std([MTFb2.CycleHistb],[],3);

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