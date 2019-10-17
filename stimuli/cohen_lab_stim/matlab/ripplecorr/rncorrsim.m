%
%function [E]=rncorrsim(M,FmMax,RDMax,sigmaX,sigmat,L,K,FsX,Fst,NsigX,Nsigt,
%	      Dyadic)
%	
%	FILE NAME 	: RN CORR SIM
%	DESCRIPTION 	: Ripple Noise Correlation Simulation
%
%	M		: Ripple amplitude ( dB )
%	FmMax		: Maximum Temporal Modulation Rate
%	RDMax		: Maximum Ripple Density
%	sigmaX		: Gaussian Window Spectral Std
%	sigmat		: Gaussian Window Temporal Std
%	L		: Number of dynamic ripples to add
%	K		: Number of itterations for simmulation
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
%	E		: Error Signal Enregy Array 
%			  (for K Trials).
%
function [E]=rncorrsim(M,FmMax,RDMax,sigmaX,sigmat,L,K,FsX,Fst,NsigX,Nsigt,Dyadic)

%Input Arguments
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

%Global Autocorr for ideal RN
[t,X,RG]=dynripgcorr(M,FmMax,RDMax,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic);

%Finding Ensemble Mean Autocorr Error
N1=size(RG,1);
N2=size(RG,2);
for k=1:K

	%Displaying Output
	clc
	disp(['Iteration ' num2str(k) ' of ' num2str(K) ])

	%Finding Error
	[t,X,R]=ripnicorr(M,FmMax,RDMax,L,sigmaX,sigmat,FsX,Fst,NsigX,Nsigt,Dyadic); 
	EE=reshape(R-RG,1,N1*N2);
%	E(k)=sqrt(sum(EE.^2)/FsX/Fst); 
%	E(k)=std(EE)/sqrt(FsX*Fst); 
	E(k)=std(EE); 

end

