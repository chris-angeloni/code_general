%
%function [REnvFine]=rastercircularshufcorrenvfine(RASTER,Fsd,Fm,Delay)
%
%   FILE NAME       : RASTER CIRCULAR SHUF CORR ENV FINE
%   DESCRIPTION     : Shuffled rastergram circular correlation function.
%                     Computes the envelope shuffled correlation as well as
%                     the fine structure shuffled correlation.
%
%                     Shuffles are performed in two ways:
%
%                     1) First we shuffled between consecutive periods in 
%                     time and perform the correlation between the k-th and
%                     l-th raster (corresoponding to the k-th and l-th 
%                     period). Note that for this procdure, consecutive
%                     cycles have identical envelopes but the fine
%                     structure is uncorrelated. Thus this procedure gives
%                     the envelope shuffled correlogram.
%
%                     2) Second, we shuffle across trail for each cycle
%                     raster. In this case, both the envelope and fine
%                     structure are fixed. This shuffled correlogram
%                     contains buth the fine structure and envelope
%                     correlations.
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
%   REnvFine        : Data structure containing:
%
%                     .Renv         - Envelope correlogram
%                     .Renvfs       - Envelope & fine structure correlogram
%                     .Raa          - Autocorrelogram
%                     .RenvSEM      - SEM for Renv
%                     .RenvfsSEM    - SEM for Renvfs
%                     .RaaSEM       - SEM for Raa
%                     .RenvB        - Bootstrap samples for RenvB
%                     .RenvfsB      - Bootstrap samples for RenvfsB
%                     .RaaB         - Bootstrap samples for Raa
%                     .Tau          - Delay vector (msec)
%                     .sigma        - Jitter standard deviation (msec)
%                     .xhat         - Number of reliable spikes/cycle
%                     .MI1          - Modulation Index 1 - based on power
%                     .MI2          - Modulation Index 1 - based on rate.
%                                     The same as Zheng 2008
%                     .lambdaAC     - AC firing rate
%                     .lambdaDC     - DC firing rate
%                     .F            - Temporal coding fraction 
%                                     =lambdaAC^2/(lambdaAC^2+lambdaDC^2)
%                     .Rmodel       - Sum of gaussian model fit of envelope
%                                     correlation 
%                     .BW           - Bandwidth
%                     .Fm           - Modulation Frequency (Hz)
%                     .lambdap      - 
%    
% (C) Monty A. Escabi, Feb 2011
%
function [REnvFine]=rastercircularshufcorrenvfine(RASTER,Fsd,Fm,Delay)

%Number of trials and periods over time
L=size(RASTER,1);
M=size(RASTER,2);

%Computing Firing Rate
T=RASTER(1).T;
[RAS,Fs]=rasterexpand(reshape(RASTER,1,numel(RASTER)),Fsd,T);
lambda=mean(mean(RAS));

%Computing Envelope and Fine Structure Correlograms
RenvfsB=[];
RaaB=[];
for k=1:M
    [R]=rastercircularshufcorrfast(RASTER(:,k),Fsd,Delay,0);
    RenvfsB=[RenvfsB;R.Rshuf];
    RaaB=[RaaB;R.Raa];
end

%Computing Envelope Correlograms
%Ive tested both of the procedures below, and the results are identical.
%However, the procedure using RASTERCIRCULARSHUFCORRENV requires N+1
%correlations compared to N^2. It is way faster (several hours versus ~30
%sec). 
%
%  RenvB=[];
%  for k=1:M
%      for l=k+1:M
%          [R]=rastercircularxcorrfast(RASTER(:,k),RASTER(:,l),Fsd,Delay,0);
%          RenvB=[RenvB; R.R12];
%      end
%  end
% RenvB=[RenvB;fliplr(RenvB)];
[REnvB]=rastercircularshufcorrenv(RASTER,Fsd,Fm,Delay);
RenvB=[REnvB.Renv;REnvB.Renv];

%Bootstrapping data to obtain SE
RenvSEM=std(bootstrp(1000,'mean',RenvB));
RenvfsSEM=std(bootstrp(1000,'mean',RenvfsB));
RaaSEM=std(bootstrp(1000,'mean',RaaB));

%Delay Axis
N=size(RenvB,2);
Tau=((.5:N)-N/2)/Fsd*1000;

%Adding to Data Structure
REnvFine.Renv=mean(RenvB);
REnvFine.Renvfs=mean(RenvfsB);
REnvFine.Raa=mean(RaaB);
REnvFine.RenvSEM=RenvSEM;
REnvFine.RenvfsSEM=RenvfsSEM;
REnvFine.RaaSEM=RaaSEM;
REnvFine.RenvB=RenvB;
REnvFine.RenvfsB=RenvfsB;
REnvFine.RaaB=RaaB;
REnvFine.lambda=lambda;
REnvFine.Fm=Fm;
REnvFine.Tau=Tau;

% 
% %Fitting Jitter / Reliability Model & Adding Model Results to structure
% [beta,R0,J0]=gaussfunmodeloptim(REnv,REnv.Renv);
% REnv.sigma=beta(1);
% REnv.xhat=beta(2);
% REnv.Rmodel=gaussfunmodel(beta,REnv);
% 

%Measuring Response Parameters
[REnvParam]=circularshufcorrenvparam(REnvFine);
REnvFine.MI1=REnvParam.MI1;
REnvFine.MI2=REnvParam.MI2;
REnvFine.sigma=REnvParam.sigma;
REnvFine.xhat=REnvParam.xhat;
REnvFine.lambda=REnvParam.lambda;
REnvFine.lambdaAC=REnvParam.lambdaAC;
REnvFine.lambdaDC=REnvParam.lambdaDC;
REnvFine.F=REnvParam.F;
REnvFine.Rmodel=REnvParam.Rmodel;