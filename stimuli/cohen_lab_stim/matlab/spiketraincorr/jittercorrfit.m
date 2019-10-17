%
%function [JitterData]=jittercorrfit(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)
%
%   FILE NAME   : JITTER CORR FIT
%   DESCRIPTION : Noise correlation model. Generates the shuffled, auto and
%                 noise correlograms and fits the difference between the 
%                 shuffled and auto correlograms with Gaussian function.
%                 This procedure is used to estimate the spike timing
%                 jitter and firing reliability.
%
%   spetA       : Spike train ISI array - trial A
%   spetB       : Spike train ISI array - trail B
%   Fs          : Sampling rate for spetA and spetB
%   Fsd         : Sampling rate for correlation measurement
%   T           : Recording time interval in seconds
%   MaxTau      : Maximum Correlation Delay (msec)
%   Disp        : Display Output (Optional; Default='n')
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
%       .pg          : Trial reproducibility - Gaussian Estimate
%       .lambdag     : Hypothetical spike rate - Gaussian Estimate
%                      (Assumesno jitter or trial reprodicibility errors)
%       .sigma       : Spike Timing Jitter - Direct Estimate
%       .p           : Trial reproducibility - Direct Estimate
%       .lambda      : Hypothetical Spike rate - Direct Estimate
%                      (Assumes no jitter or rial reprodicibility errors)
%
% (C) Monty A. Escabi, July 2006 (Last Edit June 2010)
%
function [JitterData]=jittercorrfit(spetA,spetB,Fs,Fsd,T,MaxTau,Disp)

%Input Arguments
if nargin<7
	Disp='n';
end

%Computing Shuffled, Auto, and Noise Correlograms
[JitterData]=jittercorr(spetA,spetB,Fs,Fsd,T,MaxTau,'n');

%Fitting Gaussian Jitter Model to Rnoise and Obtaining Direct Estimate
%Paramaeters
[JitterModel]=corrmodelfit(JitterData.Rnoise,JitterData.lambdap,JitterData.Tau,'n');

%Changing sampling rate for cases were Jitter>2 msec. If the sampling rate
%is too low (say 5kHz) the direct algorithm will be prone to computation errors
%because the amplitude of the Rnoise is very small and the SNR is very low.
if JitterModel.sigmag>2
    Fsd=1000;
    %Computing Shuffled, Auto, and Noise Correlograms
    [JitterData]=jittercorr(spetA,spetB,Fs,Fsd,T,MaxTau,'n');

    %Fitting Gaussian Jitter Model to Rnoise and Obtaining Direct Estimate
    %Paramaeters
    [JitterModel]=corrmodelfit(JitterData.Rnoise,JitterData.lambdap,JitterData.Tau,'n');
end

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