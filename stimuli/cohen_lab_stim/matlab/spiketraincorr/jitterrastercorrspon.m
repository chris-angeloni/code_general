%
%function [JitterData]=jitterrastercorrspon(RASTER,Fsd,MaxTau,Disp)
%
%   FILE NAME   : JITTER CORR SPON
%   DESCRIPTION : Generates the shuffled and autocorrelograms used to
%                 estimate spike timing precicison and reliability when
%                 spontaneous firing is present.%
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Desired sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%   Disp            : Display Output (Optional; Default='n')
%
%RETURNED VARIABLES
%
%   JitterData: Data Structure containgin
%       .Tau         : Delay Axis (msec)
%       .Raa         : Autocorrelation
%       .Rab         : Crosscorrelation
%       .RaaS        : ISI shuffled crosscorrelogram
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .lambdap     : Measured spike rate. Ideal spike rate x p.
%
% (C) Monty A. Escabi, June 2010
%
function [JitterData]=jitterrastercorrspon(RASTER,Fsd,MaxTau,Disp)

%Input Arguments
if nargin<4
	Disp='n';
end

%Estimating auto and cross correlations
[CorrData]=rastershuffledcorrfast(RASTER,Fsd,MaxTau);
Rab=CorrData.Rab;
Raa=CorrData.Raa;

%Estimating ISI shuffled auto and cross correlations
RASTERS=shuffleraster(RASTER);
[CorrDataS]=rastershuffledcorrfast(RASTERS,Fsd,MaxTau);
RabS=CorrDataS.Rab;
RaaS=CorrDataS.Raa;

%Estimating Mean Spike Rate including reliability errors
lambdap=mean(mean(rasterexpand(RASTER,Fsd,RASTER(1).T)));
lambdapS=mean(mean(rasterexpand(RASTERS,Fsd,RASTERS(1).T)));

%Estimating Noise Correlation Function
N=(length(Raa)-1)/2;
%Raa(N+1)=Raa(N+1)-lambdap*Fsd;
%RaaS(N+1)=RaaS(N+1)-lambdapS*Fsd;
Rnoise=Rab-Raa+(RaaS-lambdap^2)/lambdap^2*lambdap^2;
Tau=(-N:N)/Fsd*1000;

%Saving Raw Data in Structure
JitterData.Tau=Tau;
JitterData.Raa=Raa;
JitterData.RaaS=RaaS;
JitterData.Rab=Rab;
JitterData.RabS=RabS;
JitterData.Rnoise=Rnoise;
JitterData.lambdap=lambdap;

%Plotting Results
if strcmp(Disp,'y')
	subplot(211)
	plot(Tau,Raa)
	hold on
	plot(Tau,Rab,'r')
	ylabel('Raa (blue), Rab (red)')
	hold off

	subplot(212)
	plot(Tau,Rnoise)
	xlabel('Delay (msec)')
	ylabel('Rnoise - Jitter Correlation')
	pause(0)
end