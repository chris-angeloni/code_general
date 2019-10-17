%
%function [JitterData]=jitterrastercorrfit(RASTER,Fsd,MaxTau,Disp)
%
%   FILE NAME       : JITTER RASTER CORR FIT
%   DESCRIPTION     : Correlation model to fit Cross-Channel correlation
%			          from RASTERGRAM.
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Desired sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%   Disp            : Display Output (Optional; Default='n')
%
%Returned Variables
%
%   JitterData: Data Structure containgin
%       .Tau         : Delay Axis (msec)
%       .Raa         : Autocorrelation
%       .Rab         : Crosscorrelation
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .pg          : Trial reproducibility - Gaussian Estimate
%       .lambdag     : Hypothetical spike rate - Gaussian Estimate
%                      (Assumesno jitter or trial reprodicibility errors)
%       .sigma       : Spike Timing Jitter - Direct Estimate
%       .p           : Trial reproducibility - Direct Estimate
%       .lambda      : Hypothetical Spike rate - Direct Estimate
%                      (Assumes no jitter or rial reprodicibility errors)
%
% (C) Monty A. Escabi, August 2006 (Edit August 2010)
%
function [JitterData]=jitterrastercorrfit(RASTER,Fsd,MaxTau,Disp)

%Input Arguments
if nargin<4
	Disp='n';
end

%Computing Shuffled, Auto, and Noise Correlograms
[JitterData]=jitterrastercorr(RASTER,Fsd,MaxTau,'n');

%Fitting Gaussian Jitter Model to Rnoise and Obtaining Direct Estimate
%Paramaeters
[JitterModel]=corrmodelfit(JitterData.Rnoise,JitterData.lambdap,JitterData.Tau,'n');

%Combining Model and Estimated Parameters
JitterData.Rmodel=JitterModel.Rmodel;
JitterData.sigmag=JitterModel.sigmag;
JitterData.pg=JitterModel.pg;
JitterData.lambdag=JitterModel.lambdag;
JitterData.sigma=JitterModel.sigma;
JitterData.p=JitterModel.p;
JitterData.lambda=JitterModel.lambda;

%Plotting Results
if strcmp(Disp,'y')
	subplot(211)
	plot(JitterData.Tau,JitterData.Raa)
	hold on
	plot(JitterData.Tau,JitterData.Rab,'r')
	ylabel('Raa (blue), Rab (red)')
	hold off

	subplot(212)
	plot(JitterData.Tau,JitterData.Rnoise)
	xlabel('Delay (msec)')
	ylabel('Rnoise - Jitter Correlation')
	hold on
	plot(JitterData.Tau,JitterData.Rmodel,'r')
	hold off
	pause(0)
end