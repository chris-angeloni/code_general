%
%function [Nsig,sigma,p,lambda,Delay,Ravg,R05]=jittercorrifnsig(Im,In,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,NB,flag,L)
%
%       FILE NAME       : JITTER CORR IF NSIG
%       DESCRIPTION     : Simulates JITTERCORRIFSIM as a function of Nsig, the
%			  integrate fire neuron relative threshold
%
%	Im		: Input Membrane Current Signal
%	In		: Input Noise Signal ( its duration should be at 
%			  least twice as long as Im: length(In)>2length(Im))
%	Tau		: Integration time constant Array (msec)
%	Tref		: Refractory Period (msec)
% 	Vtresh		: Threshold Membrane Potential (mVolts)
% 	Vrest		: Resting Membrane Potential - Same as the Leackage
% 			  Membrane Potential (mVolts)
%	Nsig		: Array of threshold values to run simulation
% 	                  Number of standard deviations of the
% 			  intracellular voltage to set the spike
% 			  threshold
% 	SNR		: Signal to Noise Ratio Array ( SNR~=0 )
% 			  SNR = sigma_in^2/sigma_n^2
% 	Fs		: Sampling Rate
%	NB		: Numbrer of Bootstrap Itterations
% 	flag		: flag = 0: Input current variance is constant (Default)
%				    sig_tot^2 = sig_i^2 + sig_n^2
%				    where sig_n = sig_i/sqrt(SNR)  and 
%				    sig_i=constant is choosen so that 
%				    sig_m = (Vtresh-Vrest)/Nsig
%				1: Total current variance is constant
%				    Same as 0 except that sig_tot is chosen so
%				    so that sig_m = (Vtresh-Vrest)/Nsig
%	L		: Number of Trials for simulation (Default==25)
%
%Returned Variables
%	Nsig		: Integrate Fire neuron relative threshold array
%	sigma		: Estimated jitter standard deviation
%	p		: Estimated reproducibility probability
%	lambda		: Estimated spike rate assuming p=1
%
function [Nsig,SNR,sigma,p,lambda,Delay,Ravg,R05]=jittercorrifnsig(Im,In,Tau,Tref,Vtresh,Vrest,Nsig,SNR,Fs,NB,flag,L)

%Input Arguments
if nargin<10
	NB=500;
end
if nargin<11
	flag=0;
end
if nargin<12
	L=25;
end

%Simulating Model over All Parameters
count1=1;
count2=1;
for Nsigt=Nsig
		for SNRt=SNR

%Simulating IF Neuron and Computing Jitter/Reproducibility
[Delay,Ravg(:,count1,count2),Rstd,R05,R01,Rpeak,Rmean,sigma(count1,count2),p(count1,count2),lambda(count1,count2)]=jittercorrifsim(Im,Tau,Tref,Vtresh,Vrest,Nsigt,SNRt,Fs,NB,flag,L,In);

%Plotting Correlation
%plot(1000*Delay,Ravg(:,count1,count2))
%xlabel('Delay (msec)')
%ylabel('Crosscorrelation Amplitude')
%pause(0)

			count2=count2+1;
	end
	count1=count1+1;
end

