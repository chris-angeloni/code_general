%
%function [InfoData,InfoMaxData]=infperiodicfm(RASTER,Fm,L,T)
%
%   FILE NAME   : INF PERIODIC FM
%   DESCRIPTION : Extrapolates Mutual Iformation Estimate for infinate
%                 Data size using the procedure of Strong et al. and 
%                 INFPERIODICMAX. The extrapolation is performed at
%                 at various sampling rates (Fsd). Computes the mutual
%                 information at multiple modulation frequencies
% 
%   RASTER		: Rastergram using spet compressed format
%   Fm          : Modulation frequency array
%	L           : Number of Bootstrap Itterations (Default: L=10)
%   T           : Amount of time to remove at begingin of raster
%                 (Default==0)
%
%Returned Variables
%
%   InfoData(k)      : Data structure array containing all of the mutual 
%                     information raw data
%
%                     .HWordt   : Noise Entropy per Word
%                     .HSect    : Noise Entropy per Second
%                     .HSpiket  : Noise Entropy per Spike
%                     .HWord    : Entropy per Word
%                     .HSec     : Entropy per Second
%                     .HSpike   : Entropy per Spike
%                     .Rate     : Mean Spike Rate
%                     .Fm       : Modulation frequency
%
% (C) Monty A. Escabi, Aug. 2008
%
function [InfoData,InfoDataFm]=infperiodicfm(RASTER,Fm,L,T)


%Input Args
if nargin<3
    L=10;
end
if nargin<4
    T=0;
end

%Number of trials 
Ntrials=length(RASTER)/length(Fm);

%Computing Information Using Multiple Sampling Rates
for k=1:length(Fm)

    %Finding Number of bits
    B=2.^(0:15);
    i=find(B*Fm(k)<2*RASTER(1).Fs);     %One bit beyond sampling resolution of data
    B=B(i);

    %Computing Mutual Information
    [InfoData(k).Data,InfoDataFm(k)]=infperiodicmax(RASTER((1:Ntrials)+(k-1)*Ntrials),B,Fm(k),L,T);
    
end