%
%function [AudData]=audiogramduck(data,Fs,dX,f1,fN,Fm,Norm,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM
%	DESCRIPTION : Spectro-temporal signal representation obtained 
%                 by applying a octave spaced filterbank and
%                 extracting envelope modulation signal. Uses critical
%                 bandwidth Gamma tone filters for the auditory
%                 model decomposition.
%
%	data    : Input data
%	Fs		: Sampling Rate
%	dX		: Spectral separation betwen adjacent filters in octaves
%			  Usually a fraction of an octave ~ 1/8 would allow 
%			  for a spectral envelope resolution of up to 4 
%			  cycles per octave
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation 
%	f1		: Lower frequency to compute spectral decomposition
%	fN		: Upper freqeuncy to compute spectral decomposition
%	Fm		: Maximum Modulation frequency allowed for temporal
%			  envelope at each band. If Fm==inf full range of Fm is used.
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%	dis		: display (optional): 'y' or 'n'
%			  Default == 'n'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB
%
%RETURNED VARIABLES
%
%   AudData : Data structure containing audiogram results
%             .taxis   : Time axis
%             .faxis   : Frequency axis
%             .S       : Audiogram
%             .NormGain: Power gain between Energy and Amplitude normalization
%                        This allows you convert between either output by simply
%                        multiplying by the gain. Note that:
%
%             Norm Gain = 'Amp' Normalization Power / 'En' Normalization Power
%
% (C) Monty A. Escabi, January 2008 (Edit June 2009)
%
function [AudData]=audiogramduck(data,Fs,dX,f1,fN,Fm,Norm,dis,ATT)

%Input Parameters
if nargin<7
    Norm='En';
end
if nargin<8
	dis='n';
end
if nargin<9
	ATT=60;
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

%Desining Low Pass Filter for Extracting Envelope
He=lowpass(Fm,.25*Fm,Fs,ATT,'n');
Ne=(length(He)-1)/2;

%Generating Gammatone Filters
for k=1:length(fc)
    [GammaTone(k).H]=gammatonefilter(3,BW(k),fc(k),Fs);
    N(k)=(length(GammaTone(k).H)-1)/2;
end

%FFT Size
NFFT=2 ^ nextpow2( length(data) + max(N)*2+1 +Ne*2+1);

%Filtering data, Extracting Envelope, and Down-Sampling
Ndata=length(data);
for k=1:length(fc)

	%Output Display
	clc,disp(['Filtering band ' int2str(k) ' of ' int2str(length(fc))]) 

    %Gamma Tone Filter
    H=GammaTone(k).H;
    Hen=H/sqrt(sum(H.^2));
    NormGain(k)=sqrt(sum(H.^2))/sqrt(sum(Hen.^2));
    if strcmp(Norm,'En')        %Edit Nov 2008, Escabi
        H=Hen;                  %Equal Energy
    end
        
	%Filtering at kth Scale
	Y=convfft(data',H,0,NFFT,'y');      %Changed delayed from N(k) to zero
    
    %Spectrotemporal Envelope
    S(k,:)=Y;
    
end
taxis=(0:size(S,2)-1)/Fs;
faxis=fc;

%Storing as data structure
AudData.S=S;
AudData.taxis=taxis;
AudData.faxis=faxis;
AudData.Norm=Norm;
AudData.NormGain=NormGain;

if strcmp(dis,'y')
       
     imagesc(AudData.taxis,log2(AudData.faxis./AudData.faxis(1)),AudData.S),set(gca,'YDir','normal')
     
end 