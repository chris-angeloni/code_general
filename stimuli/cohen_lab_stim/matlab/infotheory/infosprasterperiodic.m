%
%function [InfoData]=infrasterperiodic(RASTER,B,Fm,TW,T)
%
%   FILE NAME       : INF SP RASTER PERIOD
%   DESCRIPTION     : Specific Information of a periodic Spike Train 
%                     obtained from the rastergram by computing the 
%                     Probability Distribution, P(W|s), of finding a B 
%                     letter Word, W, in the Spike Train at time T for a
%                     given periodic stimulus, s.
%
%   RASTER          : Rastergram containt all modulation conditions
%	B               : Length of Word, number of bits per cycle for
%                     generating P(W) and P(W,t)
%   Fm              : Modulation frequency (Hz)
%   TW              : Word length (sec)
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
% (C) Monty A. Escabi, Aug. 2008
%
function [InfoData]=infsprasterperiodic(RASTER,B,Fm,TW,T)

%Input Args
if nargin<5
    T=0;    
end

%Temporal Resolution
Fsd=1/(TW/B);
dt=1/Fsd;
Fs=RASTER(1).Fs;
L=length(RASTER)/length(Fm);

%Finding the Possible Maximum Number of spikes per bin
Max=-9999;
for k=1:length(RASTER)
    Max=ceil(max([Max , 1/Fsd ./ ( diff(RASTER(k).spet)/Fs )]));    %Theoretical max number of spikes given observed ISIs
end

%Binary Mask
D=Max+1;
Mask=[];
for k=1:B
        Mask=[Mask D^(k-1)];
end

%Computing Word Distribution for Noise Entropy: P(W,t)
Ntrials=L;
Ncycles=floor((RASTER(1).T-ceil(T*1/TW)*TW)/(TW));  %Note that ceil(T*Fm)/Fm is the amount of time to remove at begining of raster
Wt=zeros(length(Fm),B,Ntrials*Ncycles);
for l=1:length(Fm)
    
    RAS=RASTER((1:L)+(l-1)*L);
    Pt=[];
    HWt=0;
    for k=1:B %This loop is used to change the phase value so that all phases are considered

        %Generating Matrix From Raster at desired resolution and desired cycle
        %phase
        FM=Fm(l);
        [RASTERc]=raster2cyclerastermatrix(RAS,1/TW,1,T,Fsd,(k-1)/Fsd);
        RASTERc=sparse(RASTERc)/Fsd;                        %Normalizes amplitude and makes sparse

        %Generating coded words at a fixed phased  
        Wt(l,k,:)=(RASTERc*Mask')';
        
        %Computing Noise Entropy at Each Fm
        Nt=hist(log10(Wt(l,k,:)+1),10000);
        PPt=sort(Nt/sum(Nt));
        index=find(PPt~=0);
        HWt(k)=sum(PPt(index).*log2(1./PPt(index)));
    
    end
    %Noise Entropy (Everaged across all phases)
    HWordt(l)=mean(HWt);
    
end

%Finding Total Entropy (Across all Fm and phases)
W=reshape(Wt,1,numel(Wt));
N=hist(log10(W+1),10000);
P=sort(N/sum(N));
semilogy(P)
index=find(P~=0);
HWord=sum(P(index).*log2(1./P(index)));

%Finding Specific Entropy (Entropy at each Fm)
for l=1:length(Fm)
    W=reshape(Wt(l,:,:),1,numel(Wt(l,:,:)));
    N=hist(log10(W+1),10000);
    P=sort(N/sum(N));
    index=find(P~=0);
    HWordsp(l)=sum(P(index).*log2(1./P(index)));

    %Mean Spike Rate at Each Fm
    RASTER((1:L)+(l-1)*L);
    Rate(l)=numel([RASTER((1:L)+(l-1)*L).spet])/RASTER(1+(l-1)*L).T/L;

end

%Entropy per time and per spike
InfoData.HWordt=HWordt;
InfoData.HWordsp=HWordsp;
InfoData.HWord=HWord;
InfoData.Rate=Rate;
InfoData.W=Wt;      %The words are order for each Fm and phase
InfoData.dt=dt;
InfoData.Fm=Fm;