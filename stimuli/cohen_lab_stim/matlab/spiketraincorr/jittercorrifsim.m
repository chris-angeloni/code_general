%
%function [Tau,Ravg,Rstd,R05,R01,Rpeak,Rmean,sigma,p,lambda]=jittercorrifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,NB,flag,L,In)
%
%       FILE NAME       : JITTER CORR IF SIM
%       DESCRIPTION     : Simulates a noisy action potential sequence by 
%			  presenting a reference input to an integrate-
%			  fire model neuron and adding a noise current.
%			  The across-trial correlation function is then 
%			  estimated to find the jitter and reproducibility 
%			  parameters for a given set of intracellular
%			  parameters of the integrate fire neuron.
%			  Jitter probability distribution is modeled as a
%			  normal distribution with std of sigma. 
%			  Trial variability is modeled by a bernoulli process 
%			  with trial probability of producing a given action 
%			  potential of p.
%
%	Im		: Input Membrane Current Signal
%	Tau		: Integration time constant (msec)
%	Tref		: Refractory Period (msec)
% 	Vtresh		: Threshold Membrane Potential (mVolts)
% 	Vrest		: Resting Membrane Potential - Same as the Leackage
% 			  Membrane Potential (mVolts)
% 	Nsig		: Number of standard deviations of the
% 			  intracellular voltage to set the spike
% 			  threshold
% 	SNR		: Signal to Noise Ratio ( SNR!=0 )
% 			  SNR = sigma_in^2/sigma_n^2
% 	Fs		: Sampling Rate
%	NB		: Number of Bootstraps for Correlation Estimate
%			  Default = 500
% 	flag		: flag = 0: Input current variance is constant (Default)
%				    sig_tot^2 = sig_i^2 + sig_n^2
%				    where sig_n = sig_i/sqrt(SNR)  and 
%				    sig_i=constant is choosen so that 
%				    sig_m = (Vtresh-Vrest)/Nsig
%				1: Total current variance is constant
%				    Same as 0 except that sig_tot is chosen so
%				    so that sig_m = (Vtresh-Vrest)/Nsig
%	L		: Number of Trials for simulation (Default==25)
%	In		: Intracellular Synaptic Noise (Optional, its
%			  duration should be at least twice as long as Im
%			  length(In) > 2*length(Im) )
%
%Returned Variables
%	Tau		: Correlation delay array
%	Ravg		: Across-trial correlation function
%	Rstd		: Across-trial correlation standard deviation array
%	R05		: Across-trial correlation p<0.05 confidence
% 			  interval. 2xlength(R) matrix containing the possitive
% 			  and the negative confidence intervals
% 	R01		: Across-trial correlation p<0.01 confidence
%			  interval. 2xlength(R) matrix containing the possitive
%			  and the negative confidence intervals
%	Rpeak		: Peak value of Ravg ~= Ravg(0)
%	Rmean		: Mean value of Ravg ~= Ravg(inf) = lambda*(lambda-1)
%	sigma		: Estimated jitter standard deviation
%	p		: Estimated reproducibility probability
%	lambda		: Estimated spike rate assuming p=1
%
function [Tau,Ravg,Rstd,R05,R01,Rpeak,Rmean,sigma,p,lambda]=jittercorrifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,NB,flag,L,In)

%Input Arguments
if nargin<9
	NB=500;
end
if nargin<10
	flag=0;
end
if nargin<11
	L=25;
end

%Generating Simulated Rastergram
if exist('In')
	[taxis,RASTER]=rasterifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L,In);
else
	[taxis,RASTER]=rasterifsim(Im,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,flag,L);
end

%Computing Across-Trial Raster Correlation 
taxis=(1:size(RASTER,2))/Fs;
[Ravg,Rstd,R05,R01]=rastercorr(RASTER,taxis,250,NB);

%Fiting Correlation Parameters
N=(length(Ravg)-1)/2;
Tau=(-N:N)/Fs;
[Rmodel,Rmean,Rpeak,sigma,p,lambda]=corrmodelfit(Ravg,Tau);
