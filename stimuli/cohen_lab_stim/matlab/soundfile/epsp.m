%
%function [EPSP]=epsp(d1,d2,alpha,Fs)
%
%       FILE NAME       : EPSP
%       DESCRIPTION     : Generates a short Excitatory Post Synaptic 
%			  Potential Signal
%
%	d1		: Rise Time Constant (msec)
%	d2		: Decay Time Constant (msec)
%	alpha		: EPSP Amplitude
%	Fs		: Sampling Rate
%
%OUTPUT SIGNAL
%
%	EPSP		: EPSP Array
%
function [EPSP]=epsp(d1,d2,alpha,Fs)

%Converting Decay and Rise Times from msec to sec
d1=d1/1000;
d2=d2/1000;

%Finding Discrete values of d1 and d2
N1=ceil(d1*Fs);
N2=ceil(10*d2*Fs);
N=N1+N2;

%Generating EPSP (2 segments)
t1=(0:N1)/Fs;
EPSP(1:N1+1)=alpha*t1/d1.*exp(-t1/d1);
t2=(N1+2:N2)/Fs;
EPSP(N1+2:N2)=alpha.*(t2+d2-d1)/d2.*exp((-t2+d1-d2)/d2);

%Normalizing Amplitude
EPSP=EPSP/max(EPSP)*alpha;
