%
%function [InfoDataBias]=infwordrasterperiodicbias(RASTER,B,Fm,M,T)
%
%   FILE NAME       : INF WORD RASTER PERIOD BIAS
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
%   M               : Number of trials for cycle raster - reduced data
%                     size
%   T               : Amount of time to remove at begingin of raster
%                     (Default==0)
%   
%Returned Variables
%
%   InfoDataBias    : Data structure containing all mutual information
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
% (C) Monty A. Escabi, Dec. 2012
%
function [InfoDataBias]=infwordrasterperiodicbias(RASTER,B,Fm,M,T)

%Input Args
if nargin<5
    M2=10000;
end
if nargin<6
    T=0;
end

%Temporal Resolution
Fsd=Fm*B;
dt=1/Fsd;
Fs=RASTER(1).Fs;
L=max(round(Fs/Fsd),1);

% %Finding the Possible Maximum Number of spikes per bin (changed Aug 2012)
% Max=-9999;
% for k=1:B
%     [RASTERc]=raster2cyclerastermatrix(RASTER,Fm,1,T,Fsd,(k-1)/Fsd);
%     Max=max(Max,max(max(RASTERc))/Fsd);
% end

%Finding the Possible Maximum Number of spikes per bin (changed Aug 2012)
Max=-9999;
k=1;
[RASTERc]=raster2cyclerastermatrix(RASTER,Fm,1,T,Fsd,(k-1)/Fsd);
Max=max(Max,max(max(RASTERc))/Fsd);

%Binary Mask
D=Max+1;
Mask=D.^(0:B-1);

%Generating Cycle Matrix desired resolution and zero cycle phase
[RASTERc]=raster2cyclerastermatrix(RASTER,Fm,1,T,Fsd,0);
RASTERc=sparse(RASTERc)/Fsd;    %Normalizes amplitude and makes sparse
RASTERt=RASTERc(2:end,:);
RASTERc=RASTERc(1:end-1,:);

%Computing Word Distribution for Noise Entropy: P(W,t)
Ntrials=length(RASTER);
Ncycles=floor((RASTER(1).T-ceil(T*Fm)/Fm)/(1/Fm));  %Note that ceil(T*Fm)/Fm is the amount of time to remove at begining of raster
Wt=zeros(B,Ntrials*Ncycles-1);
Wt1=zeros(B,M);
Pt=[];
for k=1:B %This loop is used to change the phase value so that all phases are considered
    
    %Circularly shifting cycle raster - elements wrap around and move up
    %one row as they are shifted circularly - this approach is much faster
    %than actually regneerating the cycle raster
    RASTERc(:,k)=RASTERt(:,k);

    %Shifting the Mask
    Mask=circshift(Mask',k)';
    
    %Generating coded words at a fixed phased  
    Wt(k,:)=RASTERc*Mask';
    Wt1(k,:)=Wt(k,1:M);
    
    %Generating Noise Word Histogram & Computing Noise Entropy - Infinite
    %data case
    W=Wt(k,:);
    Nt=[];
    clear N
    while length(W)>=1
        Nt=[Nt sum(W(1)==W)];
        index=find(W(1)~=W);
        W=W(index);
    end
    PPt=sort(Nt/sum(Nt));
    HWordt(k)=sum(PPt.*log2(1./PPt));
    
    %Generating Noise Word Histogram & Computing Noise Entropy - Finite
    %data case
    W1=Wt1(k,:);
    Nt1=[];
    clear N
    while length(W1)>=1
        Nt1=[Nt1 sum(W1(1)==W1)];
        index=find(W1(1)~=W1);
        W1=W1(index);
    end
    PPt1=sort(Nt1/sum(Nt1));
    HWordt1(k)=sum(PPt1.*log2(1./PPt1));
    
    %Generating Noise Entropy Distribution
    Pt(k).Pt=PPt;
    Pt1(k).Pt=PPt1;
    
end
HWordt=mean(HWordt);
HWordt1=mean(HWordt1);

%Finding Total Entropy - infinite data case
W=reshape(Wt,1,numel(Wt));
N=[];
while length(W)>=1
    N=[N sum(W(1)==W)];
    index=find(W(1)~=W);
    W=W(index);
end
PP=sort(N/sum(N));
HWord=sum(PP.*log2(1./PP));

%Finding Total Entropy - finite data case

W=reshape(Wt(:,1:M),1,numel(Wt(:,1:M)));
while length(W)>=1
    N=[N sum(W(1)==W)];
    index=find(W(1)~=W);
    W=W(index);
end
PP=sort(N/sum(N));
HWord1=sum(PP.*log2(1./PP));


%Mean Spike Rate
Rate=numel([RASTER.spet])/RASTER(1).T/length(RASTER);

%Entropy per time and per spike
InfoDataBias.HWordt=HWordt;
InfoDataBias.HWordt1=HWordt1;
%InfoDataBias.HSect=HWordt/dt/B;
%InfoDataBias.HSpiket=InfoDataBias.HSect/Rate;
InfoDataBias.HWord=HWord;
InfoDataBias.HWord1=HWord1;

%InfoDataBias.HSec=HWord/dt/B;
%InfoDataBias.HSpike=InfoDataBias.HSec/Rate;
InfoDataBias.Rate=Rate;
InfoDataBias.W=W;
InfoDataBias.Wt=Wt;
%InfoDataBias.P=P;
%InfoDataBias.Pt=Pt;
InfoDataBias.dt=dt;
InfoDataBias.Fm=Fm;