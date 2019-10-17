%
%function [RData]=rastercircularshufcorrfast(RASTER,Fsd,Delay,NJ)
%
%   FILE NAME       : RASTER CIRCULAR SHUF CORR FAST
%   DESCRIPTION     : Shuffled rastergram circular correlation function.
%                     Shuffles are performed across trials for a repeated
%                     periodic sound.
%
%                     The standard error is obtaine with a Jackknife on the
%                     original data samples.
%
%   RASTER          : Cycle Rastergram (compressed spet format). Generated
%                     using RASTER2CYCLERASTER
%   Fsd             : sampling rate of raster to compute raster-corr.
%   Delay           : Rearranges the shuffled correlation so that the
%                     zeroth bin is centered about the center of the
%                     correaltion function (at the floor(N/2)+1 sample).
%                     Otherwize, the zeroth bin of the correaltion function
%                     is located at the first sample of Rshuf. (OPTIONAL,
%                     Default == 'n')
%	NJ              : Number of Jackknives for Cross Correlation Estimate
%                     (Default = 0). This is used to compute the standard
%                     errror on all statistics.
%RETURNED VALUES
%
%   RData             : Data structure containing:
%                     .Rshuf    - Shuffled correlation fuction
%                     .Rset     - Shuffled correlation standard error
%                                 across trials
%                     .RshufJt  - Jackknife matrix containing shuffled 
%                                 correlation functions for NJ Jackknives
%                                 (across trials).
%                     .Rsec     - Shuffled correlation standard error
%                                 across correlations
%                     .RshufJc  - Jackknife matrix containing shuffled 
%                                 correlation functions for NJ Jackknives
%                                 (across correlations).
%                     .Tau      - Delay axis (ms)
%
% (C) Monty A. Escabi, July 2007 (Edit Dec 2010)
%                      Edited from RASTERCIRCULARXCORRFAST
%
function [RData]=rastercircularshufcorrfast(RASTER,Fsd,Delay,NJ)

%Input Args
if nargin<3
   Delay='n'; 
end
if nargin<4
    NJ=0;
end

%Expand rastergram into matrix format
T=RASTER(1).T;
[RAS,Fs]=rasterexpand(RASTER,Fsd,T);

%Rastergram Length
L=size(RAS,2);
M=size(RAS,1);
    
%Computing Shuffled Circular Correlation using the following algorithm:
%
%   Rshuffle = Rpsth - Rdiag
%
%This approach is a very efficient way of computing the shuffled
%correlation function. It requires N+1 correlations compared to N*(N+1)/2.
%Note that it differs from the standard shuffled correlation since we are
%taking all of the off-diagonal terms (N*(N-1)), and not simply the lower 
%off-diagonal terms (N*(N-1)/2). The shuffled is an even-function (i.e., 
%symetric for + and - delays) when computed this way.
%
PSTH=sum(RAS,1);
F=fft(PSTH);
R=real(ifft(F.*conj(F)))/Fsd/T;
F=fft(RAS,[],2);
Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
Rshuf=(R-sum(Rdiag)) / (M*(M-1));
Raa=mean(Rdiag);
i=find(max(Raa)==Raa);
Raa(i)=0;

%Shifting zeroth bin
if Delay=='y'
   Rshuf=fftshift(Rshuf); 
   Raa = fftshift(Raa);
end

%Performing a Jackknife if desired
if NJ>=1
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %JACKKNIFING DATA ACROSS TRIALS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %Permuting Trials
    NJt=min(M,NJ);   %Make sure we have enough trials
    index=randperm(M);
    RAS=RAS(index,:);
        
    %Correlation For Diagonals
    F=fft(RAS,[],2);
    Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
        
    %Jackknifing data across rastergram trials
    for k=1:NJt        
        %Computing Correlation Functions
        i=[index(1:k-1) index(k+1:M)];      %Jackknife subsample
        PSTH=sum(RAS(i,:),1);
        F=fft(PSTH);
        R=real(ifft(F.*conj(F)))/Fsd/T;
        
        %F=fft(RAS(i,:),[],2);
        %Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
        
        RshufJt(k,:)=(R-sum(Rdiag(i,:))) / ((M-1)*(M-2));
    end
    if Delay=='y'
        RshufJt=fftshift(RshufJt);
    end
    
    %Computing Jacknife Residuals
    for k=1:NJt        
        Rrest(k,:)=mean(RshufJt,1)-RshufJt(k,:);
    end

    %Standard Error (across trials) on Shuffled Corr
    Rset=sqrt((M-1)*var(Rrest));

    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %JACKKNIFING DATA ACROSS CORRELATIONS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Finding Sample Indeces
%     NJc=min(M*(M-1),NJ);    %Make sure we have enough correlations
%     index=randsample(M,2)';
%     while length(index)<NJc     %Fast implementation - previously generated all possibilities, way too slow
%         i=randsample(M,2)';     %Samples without replacement
%         if sum(index(:,1)~=i(1) & index(:,2)~=i(2)) %Without Replacement
%             index=[index; i];
%         end
%     end
% 
%     %Computing Correlation for each jackknife correlation to remove
%     F1=fft(RAS(index(:,1),:),[],2);
%     F2=fft(RAS(index(:,2),:),[],2);
%     Rc=real(ifft(F1.*conj(F2),[],2))/Fsd/T;
%     if Delay=='y'
%         Rc=fftshift(Rc); 
%     end
%     %Computing Jacknife Samples
%     for k=1:NJc
%         RshufJc(k,:)=( Rshuf*M*(M-1)-Rc(k,:) ) / ( M*(M-1) - 1 );
%     end 
%     
%     %Computing Jacknife Residuals
%     for k=1:NJc
%         Rresc(k,:)=mean(RshufJc,1)-RshufJc(k,:);
%     end
%     
%     %Standard Error (across correlations) on Shuffled Corr
%     Rsec=sqrt((M*(M-1)-1)*var(Rresc));

else
   RshufJt=-9999;
   Rset=-9999;
   Rsec=-9999;   
end

%Delay Axis
N=length(Rshuf);
Tau=((.5:N)-N/2)/Fsd*1000;

%Converting to data structure
RData.Rshuf=Rshuf;
RData.Raa=Raa;
RData.RshufJ=RshufJt;
RData.Rset=Rset;
RData.lambda = mean(mean(RAS));  % average firing rate
RData.Tau=Tau;
% R.RshufJc=RshufJc;
% R.Rsec=Rsec;