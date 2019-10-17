%
%function [t,X,R]=dynripicorrkl(M,Fm1,RD1,Fm2,RD2,sigmaX,sigmat,FsX,Fst,NsigX,
%		  Nsigt,Dyadic)
%	
%	FILE NAME 	: DYN RIP ICORR KL
%	DESCRIPTION 	: Dynamic Ripple Instantenous Cross Correlation
%			  For two ripple components k and l
%
%	M		: Amplitude (dB)
%	Fm		: Temporal Modulation Rate
%	RD		: Ripple Density
%	sigmaX		: Gaussian Window Spectral Std
%	sigmat		: Gaussian Window Temporal Std
%	FsX		: Spectral sampling frequency
%			  Default == 20 ripples/octave
%	Fst		: Temporal sampling frequency
%			  Default == 1000 Hz
%       NsigX           : Number of std for spectral axis for sampling grid
%                         Default==3
%       Nsigt           : Number of std for time axis for sampling grid
%                         Default==3
%       Dyadic          : Use a dyadic number of samples: 'y' or 'n'
%			  Default=='n'
%
%RETURNED VARIABLES
%
%       t               : Time Array
%       X               : Octave Frequency Array
%       R               : Local Autocorrelation Matrix
%
function [t,X,R]=dynripicorrkl(M,Fm1,RD1,Fm2,RD2,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)

%Input Parameters
if nargin<8
	FsX=20;
end
if nargin<9
	Fst=1000;
end
if nargin<10
        NsigX=3;
end
if nargin<11
        Nsigt=3;
end
if nargin<12
        Dyadic='n';
end

%Generating Windowed Ripple X-Corr
PH1=2*pi*rand;
[t1,X1,S1]=dynripplei(M,Fm1,RD1,PH1,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic);
PH2=2*pi*rand;
[t2,X2,S2]=dynripplei(M,Fm2,RD2,PH2,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic);
R=xcorrfft2(S1,S2);
R=R*size(S1,1)*size(S1,2)/Fst/FsX;
R=fftshift(R);
 
