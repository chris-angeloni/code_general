%
%function [SynapticNoise,Inputs]=synapticnoiseraddy(lambda,T1,T2,N,Nfixed,r,rfixed,Fs,M)
%
%       FILE NAME       : SYNAPTIC NOISE RADDY
%       DESCRIPTION     : Synaptic Noise Current Signal Generator used by 
%			  Raddy Ramos to test the input-output properties of 
%			  a collection of neurons from a large enseble. 
%			
%			  Adds presynaptic EPSC and IPSC afferent inputs that
%			  have Poisson distributed inter-event times.
%
%			  Input firing rates are constant
%
%			  Amplitude of EPSCs and IPSCs are fixed (1 microAmp)! 
%
%	lambda		: Presynaptic firing rates
%	T1		: EPSC/IPSC Onset Time (msec)
%	T2		: EPSC/IPSC Offset Time (msec)
%	N		: Total Number of presynaptic afferents (N>=2)
%	Nfixed		: Number of fixed presynaptic afferents
%	r		: Ratio of Excitation to Inhibition (Expressed as a
%			  r=NE/NI) for variable inputs
%	rfixed		: Ratio of Excitation to Inhibition (Expressed as a
%			  r=NE/NI) for fixed inputs
%	Fs		: Sampling Rate
%	M		: Number of samples
%
%RETURNED VARIABLES
%
%	SynapticNoise	: Pre Synaptic Noise Input
%	Inputs		: Data Structure Containg all of the Pre Synaptic 
%			  Inputs for the population of neurons
%
function [SynapticNoise,Inputs]=synapticnoiseraddy(lambda,T1,T2,N,Nfixed,r,rfixed,Fs,M)

%Finding PSC signs (+/- for Exc/Inh) for fixed inputs
NEfixed=round(rfixed/(1+rfixed)*(Nfixed));
NIfixed=round((Nfixed)/(1+rfixed));

%Finding PSC signs (+/- for Exc/Inh) for variable inputs 
NE=round(r/(1+r)*N)-NEfixed;
NI=round(N/(1+r))-NIfixed;

%Display Number and Type of Inputs
disp(['Variable Excitatory Inputs: ' int2str(NE)])
disp(['Variable Inhibitory Inputs: ' int2str(NI)])
disp(['Fixed Excitatory Inputs:    ' int2str(NEfixed)])
disp(['Fixed Inhibitory Inputs:    ' int2str(NIfixed)])

%Post Synaptic Current
PSC=epsp(T1,T2,1,Fs);
NPSC=length(PSC);

%Data Length  - Extending by 50 %
MM=round(1.5*M);

%Generating Fixed Pre Synaptic Afferent Input PSC 
for k=1:NEfixed
	Inputs.Ex.Fixed(k).spet=poissongenstat(lambda,MM/Fs,Fs,1,k);
end
for k=1:NIfixed
	Inputs.In.Fixed(k).spet=poissongenstat(lambda,MM/Fs,Fs,1,k+NEfixed);
end

%Generating Variable Pre Synaptic Afferent Input PSC 
rand('seed',sum(100*clock));
for k=1:NE
	Inputs.Ex.Variable(k).spet=poissongenstat(lambda,MM/Fs,Fs,1);
end
for k=1:NI
	Inputs.In.Variable(k).spet=poissongenstat(lambda,MM/Fs,Fs,1);
end

%Generating Excitatory Synaptic Noise
SpetEx=[];
for k=1:NEfixed
	SpetEx=[SpetEx Inputs.Ex.Fixed(k).spet];
end
for k=1:NE
	SpetEx=[SpetEx Inputs.Ex.Variable(k).spet];
end
SpetEx=sort(SpetEx);
ExNoise=spet2impulse(SpetEx,Fs,Fs);
ExNoise=conv(ExNoise,PSC)/Fs;

%Generating Inhibitory Synaptic Noise
SpetIn=[];
for k=1:NIfixed
	SpetIn=[SpetIn Inputs.In.Fixed(k).spet];
end
for k=1:NI
	SpetIn=[SpetIn Inputs.In.Variable(k).spet];
end
SpetIn=sort(SpetIn);
InNoise=spet2impulse(SpetIn,Fs,Fs);
InNoise=conv(InNoise,PSC)/Fs;

%Truncate Total Noise Signal
SynapticNoise=ExNoise(1:M)-InNoise(1:M);

%Adding Other Relevant Information to Data Structure
Inputs.psc=PSC;
Inputs.NE=NE;
Inputs.NI=NI;
Inputs.NEfixed=NEfixed;
Inputs.NIfixed=NIfixed;
Inputs.Fs=Fs;
Inputs.lambda=lambda;
Inputs.M=M;

