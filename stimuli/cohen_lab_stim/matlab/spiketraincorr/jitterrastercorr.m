%
%function [JitterData]=jitterrastercorr(RASTER,Fsd,MaxTau,Disp)
%
%   FILE NAME   : JITTER CORR
%   DESCRIPTION : Noise correlation model. Fits the difference between the 
%                 shuffled and auto correlograms with Gaussian function.
%                 This procedure is used to estimate the spike timing
%                 jitter and firing reliability.
%
%                 JITTERCORRFIT is similar but also estimates jitter
%                 parameters.
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
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .lambdap     : Measured spike rate. Ideal spike rate x p.
%
% (C) Monty A. Escabi, June 2010
%
function [JitterData]=jitterrastercorr(RASTER,Fsd,MaxTau,Disp)

%Input Arguments
if nargin<4
	Disp='n';
end

%Estimating auto and cross correlations
[CorrData]=rastershuffledcorrfast(RASTER,Fsd,MaxTau);
Rab=CorrData.Rab;
Raa=CorrData.Raa;

%Estimating Mean Spike Rate including reliability errors
lambdap=mean(mean(rasterexpand(RASTER,Fsd,RASTER(1).T)));

%Estimating Jitter Correlation Function
N=(length(Raa)-1)/2;
%Raa(N+1)=Raa(N+1)-lambdap*Fsd;
Rnoise=Rab-Raa;
Tau=(-N:N)/Fsd*1000;

%Saving Raw Data in Structure
JitterData.Tau=Tau;
JitterData.Raa=Raa;
JitterData.Rab=Rab;
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