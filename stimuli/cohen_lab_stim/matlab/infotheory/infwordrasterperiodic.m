%
%function [InfoData]=infwordrasterperiodic(RASTER,B,Fm,T)
%
%   FILE NAME       : INF WORD RASTER PERIOD
%   DESCRIPTION     : Entropy & Noise Entropy of a periodic Spike Train 
%                     obtained from the rastergram by computing the 
%                     Probability Distribution, P(W|t,s), of finding a B 
%                     letter Word, W, in the Spike Train at time T for a
%                     given periodic stimulus, s.
%
%   RASTER          : Rastergram
%	B               : Length of Word, number of bits per cycle for
%                     generating P(W) and P(W,t)
%   Fm              : Sound modulation Frequency (Hz)
%   T               : Amount of time to remove at begingin of raster
%                     (Default==0)
%
%Returned Variables
%
%   InfoData        : Data structure containing all mutual information
%                     results
%                     .HWordt   : Noise Entropy per Word
%                     .HSect    : Noise Entropy per Second
%                     .HSpiket  : Noise Entropy per Spike
%                     .HWord    : Entropy per Word
%                     .HSec     : Entropy per Second
%                     .HSpike   : Entropy per Spike
%                     .Rate     : Mean Spike Rate
%                     .W        : Coded words for entropy calculation
%                     .Wt       : Coded words for noise entropy calculation
%                     .P        : Word distribution function
%                     .Pt       : Word distribution function for noise entropy
%                     .dt       : Actual Temporal Resolution Used
%
% (C) Monty A. Escabi, Aug. 2008 (Edit Aug 2012)
%
function [InfoData]=infwordrasterperiodic(RASTER,B,Fm,T)

%Input Args
if nargin<4
    T=0;    
end

%Temporal Resolution
Fsd=Fm*B;
dt=1/Fsd;
Fs=RASTER(1).Fs;
L=max(round(Fs/Fsd),1);

%Finding the Possible Maximum Number of spikes per bin (changed Aug 2012)
Max=-9999;
for k=1:B
    [RASTERc]=raster2cyclerastermatrix(RASTER,Fm,1,T,Fsd,(k-1)/Fsd);
    Max=max(Max,max(max(RASTERc))/Fsd);
end
%Max=-9999;
%for k=1:length(RASTER)
%    Max=ceil(max([Max , 1/Fsd ./ ( diff(RASTER(k).spet)/Fs )]));    %Theoretical max number of spikes given observed ISIs
%end

%Binary Mask
D=Max+1;
Mask=D.^(0:B-1);

%Computing Word Distribution for Noise Entropy: P(W,t)
Ntrials=length(RASTER);
Ncycles=floor((RASTER(1).T-ceil(T*Fm)/Fm)/(1/Fm));  %Note that ceil(T*Fm)/Fm is the amount of time to remove at begining of raster
Wt=zeros(B,Ntrials*Ncycles);
Pt=[];
for k=1:B %This loop is used to change the phase value so that all phases are considered

    %Generating Matrix From Raster at desired resolution and desired cycle
    %phase
    [RASTERc]=raster2cyclerastermatrix(RASTER,Fm,1,T,Fsd,(k-1)/Fsd);
    RASTERc=sparse(RASTERc)/Fsd;    %Normalizes amplitude and makes sparse

    %Generating coded words at a fixed phased  
    Wt(k,:)=RASTERc*Mask';
    
    %Generating Noise Word Histogram & Computing Noise Entropy 
    Nt=hist(log10(Wt(k,:)+1),10000);
    PPt=sort(Nt/sum(Nt));
    index=find(PPt~=0);
    HWordt(k)=sum(PPt(index).*log2(1./PPt(index)));
     
    %Generating Noise Entropy Distribution
    Pt(k).Pt=PPt(index);
    
end
HWordt=mean(HWordt);

%Finding Total Entropy
W=reshape(Wt,1,numel(Wt));
N=hist(log10(W+1),10000);
P=sort(N/sum(N));
index=find(P~=0);
HWord=sum(P(index).*log2(1./P(index)));

%Mean Spike Rate
Rate=numel([RASTER.spet])/RASTER(1).T/length(RASTER);

%Entropy per time and per spike
InfoData.HWordt=HWordt;
InfoData.HSect=HWordt/dt/B;
InfoData.HSpiket=InfoData.HSect/Rate;
InfoData.HWord=HWord;
InfoData.HSec=HWord/dt/B;
InfoData.HSpike=InfoData.HSec/Rate;
InfoData.Rate=Rate;
InfoData.W=W;
InfoData.Wt=Wt;
InfoData.P=P;
InfoData.Pt=Pt;
InfoData.dt=dt;
InfoData.Fm=Fm;