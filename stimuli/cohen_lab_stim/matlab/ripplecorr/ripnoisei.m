%
%function [t,X,S]=ripnoisei(M,FMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)
%	
%	FILE NAME 	: RIP NOISE I 
%	DESCRIPTION 	: Instantaneous Ripple Noise Envelope
%
%	M		: Amplitude (dB)
%	FMax		: maximum Temporal Modulation Rate
%	RDMax		: Maximum Ripple Density
%	L		: Number of Ripple Envelopes to Add
%	sigmaX		: Gaussian Window Spectral Std
%	sigmat		: Gaussian Window Temporal Std
%	FsX		: Spectral sampling frequency
%			  Default == 20 ripples/octave
%	Fst		: Temporal sampling frequency
%			  Default == 1000 Hz
%	NsigX		: Number of std for spectral axis for sampling grid
%			  Default==3
%	Nsigt		: Number of std along time axis for sampling grid
%			  Default==3
%	Dyadic		: 'y' or 'n'. If 'y' uses a dyadic sampling grid
%			  Default == 'n'
%
%RETURNED VARIABLES
%
%       t               : Time Array
%       X               : Octave Frequency Array
%       S               : Local Envelope Matrix
%
function [t,X,S]=ripnoisei(M,FMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)

%Input Parameters
if nargin<7
	FsX=20;
end
if nargin<8
	Fst=1000;
end
if nargin<9
	NsigX=3;
end
if nargin<10
	Nsigt=3;
end
if nargin<11
	Dyadic='n';
end

%Temporal and Spectral Axis
if strcmp(Dyadic,'n')
        NX=ceil(NsigX*sigmaX*FsX);
        Nt=ceil(Nsigt*sigmat*Fst);
else
        Nt=2^nextpow2(ceil(Nsigt*sigmat*Fst));
        NX=2^nextpow2(ceil(NsigX*sigmaX*FsX));
end
t=(-Nt:Nt-1)/Fst;
X=(-NX:NX-1)/FsX;
XX=ones(length(X),length(t));
T=ones(length(X),length(t));
for k=1:length(t)
	T(:,k)=T(:,k)*t(k);
end
for k=1:length(X)
	XX(k,:)=XX(k,:)*X(k);
end

%Generating Windowed Ripple Noise
S=zeros(size(T,1),size(T,2));
for k=1:L
	PH=2*pi*rand;
	RD=RDMax*rand;
	Fm=FMax*2*(rand-.5);
	S=S+1/sqrt(L)*M/2*sin(2*pi*RD*XX+2*pi*Fm*T+PH);
end

%Designing Window of Unit Energy
W=1/sqrt(pi*sigmaX*sigmat).*exp(-T.^2/2/sigmat^2).*exp(-XX.^2/2/sigmaX^2);

%Multiplying Window And Ripple Noise Envelope
S=S.*W;
