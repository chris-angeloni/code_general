%
%function [FmAxis,RDAxis,P]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF,Norm,dis,ATT)
%	
%	FILE NAME 	: RIPPLESPEC
%	DESCRIPTION : Computes the ripple spectrum of a sound.
%
%	data    : Input data
%	Fs		: Sampling Rate
%	dX		: Spectral Filter Bandwidth Resolution in Octaves
%			  Usually a fraction of an octave ~ 1/8 would allow 
%			  for a spectral envelope resolution of up to 4 
%			  cycles per octave
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation 
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%	Fm		: Maximum Modulation frequency allowed for temporal
%			  envelope at each band. If Fm==inf full range of Fm is used.
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%	dis		: display (optional): 'log' or 'lin' or 'n'
%			  Default == 'n'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB
%
%RETURNED VARIABLES
%
%   taxis   : Time axis
%   faxis   : Frequency axis
%   S       : Audiogram
%   Sf      : Spectral Envelope Distribution
%
% (C) Monty A. Escabi, July 2008 (Edit Nov 2008)
%
function [FmAxis,RDAxis,P]=ripplespec(data,Fs,dX,dFm,f1,fN,Fm,OF,Norm,dis,ATT)

%Input Parameters
if nargin<9
    Norm='En';
end
if nargin<10
	dis='n';
end
if nargin<11
	ATT=60;
end

%Temporal Down Sampling Factor - see Audiogram.m
DF=ceil(Fs/2/Fm/OF);

%Normalizing Sound for Unit Variance
data=data/std(data);

%Generating Audiogram
[taxis,faxis,S,Sf]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);

%Number of temporal samples used for each analysis block
Fst=1/(taxis(2)-taxis(1));
Nt=pow2(nextpow2(ceil(1/dFm*Fst)));

%Generating ripple spectrum
k=1;
P=zeros(size(S,1),Nt);
while length(S)>k*Nt
    
    for l=1:size(P,1)
       MS=(mean(S(l,(k-1)*Nt+1:k*Nt)));
       S(l,:)=S(l,:)-MS;
    end
   P=P+fftshift(abs(fft2(S(:,(k-1)*Nt+1:k*Nt))).^2);
   k=k+1;
   
end
P=P/(k-1);

%Spectral and Temporal Modulation Axis
FmAxis=(-Nt/2:Nt/2-1)/Nt*Fst;
Nx=size(P,1);
RDAxis=1/dX*(-Nx/2:Nx/2-1)/Nx;