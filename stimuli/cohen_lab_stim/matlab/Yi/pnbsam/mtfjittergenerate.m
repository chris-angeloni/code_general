
%
% function [MTFJ] = mtfjittergenerate(RASTER,Fsd,T)
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
%   (C) Monty A. Escabi 2006
%
function [MTFJ] = mtfjittergenerate(RASTER,FMAxis)


%Number of Trials and Stimulus Conditions
N=length(FMAxis);           %Number of stimulus conditions
NTrial=length(RASTER)/N;    %Number of trials per stimulus

%Generating Jitter Correlation Functions at each FM
for k=1:length(FMAxis)
    MaxTau = 4*1000/(2*FMAxis(k));   % in msec, half of one period
    % MaxTau = 100;
    Fsd = 50*FMAxis(k);  % relative Fsd
    % Fsd = 2000;
    
    %Determining Jitter Correlation, sigma,p, and lambda
    RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fsd,1);
    [Tau,Raa,Rab,Rpp,Rmodel,sigmag,pg,lambdag,sigma,p,lambda]=jitterrastercorrfit(RAS,Fsd,MaxTau,'y');
    pause(1)

    %Appending to jitter MTF data structure
    MTFJ(k).FMAxis = FMAxis(k);
    MTFJ(k).p=p; P(k)=p;
    MTFJ(k).sigma=sigma;  
    MTFJ(k).lambda=lambda; 
    MTFJ(k).pg=pg;  Pg(k)=pg;
    MTFJ(k).sigmag=sigmag;  
    MTFJ(k).lambdag=lambdag;  
    MTFJ(k).Corr.Tau=Tau;  
    MTFJ(k).Corr.Raa=Raa;
    MTFJ(k).Corr.Rab=Rab;
    MTFJ(k).Corr.Rpp=Rpp;
    MTFJ(k).Corr.Rmodel=Rmodel;

end

for k=1:length(FMAxis)
     P(k) = MTFJ(k).p;
     Sigma(k) = (MTFJ(k).sigma)^2;
     Pg(k) = MTFJ(k).pg;
     Sigmag(k) = MTFJ(k).sigmag;
end

figure
subplot(221)
semilogx(FMAxis,P,'.b-');
axis([1 2000 0 1])
subplot(223)
semilogx(FMAxis,Sigma,'.b-');
axis([1 2000 0 150])
subplot(222)
semilogx(FMAxis,Pg,'.g-');
axis([1 2000 0 1])
subplot(224)
semilogx(FMAxis,Sigmag,'.g-');
axis([1 2000 0 1])

