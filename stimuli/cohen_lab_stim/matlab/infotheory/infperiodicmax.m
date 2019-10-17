%
%function [InfoData,InfoMaxData]=infperiodicmax(RASTER,B,Fm,L,T)
%
%   FILE NAME   : INF PERIODIC MAX
%   DESCRIPTION : Extrapolates Mutual Iformation Estimate for infinate
%                 Data size using the procedure of Strong et al. and 
%                 INFWORDRASTERPERIODIC. The extrapolation is performed at
%                 at various sampling rates (Fsd).
% 
%   RASTER		: Rastergram using spet compressed format
%	B               : Length of Word, number of bits per cycle for
%                     generating P(W) and P(W,t)
%   Fm          : Modulation frequency
%	L           : Number of Bootstrap Itterations (Default: L=10)
%   T           : Amount of time to remove at begingin of raster
%                 (Default==0)
%
%Returned Variables
%
%   InfoData        : Data structure containing all of the mutual 
%                     information raw data
%
%                     .HWordt   : Noise Entropy per Word
%                     .HSect    : Noise Entropy per Second
%                     .HSpiket  : Noise Entropy per Spike
%                     .HWord    : Entropy per Word
%                     .HSec     : Entropy per Second
%                     .HSpike   : Entropy per Spike
%                     .Rate     : Mean Spike Rate
%
% (C) Monty A. Escabi, Aug. 2008
%
function [InfoData,InfoMaxData]=infperiodicmax(RASTER,B,Fm,L,T)

%Input Args
if nargin<4
    L=10;
end
if nargin<5
    T=0;    
end

%Computing Information Using Multiple Sampling Rates
for k=1:length(B)

    %Displaying Output Message
    %clc
    disp(['Computing Entropy & Bootstrapping for B='  int2str(B(k)) ' & Fm=' int2str(Fm)])
    
    %Computing Mutual Information
    [InfoData(k)]=infextrapolateperiodic(RASTER,B(k),Fm,L,T);
    
end
for k=1:length(B)
    
    InfoData(k).Fs=Fm*B(k);
    InfoData(k).B=B(k);
    
end
for k=1:length(B)
    
    %Mean Values
    InfoMaxData.HWordt(k)=mean([InfoData(k).HWordt]);
    InfoMaxData.HSect(k)=mean([InfoData(k).HSect]);
    InfoMaxData.HSpiket(k)=mean([InfoData(k).HSpiket]);
    InfoMaxData.HWord(k)=mean([InfoData(k).HWord]);
    InfoMaxData.HSec(k)=mean([InfoData(k).HSec]);
    InfoMaxData.HSpike(k)=mean([InfoData(k).HSpike]);
    InfoMaxData.Eff(k)=mean([InfoData(k).Eff]);
    
    %Standard Errors
    InfoMaxData.HWordtse(k)=std([InfoData(k).HWordt]);
    InfoMaxData.HSectse(k)=std([InfoData(k).HSect]);
    InfoMaxData.HSpiketse(k)=std([InfoData(k).HSpiket]);
    InfoMaxData.HWordse(k)=std([InfoData(k).HWord]);
    InfoMaxData.HSecse(k)=std([InfoData(k).HSec]);
    InfoMaxData.HSpikese(k)=std([InfoData(k).HSpike]);
    InfoMaxData.Effse(k)=std([InfoData(k).Eff]);
    
    %Other Parameters
    InfoMaxData.B(k)=B(k);
    InfoMaxData.Fm(k)=Fm;
end