%
% function [MTF] = mtfgenerate(RASTER,FMAxis,OnsetT,Ncyc,Mcyc)
%
%   FILE NAME   : MTF GENERATE
%   DESCRIPTION : Generates a MTF on the TDT system. Each SAM can contain a
%                 variable number of trials.
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
%   Disp        : Display output (Default=='n')
%
% RETURNED DATA
%   MTF         : MTF Data Structure
%                 .FMAxis       - Modulation Frequency Axis
%                 .Rate         - Rate MTF
%                 .VS           - Vector Strength MTF
%                 .CycleHist    - Cycle Histogram matrix
%                 .P            - Phase for cycle histogram
%
%   (C) Monty A. Escabi, November 2006 (Edit Feb 2012)
%
function [MTF] = mtfgenerate(RASTER,FMAxis,OnsetT,Ncyc,Mcyc,Disp)

%Input Arguments
if nargin<6
    Disp='n';
end

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