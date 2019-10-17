%
%function [t,X,R]=dynripicorr(M,Fm,RD,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)
%	
%	FILE NAME 	: DYN RIP ICORR
%	DESCRIPTION 	: Dynamic Ripple Instantenous Correlation
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
%       Nsigt           : Number of std along time axis for sampling grid
%                         Default==3
%       Dyadic          : Use a dyadic number of samples: 'y' or 'n'
%                         Default: 'n'
%
%RETURNED VARIABLES
%
%       t               : Time Array
%       X               : Octave Frequency Array
%       R               : Local Autocorrelation Matrix
%
%
function [t,X,R]=dynripicorr(M,Fm,RD,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic)

%Input Parameters
if nargin<6
	FsX=20;
end
if nargin<7
	Fst=1000;
end
if nargin<8
        NsigX=3;
end
if nargin<9
        Nsigt=3;
end
if nargin<10
        Dyadic='n';
end

%Temporal and Spectral Axis
if strcmp(Dyadic,'n')                                                                   NX=ceil(NsigX*sigmaX*FsX);
        Nt=ceil(Nsigt*sigmat*Fst);
else
        NX=2^nextpow2(ceil(NsigX*sigmaX*FsX));
        Nt=2^nextpow2(ceil(Nsigt*sigmat*Fst));
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

%Generating Windowed Ripple Local AutoCorr
R=M^2/8*cos(2*pi*RD*XX+2*pi*Fm*T);
WW=exp(-T.^2/4/sigmat^2).*exp(-XX.^2/4/sigmaX^2);
R=R.*WW;
