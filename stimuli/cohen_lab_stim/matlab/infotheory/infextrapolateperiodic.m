%
%function [InfoData]=infextrapolate(RASTER,B,Fm,L,T)
%
%   FILE NAME   : INF EXTRAPOLATE PERIODIC
%   DESCRIPTION : Extrapolates Mutual Iformation Estimate for infinate
%                 Data size using the procedure of Strong et al. and 
%                 INFWORDRASTERPERIODIC
%                 Extrapolation procedure is performed at a fixed
%                 temporal resolution (1/Fsd) and a fixed word 
%                 length (B)
%                 To extrapolate by considering word length, B, use
%                 the routine INFEXTRAPOLATEB
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
%   InfoData        : Data structure containing all mutual information
%                     results
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
function [InfoData]=infextrapolateperiodic(RASTER,B,Fm,L,T)

%Input Arguments
if nargin<4
	L=10;
end
if nargin<5
   T=0; 
end

%Computing Mutual Information and getting data for bootstrapping
[InfoData]=infwordrasterperiodic(RASTER,B,Fm,T);
HWord=InfoData.HWord;
HSec=InfoData.HSec;
HSpike=InfoData.HSpike;
HWordt=InfoData.HWordt;
HSect=InfoData.HSect;
HSpiket=InfoData.HSpiket;
Rate=InfoData.Rate;
P=InfoData.P;
Pt=InfoData.Pt;
W=InfoData.W;
Wt=InfoData.Wt;
dt=InfoData.dt;

%Botstrapping Entropy as a function of data fraction
for l=1:L
    for k=1:4
    
    %Truncating Data for Each Data Fraction
    DF=1/k;
    M=round(length(W)*DF);
    Wb=randsample(W,M);
    
    %Generating Histogram & Computing Entropy
    N=hist(log10(Wb+1),10000); 
	PP=sort(N/sum(N));
	index=find(PP~=0);
	HW(l,k)=sum(PP(index).*log2(1./PP(index)));
    
    %Firing Rate
    R(l,k)=Rate;
    
    end
end

%Botstrapping Noise Entropy as a function of data fraction
for l=1:L
    for k=1:4
        for m=1:size(Wt,1)  %Looping over cycle phases

        %Truncating Data for Each Data Fraction
        DF=1/k;
        Mt=round(size(Wt,2)*DF);
        Wtb=randsample(Wt(m,:),Mt,'true'); %Word Distribution at a fixed phase

        %Generating Histograms & Computing Noise Entropy
        Nt=hist(log10(Wtb+1),10000);
        PPt=sort(Nt/sum(Nt));
        index=find(PPt~=0);
        HWt(l,k,m)=sum(PPt(index).*log2(1./PPt(index)));
    
        end
    end
end
HWt=mean(HWt,3);

%Fitting Polynomial, Extrapolating Entropy, & computing efficiency
HWord=[];
HWordt=[];
X=1:4;
for k=1:500 %Number of bootstraps
    
	%Extrapolating Spike Train Entropy vs. Data Fraction
    index1=randsample(L,4,'true')';
    index2=1:4;
    [P,S]=polyfit(X,diag(HW(index1,index2))',2);
	HWord=[HWord P(3)];

	%Extrapolating Noise Entropy vs. Data Fraction
    index1=randsample(L,4,'true')';
    index2=1:4;
    [Pt,S]=polyfit(X,diag(HWt(index1,index2))',2);
	HWordt=[HWordt Pt(3)];
 
end

%Extpolated Efficiency
Eff=(HWord-HWordt)./HWord;

%Measuring Firing Rate
Rate=length([RASTER.spet])/sum([RASTER.T]);

%Enthropy per time and per spike
Fsd=B*Fm;
HSect=HWordt/B*Fsd;
HSpiket=HSect/Rate;
HSec=HWord/B*Fsd;
HSpike=HSec/Rate;

%Ouput Data Structure
InfoData.HWordt=HWordt;
InfoData.HSect=HSect;
InfoData.HSpiket=HSpiket;
InfoData.HWord=HWord;
InfoData.HSec=HSec;
InfoData.HSpike=HSpike;
InfoData.Rate=Rate;
InfoData.Eff=Eff;