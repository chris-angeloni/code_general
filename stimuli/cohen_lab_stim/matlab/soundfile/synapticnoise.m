%
%function [In]=synapticnoise(lambdamean,lambdastd,pscamean,pscastd,T1,T2,N,r,Fs,M,seed)
%
%       FILE NAME       : SYNAPTIC NOISE
%       DESCRIPTION     : Synaptic Noise Current Signal Generator
%                         Sums EPSCs and IPSCs current pulses to generate a
%                         compund synaptic noise signal.
%
%                         Adds presynaptic EPSC and IPSC afferent inputs that
%                         have Poisson distributed inter-event times.
%
%                         Input firing rates are normally distributed with
%                         LAMBDAMEAN and LAMBDASTD.
%
%                         Amplitude of EPSCs and IPSCs are normally distributed
%                         with PSCAMEAN and PSCASTD.
%
%       lambdamean      : Mean presynaptic firing rates
%       lambdastd       : Standard deviation of pre synaptic firing rates
%       pscamean        : Post Synaptic Current Amplitudes Mean (micro Amps)
%       pscastd         : Post Synaptic Current Amplitudes Standard 
%                         Deviation (micro Amps)
%       T1              : EPSC/IPSC Onset Time (msec)
%       T2              : EPSC/IPSC Offset Time (msec)
%       N               : Total Number of presynaptic afferents (N>=2)
%       r               : Ratio of Excitation to Inhibition (Expressed as a
%                         r=NE/NI)
%       Fs              : Sampling Rate
%       M               : Number of samples
%       seed            : Random number seed (Optional)
%
%RETURNED VARIABLES
%
%       In               : Synaptic Current Noise Signal (micro Amps)
%
%   (C) Monty A. Escabi, Edited September 2006
%
function [In]=synapticnoise(lambdamean,lambdastd,pscamean,pscastd,T1,T2,N,r,Fs,M,seed)

%Setting Seed if Necessary
if exist('seed')
   rand('state',seed); 
   randn('state',seed+1);
end

%Finding Firing Rates, PSC Amplitudes, and PSC signs (+/- for Exc/Inh)
lambda=betarnd(2,2,1,N);
psca=betarnd(2,2,1,N);
if N==1
	lambda=lambdamean;
	psca=pscamean;
else
	lambda=(lambda-.5)/std(lambda)*lambdastd+lambdamean;
	psca=(psca-.5)/std(psca)*pscastd+pscamean;
end
NE=round(r/(1+r)*N);
NI=round(N/(1+r));
pscsign=[ones(1,NE) -ones(1,NI)];

%Generating Compound Synaptic Current 
In=zeros(1,M);
for k=1:N
	clc
	disp(['Adding Presynaptic Input Currents (Afferent Number): ' int2str(k)])

	%Post Synaptic Current	
	PSC=epsp(T1,T2,1,Fs);
	
	%Generating Pre Synaptic Afferent Input PSC 
    if exist('seed')
        [spet]=poissongenstat(lambda(k),2*M/Fs,Fs,1,seed+k+2);
    else
        [spet]=poissongenstat(lambda(k),2*M/Fs,Fs,1);
    end
	X=spet2impulse(spet,Fs,Fs);
	X=conv(X,PSC)/Fs;

	%Adding to Generate Compound PSC
    In=In+pscsign(k)*psca(k)*X(1:M);
end
