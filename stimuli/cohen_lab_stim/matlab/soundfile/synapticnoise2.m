%
%function
%[N,XEf,XIf,NEf,NIf]=synapticnoise2(lambda,pscamp,T1,T2,N,Nfixed,r,rfixed,seed,seedfixed,Fs,M)
%
%       FILE NAME       : SYNAPTIC NOISE 2
%       DESCRIPTION     : Siplified Synaptic Noise Current Signal Generator
%			  Sums EPSCs and IPSCs current pulses to generate a
%			  compund synaptic noise signal with a static and 
%			  variable component. 
%			
%			  Adds presynaptic EPSC and IPSC afferent inputs that
%			  have Poisson distributed inter-event times.
%
%			  Input firing rates are normally distributed with
%			  LAMBDAMEAN and LAMBDASTD.
%
%			  Amplitude of EPSCs and IPSCs are fixed! 
%
%	lambda		: Presynaptic firing rates
%	pscamp		: Post Synaptic Current Amplitude (micro Amps)
%	T1		: EPSC/IPSC Onset Time (msec)
%	T2		: EPSC/IPSC Offset Time (msec)
%	N		: Total Number of presynaptic afferents (N>=2)
%	Nfixed		: Number of fixed presynaptic afferents
%	r		: Ratio of Excitation to Inhibition (Expressed as a
%			  r=NE/NI) for variable inputs
%	rfixed		: Ratio of Excitation to Inhibition (Expressed as a
%			  r=NE/NI) for fixed inputs
%	seed		: Starting Random number generator seeds for the
%			  random inputs
%	seedfixed	: Starting Random number generator seeds for the
%			  static inputs
%	Fs		: Sampling Rate
%	M		: Number of samples
%
%RETURNED VARIABLES
%
%	N		: Synaptic Current Noise Signal (micro Amps)
%	XEf		: Fixed excitatory spike train
%	XIf		: Fixed inhibitory spike train
%	NEf		: Fixed excitatory post synaptic current
%	NIf		: Fixed inhibitory post synaptic current
%
function [N,XEf,XIf,NEf,NIf]=synapticnoise2(lambda,pscamp,T1,T2,N,Nfixed,r,rfixed,seed,seedfixed,Fs,M)

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

%Initializing variables
XEv=zeros(1,M+2*NPSC);
XIv=zeros(1,M+2*NPSC);
XEf=zeros(1,M+2*NPSC);
XIf=zeros(1,M+2*NPSC);

%Generating Variable Pre Synaptic Afferent Input PSC 
%  Since a sum of N poissons RV is still poisson with a spike rate
%  of N*rate, we can simplify the computation of the excitatory 
%  and inhibitory inputs to a single computation where the effective
%  spike rate is simply lambda*NE and lambda*NI, respectively.
%  We can do this since the convolution for the EPSC follows the
%  associativity property. This procedure is significantly faster
%  than generating each input separately and then adding. 
%
if NE>0
	[spetE]=poissongenstat(lambda*NE,2*M/Fs,Fs,0,seed);
	XEv=spet2impulse(spetE,Fs,Fs);
end
if NI>0
	[spetI]=poissongenstat(lambda*NI,2*M/Fs,Fs,0);
	XIv=spet2impulse(spetI,Fs,Fs);
end

%Generating Fixed Pre Synaptic Afferent Input PSC 
if NEfixed>0
	[spetE]=poissongenstat(lambda*NEfixed,2*M/Fs,Fs,0,seedfixed);
	XEf=spet2impulse(spetE,Fs,Fs);
end
if NIfixed>0
	[spetI]=poissongenstat(lambda*NIfixed,2*M/Fs,Fs,0);
	XIf=spet2impulse(spetI,Fs,Fs);
end

%Convolving Compounded Spike Train (Variable + Noise) with EPSC
XEv=XEv(1:M+2*NPSC);
XIv=XIv(1:M+2*NPSC);
XEf=XEf(1:M+2*NPSC);
XIf=XIf(1:M+2*NPSC);
X=XEv-XIv+XEf-XIf;
N=conv(X,PSC)/Fs;
NEf=conv(XEf,PSC)/Fs;
NIf=conv(XIf,PSC)/Fs;
N=N(1:M);
NEf=NEf(1:M);
NIf=NIf(1:M);
