%
%function [InfoData]=infwordrasterperiodicpanzeri(RASTER,B,Fm,T)
%
%   FILE NAME       : INF WORD RASTER PERIODIC PANZERI
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
% (C) Monty A. Escabi, Dec 2012
%
function [InfoData]=infwordrasterperiodicpanzeri(RASTER,B,Fm,T)

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

%Computing Word Distribution for Noise Entropy: P(W,t), Psh(W,t), Pind(W,t)
Ntrials=length(RASTER);
Ncycles=floor((RASTER(1).T-ceil(T*Fm)/Fm)/(1/Fm));  %Note that ceil(T*Fm)/Fm is the amount of time to remove at begining of raster
Wt=zeros(B,Ntrials*Ncycles-1);
Pt=[];
for k=1:B %This loop is used to change the phase value so that all phases are considered

    %Circularly shifting cycle raster - elements wrap around and move up
    %one row as they are shifted circularly - this approach is much faster
    %than actually regenerating the cycle raster
    RASTERc(:,k)=RASTERt(:,k);

    %Shifting the Mask
    Mask=circshift(Mask',k)';
    
    %Generating coded words at a fixed phase
    Wt(k,:)=RASTERc*Mask';

    %Generating shuffled words at a fixed phase
    Wtsh(k,:)=rastershufflepanzeri(RASTERc)*Mask';
    
    %Generating Word Histogram for noise distribution
    W=Wt(k,:);
    Nt=[];
    while length(W)>=1
        Nt=[Nt sum(W(1)==W)];
        index=find(W(1)~=W);
        W=W(index);
    end
    PPt=sort(Nt/sum(Nt));
    Pt(k).Pt=PPt;
    
    %Generating Shuffled Word Histogram for noise distribution
    W=Wtsh(k,:);
    Nt=[];
    while length(W)>=1
        Nt=[Nt sum(W(1)==W)];
        index=find(W(1)~=W);
        W=W(index);
    end
    PPtsh=sort(Nt/sum(Nt));
    Pt(k).Ptsh=PPtsh;
    
    %Generating Independent Word Histogram for noise distribution
    for l=1:B
        for m=0:Max
            i=find(RASTERc(:,l)==m);
            Ptind(l,m+1)=length(i)/size(RASTERc,1);
        end
    end
    
    %Computing Noise Entropy
    HWordt(k)=sum(PPt.*log2(1./PPt));
    
    %Computing Shuffled Noise Entropy
    HWordtsh(k)=sum(PPtsh.*log2(1./PPtsh));

    %Compute Independent Noise Entropy
    HWordtind=Ptind.*log2(1./Ptind);
    i=find(~isnan(HWordtind));
    HWordtind=sum(HWordtind(i));
    
end
HWordt=mean(HWordt);
HWordtsh=mean(HWordtsh);

%Finding Total Entropy
W=reshape(Wt,1,numel(Wt));
N=[];
while length(W)>=1
    N=[N sum(W(1)==W)];
    index=find(W(1)~=W);
    W=W(index);
end
P=sort(N/sum(N));
HWord=sum(P.*log2(1./P));

%Computing Reliability Noise Entropy
L=sum(full(RASTERc),2);         %Spike Counts from cycle RASTER
for k=0:max(L)
    pL(k+1)=sum(find(L==k));
end
pL=pL/sum(pL);                  %Spike Count Distribution
Hreli=-sum(pL.*log2(pL));

%Computing Temporal Noise Entropy
if max(L)>0
    for l=1:max(L)  %Varying spike count

        %Selecting Words with precisely l spikes
        index=find(L==l);

        if length(index)>0
            Wtl=Wt(:,index);    %Words containing l spikes

            for k=1:B %This loop is used to change the phase value so that all phases are considered

                %Generating Word Histogram for noise distribution
                W=Wtl(k,:);
                Nt=[];
                while length(W)>=1
                    Nt=[Nt sum(W(1)==W)];
                    index=find(W(1)~=W);
                    W=W(index);
                end
                PPtl=sort(Nt/sum(Nt));
                Ptl(k).Ptl=PPtl;

                %Computing Noise Entropy for l spikes and fixed phase (k)
                HWordtl(k)=sum(PPtl.*log2(1./PPtl));

            end
            HWordtL(l)=mean(HWordtl);   %Noise entropy for l spikes (average over phases, k)
        else
            HWordtL(l)=0;
        end
    end
    Htemp=sum(pL(2:end).*HWordtL);      %Temporal Noise Entropy
else
    Htemp=0;
end

%Mean Spike Rate
Rate=sum(sum(RASTERc))/size(RASTERc,1)/(size(RASTERc,2)/Fsd);

%Entropy per time and per spike
InfoData.HWord=HWord;
InfoData.HSec=HWord/dt/B;
InfoData.HSpike=InfoData.HSec/Rate;
InfoData.HWordt=HWordt;
InfoData.HSect=HWordt/dt/B;
InfoData.HSpiket=InfoData.HSect/Rate;
InfoData.HWordtsh=HWordtsh;
InfoData.HSectsh=HWordtsh/dt/B;
InfoData.HSpiketsh=InfoData.HSectsh/Rate;
InfoData.HWordtind=HWordtind;
InfoData.HSectind=HWordtind/dt/B;
InfoData.HSpiketind=InfoData.HSectind/Rate;
InfoData.Hreli=Hreli;
InfoData.Htemp=Htemp;
InfoData.Rate=Rate;
InfoData.W=reshape(Wt,1,numel(Wt));
InfoData.Wt=Wt;
InfoData.P=P;
InfoData.Pt=Pt;
InfoData.dt=dt;
InfoData.Fm=Fm;