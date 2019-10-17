%
%function [REnv]=rastercircularshufcorrenv(RASTER,Fsd,Fm,Delay)
%
%   FILE NAME       : RASTER CIRCULAR SHUF CORR ENV
%   DESCRIPTION     : Shuffled rastergram circular correlation function.
%                     Computes the envelope shuffled correlation. Assumes
%                     frozen noise carriers.
%
%                     Env corr is obtained by shuffling consecutive periods in 
%                     time and perform the correlation between the k-th and
%                     l-th raster (corresoponding to the k-th and l-th 
%                     period). Note that for this procdure, consecutive
%                     cycles have identical envelopes but the fine
%                     structure is uncorrelated. Thus this procedure gives
%                     the envelope shuffled correlogram.
%
%                     The standard error is obtaine with a Jackknife on the
%                     original data samples.
%
%   RASTER          : Cycle Rastergram (compressed spet format). Generated
%                     using RASTER2CYCLERASTERORDERED. RASTER contains LxM
%                     elements where L corresponds to the number of trials
%                     and M corresponds to the number of cycles over time.
%   Fsd             : sampling rate of raster to compute raster-corr.
%   Fm              : Sound modulation frequency (Hz)
%   Delay           : Rearranges the shuffled correlation so that the
%                     zeroth bin is centered about the center of the
%                     correaltion function (at the floor(N/2)+1 sample).
%                     Otherwize, the zeroth bin of the correaltion function
%                     is located at the first sample of Rshuf. (OPTIONAL,
%                     Default == 'n')
%
%RETURNED VALUES
%
%   REnv            : Data structure containing:
%
%                     .Renv         - Envelope correlogram
%                     .R            - Correlogram between all cycles
%                     .Rdiag        - Correlogram for cycles with fixed
%                                     fine structure and envelope
%                     .Tau          - Delay vector (msec)
%                     .sigma        - Jitter standard deviation (msec)
%                     .xhat         - Number of reliable spikes/cycle
%
% (C) Monty A. Escabi, Feb 2011
%
function [REnv]=rastercircularshufcorrenv(RASTER,Fsd,Fm,Delay)

%Expand rastergram into matrix format
T=RASTER(1).T;
[RAS,Fs]=rasterexpand(reshape(RASTER,1,numel(RASTER)),Fsd,T);

%Rastergram Length
L=size(RAS,2);
M=size(RAS,1);

%Computing Shuffled Circular Correlation using the following algorithm:
%
%   Rshuffle = Rpsth - Rdiag
%
%where 
%
%   Rpsth = E[PSTH(t) PSTH(t+tau)]
%
%   Rdiag = sum_k E[PSTH_k(t) PSTH_k(t+tau)]
%
%and l and k are the cycle number (or block number for Ncyc>1) and PSTH is
%the cycle PSTH for all the data. PSTH_k is the cycle PSTH for the k-th 
%cycle number (over time).
%
%This approach is a very efficient way of computing the shuffled
%correlation function (i.e. Frozern envelope but unfrozen fine structure). 
% It is similar to the procedure Yi and I used to compute the 
%envelope correlogram except that now we are shuffling across cycles. For
%example, Rpsth is obtained by considering all cycles. If we are dealing
%with a periodic signal with 10 trials and 100 cycles we have a total of 
%1000^2 possible correlations for Rpsth. However, because we crosscorrelate
%the psth this amounts to 1 correaltion.
%
%Rdiag is obtained by correlating segments with fixed fine structure. Thus,
%for Rdiag we have a total of 100*10^2 correlations. However, we compute it
%as the PSTH of the kth cycle, so that we effectively perform only 100
%correlation.
%
%It requires N+1 correlations compared to N*(N+1)/2.
%Note that it differs from the standard shuffled correlation since we are
%taking all of the off-diagonal terms (N*(N-1)), and not simply the lower 
%off-diagonal terms (N*(N-1)/2). The shuffled is an even-function (i.e., 
%symetric for + and - delays) when computed this way.
%
PSTH=sum(RAS,1);
F=fft(PSTH);
R=real(ifft(F.*conj(F)))/Fsd/T;
lambda=mean(mean(RAS));

%Generating correlation for diagonal terms
Rdiag=[];
for k=1:size(RASTER,2)
    %Expand rastergram into matrix format
    [RAS,Fs]=rasterexpand(RASTER(:,k),Fsd,T);

    %Rastergram Length
    L=size(RAS,2);
    Mp=size(RAS,1);
    
    %Diagonal Correlation
    PSTHd=sum(RAS,1);
    F=fft(PSTHd);
    Rdiag=[Rdiag;real(ifft(F.*conj(F)))/Fsd/T];
end

%Envelope Correlation
Renv=(R-sum(Rdiag))/(M.^2-size(RASTER,2)*Mp^2);

%Shifting zeroth bin
if Delay=='y'
    R=fftshift(R);
    Rdiag=fftshift(Rdiag);
    Renv=fftshift(Renv); 
end

%Delay Axis
N=length(Renv);
Tau=((.5:N)-N/2)/Fsd*1000;

%Adding to Data Structure
REnv.Renv=Renv;
REnv.R=R;
REnv.Rdiag=Rdiag;
REnv.lambda=lambda;
REnv.Fm=Fm;
REnv.Tau=Tau;
% 
% %Fitting Jitter / Reliability Model & Adding Model Results to structure
% [beta,R0,J0]=gaussfunmodeloptim(REnv,REnv.Renv);
% REnv.sigma=beta(1);
% REnv.xhat=beta(2);
% REnv.Rmodel=gaussfunmodel(beta,REnv);
% 

%Measuring Response Parameters
[REnvParam]=circularshufcorrenvparam(REnv);
REnv.MI1=REnvParam.MI1;
REnv.MI2=REnvParam.MI2;
REnv.sigma=REnvParam.sigma;
REnv.xhat=REnvParam.xhat;
REnv.lambda=REnvParam.lambda;
REnv.lambdaAC=REnvParam.lambdaAC;
REnv.lambdaDC=REnvParam.lambdaDC;
REnv.F=REnvParam.F;
REnv.Rmodel=REnvParam.Rmodel;