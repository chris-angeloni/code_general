%
%function [t,X,R]=ripnicorr(M,FMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,
%		  Dyadic)
%	
%	FILE NAME 	: RIP N I CORR
%	DESCRIPTION 	: Instantaneous Ripple Noise Correltion
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
%	Nsigt		: Number of std for time axis for sampling grid
%			  Default==3        
%       Dyadic          : Use a dyadic number of samples: 'y' or 'n'
%                         Default: 'n'
%RETURNED VARIABLES
%
%	t		: Time Array
%	X		: Octave Frequency Array
%	R		: Local Autocorrelation Matrix
%
function [t,X,R]=ripnicorr(M,FMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)

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

%Finding Local Ripple Noise
[t,X,S]=ripnoisei(M,FMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic);

%Finding Autocorrelation Function
%R=xcorr2(S,S);
R=xcorrfft2(S,S);
R=R*size(S,1)*size(S,2)/Fst/FsX;
R=fftshift(R);

%Regenerating Time and Spectral Axis
t=(t(2)-t(1))*(-size(R,2)/2:size(R,2)/2-1);
X=(X(2)-X(1))*(-size(R,1)/2:size(R,1)/2-1);
