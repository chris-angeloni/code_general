%
%function [faxis,Sxx]=audiogramspec(data,Fs,dX,f1,fN,dis)
%	
%	FILE NAME 	: AUDIOGRAM SPECTRUM
%	DESCRIPTION : Sound Spectrum obtained by applying a octave spaced 
%                 filterbank with criticalband bandwidths
%
%	data    : Input data
%	Fs		: Sampling Rate
%	dX		: Filter spacing resolution in octaves
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation 
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%
%RETURNED VARIABLES
%
%   faxis   : Frequency axis
%   Sxx     : Audiogram power spectrum
%
% (C) Monty A. Escabi, August 2008
%
function [faxis,Sxx]=audiogramspec(data,Fs,dX,f1,fN,Norm)

%Input Parameters
if nargin<6
    Norm='En';
end

%Finding frequency axis for chromatically spaced filter bank
%Note that chromatic spacing requires : f(k) = f(k+1) * 2^dX
X1=0;
XN=log2(fN/f1);
L=floor(XN/dX);
Xc=(.5:L-.5)/L*XN;
fc=f1*2.^Xc;

%Finding filter characterisitic frequencies according to Greenwood
%[fc]=greenwoodfc(20,20000,.1);

%Finding filter bandwidhts assuming 1 critical band
BW=criticalbandwidth(fc);

%Generating Gammatone Filters
for k=1:length(fc)
    [GammaTone(k).H]=gammatonefilter(3,BW(k),fc(k),Fs);
    N(k)=(length(GammaTone(k).H)-1)/2;
end

%FFT Size
NFFT=2 ^ nextpow2( length(data) + max(N)*2+1 );

%Filtering data
for k=1:length(fc)

	%Output Display
	clc,disp(['Filtering band ' int2str(k) ' of ' int2str(length(fc))]) 

	%Gamma Tone Filter
    H=GammaTone(k).H;
    if strcmp(Norm,'En')
        H=H/sqrt(sum(H.^2));    %Equal Energy
    end
    
	%Filtering at kth Scale
	Y=convfft(data',H,0,NFFT,'y');      %Changed delayed from N(k) to zero
    
	%Downsampling Envelope
    Sxx(k)=var(Y);
    
end
faxis=fc;