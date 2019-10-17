%
%function [JitterData]=jitterrastercorrfitspon(RASTER,Fsd,MaxTau,Disp)
%
%   FILE NAME   : JITTER RASTER CORR FIT SPON
%   DESCRIPTION : Noise correlation model. Generates the shuffled, auto and
%                 noise correlograms estimated from a dot-raster.
%                 This procedure is used to estimate the spike timing
%                 jitter and firing reliability and spontaneous noise.
%
%	RASTER          : Rastergram in compressed format
%   Fsd             : Desired sampling rate for correlation measurement
%   MaxTau          : Maximum Correlation Delay (msec)
%   Disp            : Display Output (Optional; Default='n')
%
%Returned Variables
%
%   JitterData: Data Structure containing
%       .Tau         : Delay Axis (msec)
%       .Raa         : Autocorrelation
%       .RaaS        : ISI shuffled autocorrelation
%       .Rab         : Crosscorrelation
%       .RabS        : ISI shuffled crosscorrelation
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .lambdap     : Estimated spike rate
%       .lambdas     : Estimated spontaneous spike rate
%       .lamdad      : Estimated driven spike rate
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .pg          : Trial reproducibility - Gaussian Estimate
%       .phog        : Reliability of driven spikes, normal model
%       .lambdag     : Hypothetical spike rate - Gaussian Estimate
%                      (Assumesno jitter or trial reprodicibility errors)
%       .sigma       : Spike Timing Jitter - Direct Estimate
%       .p           : Trial reproducibility - Direct Estimate
%       .pho         : Reliability of driven spikes, direct estimate 
%       .lambda      : Hypothetical Spike rate - Direct Estimate
%                      (Assumes no jitter or rial reprodicibility errors)
%       .E           : Optimization error curve (e = Rnoise - Rmodel)
%                      versus lamdas
%       .dl          : Resolution for lambdas used to generate E
%
% (C) Monty A. Escabi, Jan 2011
%
function [JitterData]=jitterrastercorrfitspon(RASTER,Fsd,MaxTau,Disp)

%Input Arguments
if nargin<4
	Disp='n';
end

%Computing Shuffled, Auto, and Noise Correlograms
[JitterData]=jitterrastercorrspon(RASTER,Fsd,MaxTau,'n')

%Fitting Gaussian Jitter Model to Rnoise and Obtaining Direct Estimate
%Paramaeters
[JitterModel]=corrmodelfitspon(JitterData,'n');


%Changing sampling rate for cases were Jitter>1.5 msec. If the sampling rate
%is too high (say 5kHz) the direct algorithm will be prone to computation errors
%because the amplitude of the Rnoise is very small and the SNR is very low.
if JitterModel.sigmag>1.5
    Fsd=1000;
    %Computing Shuffled, Auto, and Noise Correlograms
    [JitterData]=jitterrastercorrspon(RASTER,Fsd,MaxTau,'n')

    %Fitting Gaussian Jitter Model to Rnoise and Obtaining Direct Estimate
    %Paramaeters
    [JitterModel]=corrmodelfitspon(JitterData,'n');
end

%Combining Model and Estimated Parameters
JitterData.Rnoise=JitterModel.Rnoise;   %Note that now we optimize for Rnoise
JitterData.lambdas=JitterModel.lambdas; %Note that now we optimize for lambdas
JitterData.lambdad=JitterModel.lambdad; %Note that now we optimize for lambdas
JitterData.Rmodel=JitterModel.Rmodel;
JitterData.sigmag=JitterModel.sigmag;
JitterData.pg=JitterModel.pg;
JitterData.phog=JitterModel.phog;
JitterData.lambdag=JitterModel.lambdag;
JitterData.sigma=JitterModel.sigma;
JitterData.p=JitterModel.p;
JitterData.pho=JitterModel.pho;
JitterData.lambda=JitterModel.lambda;
JitterData.E=JitterModel.E;
JitterData.dl=JitterModel.dl;

%Plotting Results
if strcmp(Disp,'y')
	subplot(211)
	plot(JitterData.Tau,JitterData.Raa)
	hold on
    plot(JitterData.Tau,JitterData.RaaS,'g')
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