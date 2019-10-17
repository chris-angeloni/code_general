%
%function [Tau,Ravg,Rpeak,Rmean,SIG,P,LAMBDA]=jittercorrsim(spet,sigma,p,MaxDelay,T,Fsd)
%
%       FILE NAME       : JITTER CORR SIM
%       DESCRIPTION     : Simulates a noisy action potential sequence by 
%			  adding spike timing jitter and modeling the 
%			  trial-to-trial reproducibility of the spike train 
%			  by a bernoulli process with probability p.
%			  Estimates the across-trial correlation function.
%			  Jitter probability distribution is modeled as a
%			  normal distribution with std of sigma. 
%			  Trial variability is modeled by a bernoulli process 
%			  with trial probability of producing a given action 
%			  potential of p.
%	
%	spet		: Spike event time array input
%	sigma		: Standard deviation of jitter distribution (msec).
%	p		: Trial-to-trial probability of producing an action
%			  potential.
%	MaxDelay	: Max correaltion fucntion delay (msec)
%	Fs		: Sampling rate for spet array
%	T		: Simulation time period (default= 60 seconds)
%	Fsd		: Sampling frequency of spike train (default=5,000 Hz) 
%
%Returned Variables
%	Tau		: Correlation delay array
%	Ravg		: Across-trial correlation function
%	Rpeak		: Peak value of Ravg ~= Ravg(0)
%	Rmean		: Mean value of Ravg ~= Ravg(inf) = lambda*(lambda-1)
%	SIG		: Estimated jitter standard deviation
%	P		: Estimated reproducibility probability
%	LAMBDA		: Estimated spike rate assuming p=1
%
function [Tau,Ravg,Rpeak,Rmean,SIG,P,LAMBDA]=jittercorrsim(spet,sigma,p,MaxDelay,Fs,T,Fsd)

%Input Arguments
if nargin<6
	T=60;
end
if nargin<7
	Fsd=5000;
end

%Adding spike timing Jitter
[spet1]=spetaddjitter(spet,sigma,p,Fs,Fs);
[spet2]=spetaddjitter(spet,sigma,p,Fs,Fs);

%Converting SPET to impulse spike train
[X1]=spet2impulse(spet1,Fs,Fsd);
[X2]=spet2impulse(spet2,Fs,Fsd);

%Finding Across-Trial Correlation Function
N=round(MaxDelay/1000*Fsd);
Ravg=xcorr(X1,X2,N)/Fsd/T;
Tau=(-N:N)/Fsd;
plot(Tau,Ravg)
pause(0)

%Fitting Model and Estimating Parameters
[Rmodel,Rmean,Rpeak,SIG,P,LAMBDA]=corrmodelfit(Ravg,Tau);

