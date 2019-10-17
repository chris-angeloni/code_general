%
% function [MTFJ] = mtfjittergenerate(RASTER,Fsd,FMAxis,MaxTau)
%
%   FILE NAME   : FM JITTER GENERATE
%   DESCRIPTION : Generates a Jitter & Reliability MTF
%
%	RASTER      : Rastergram array of data structure, spet format
%
%                 RASTER(k).spet - Spike event time array
%                 RASTER(k).Fs   - Sampling Frequency (Hz)
%                 RASTER(k).T    - Stimulus duration
%  
%  Fsd			: Sampling rate for correlation analysis (Hz)
%  FMAxis       : Modulation Rate Axis Array (Hz)
%  MaxTau       : Temporal lag to compute xcorrelation (msec)
%
% RETURNED DATA
%
%   MTFJ        : Jitter MTF Data Structure
%
%                 MTF.FMAxis    - Modulation Frequency Axis
%                 MTF.p         - Trial-to-trial reliability
%                 MTF.sigma     - Jitter standard deviation (msec)
%                 MTF.lambda    - Firing rate (spikes/sec)
%                 MTF.pg        - Trial-to-trial reliability (Gaussian
%                                 Model estimate)
%                 MTF.sigmag    - Jitter standard deviation (msec)
%                                 (Gaussian Model estimate)
%                 MTF.lambdag   - Firing rate (spikes/sec) (Gaussian Model
%                                 estimate)
%                 MTF.Corr      - Correlation functions
%                     Corr.Raa
%                     Corr.Rab
%                     Corr.Rpp
%                     Corr.Rmodel
%                     Corr.Tau
%
%   (C) Monty A. Escabi, October 2006
%
function [MTFJ] = mtfjittergenerate(RASTER,Fsd,FMAxis,MaxTau)

%Number of Trials and Stimulus Conditions
N=length(FMAxis);           %Number of stimulus conditions
NTrial=length(RASTER)/N;    %Number of trials per stimulus

%Generating Jitter Correlation Functions at each FM
for k=1:N
   
    %Determining Jitter Correlation, sigma,p, and lambda
    RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fsd);
    [Tau,Raa,Rab,Rpp,Rmodel,sigmag,pg,lambdag,sigma,p,lambda]=jitterrastercorrfit(RAS,Fsd,MaxTau,'y');
    pause(1)

    %Appending to jitter MTF data structure
    MTFJ(k).FMAxis=FMAxis;
    MTFJ(k).p=p;
    MTFJ(k).sigma=sigma;
    MTFJ(k).lambda=lambda;
    MTFJ(k).pg=pg;
    MTFJ(k).sigmag=sigmag;
    MTFJ(k).lambdag=lambdag;
    MTFJ(k).Corr.Tau=Tau;
    MTFJ(k).Corr.Raa=Raa;
    MTFJ(k).Corr.Rab=Rab;
    MTFJ(k).Corr.Rpp=Rpp;
    MTFJ(k).Corr.Rmodel=Rmodel;

end
