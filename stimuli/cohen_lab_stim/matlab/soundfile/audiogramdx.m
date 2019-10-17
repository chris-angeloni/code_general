%
%function [AudData]=audiogramdx(data,Fs,dX,dXc,f1,fN,Fm,OF,Norm,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM DX
%	DESCRIPTION : Spectro-temporal signal representation obtained 
%                 by applying a octave spaced filterbank and
%                 extracting envelope modulation signal. Uses critical
%                 bandwidth B-Spline filters for the auditory
%                 model decomposition.
%
%                 This program is similar to AUDIOGRAM except that it
%                 replaces GammaTone filters (with low frequency tails)
%                 with compact B-spline filters (no frequency overlap)
%
%	data    : Input data
%	Fs		: Sampling Rate
%	dX		: Spectral Filter Bandwidth Resolution in Octaves
%			  Usually a fraction of an octave ~ 1/8 would allow 
%			  for a spectral envelope resolution of up to 4 
%			  cycles per octave
%			  Note that X=log2(f/f1) as defined for the ripple 
%			  representation
%   dXc     : Filter center frequency spacing. Note that relationship
%             between dX and dXc determines overlap
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
%   AudData : Data structure containing audiogram results
%             .taxis        : Time axis
%             .faxis        : Frequency axis
%             .S            : Audiogram
%             .Sc           : Audiogram corrected for group delays. Filter 
%                             group delays are removed from the filterbank.
%             .Sf           : Spectral Envelope Distribution
%             .NormGain     : Power gain between Energy and Amplitude
%                             normalization. This allows you convert 
%                             between either output by simply multiplying
%                             by the gain. Note that:
%
%                             Norm Gain = 'Amp' Normalization Power / 'En' 
%                             Normalization Power
%
%             .GammaTone.H  : Data structure array containing the impulse
%                             responses (.H) of the gamma tone filters used 
%                             for the filterbank decomposition.
%             .GroupDelay   : Estimated group delays for each of the
%                             gammatone filters. Used to correct the
%                             audiogram by removing the filter delays.
%
% (C) Monty A. Escabi, January 2008 (Edit June 2009)
%
function [AudData]=audiogram(data,Fs,dX,dXc,f1,fN,Fm,OF,Norm,dis,ATT)

%Input Parameters
if nargin<8
    Norm='En';
end
if nargin<9
	dis='n';
end
if nargin<10
	ATT=60;
end

%Finding frequency axis for chromatically spaced filter bank
%Note that chromatic spacing requires : f(k) = f(k+1) * 2^dX
X1=0
XN=log2(fN/f1);
L=floor(XN/dXc);
X=(.5:L-.5)/L*XN;
Xc=(0:L)/L*XN;
faxis=f1*2.^X;
fc1=f1*2.^Xc;
fc2=f1*2.^Xc*2^dX;
i=find(fc2<Fs/2);
fc1=fc1(i);
fc2=fc2(i);
fc=faxis;

%Finding filter characterisitic frequencies according to Greenwood
%[fc]=greenwoodfc(20,20000,.1);

%Finding filter bandwidhts assuming 1 critical band
%BW=criticalbandwidth(fc);

%Temporal Down Sampling Factor
DF=max(ceil(Fs/2/Fm/OF),1);

%Desining Low Pass Filter for Extracting Envelope
He=lowpass(Fm,.25*Fm,Fs,ATT,'n');
Ne=(length(He)-1)/2;

%Generating Filters
for k=1:length(fc)
    TW=(fc1(k)-fc2(k))/4;
	[Filters(k).H]=bandpass(fc1(k),fc2(k),TW,Fs,ATT,'n');
	N=(length(Filters(k).H)-1)/2;
    FilterType='BSpline';
end

%Finding Group Delays
for k=1:length(Filters)   
    P=(Filters(k).H).^2/sum((Filters(k).H).^2);
    t=(1:length(Filters(k).H))/Fs;
    GroupDelay(k)=sum(P.*t);
end

%FFT Size
NFFT=2 ^ nextpow2( length(data) + max(N)*2+1 +Ne*2+1);

%Filtering data, Extracting Envelope, and Down-Sampling
Ndata=length(data);
for k=1:length(fc)

	%Output Display
	clc,disp(['Filtering band ' int2str(k) ' of ' int2str(length(fc))]) 

    %Gamma Tone Filter
    H=Filters(k).H;
    Hen=H/sqrt(sum(H.^2));
    NormGain(k)=sqrt(sum(H.^2))/sqrt(sum(Hen.^2));
    if strcmp(Norm,'En')        %Edit Nov 2008, Escabi
        H=Hen;                  %Equal Energy
    end
        
	%Filtering at kth Scale
	Y=convfft(data',H,0,NFFT,'y');      %Changed delayed from N(k) to zero
     
    %Spectral Amplitude Distribution
    %Sf(k)=std(Y);
    
	%Finding Envelope Using the Hilbert Transform
	Y=abs(hilbert(Y));

	%Filtering The Envelope and Downsampling
    if Fm~=inf
        Y=max(0,convfft(Y,He,Ne));      %Remove (-) values which are due to filtering
    end
    
	%Downsampling Envelope
    S(k,:)=Y(1:DF:Ndata);
    
    %Downsampling Envelope and Correcting for Group Delay
    NMax=round(max(GroupDelay*Fs));
    Ndelay=round(GroupDelay(k)*Fs)+1;
    Sc(k,:)=Y(Ndelay:DF:Ndata-NMax+Ndelay-1);
    
    %Spectral Envelope Distribution
    %Sf(k)=sqrt(mean(Y.^2));
    Sf(k)=mean(S(k,:));
    
end
taxis=(0:size(S,2)-1)/(Fs/DF);
faxis=fc;

%Storing as data structure
AudData.S=S;
AudData.Sc=Sc;
AudData.Sf=Sf;
AudData.taxis=taxis;
AudData.faxis=faxis;
AudData.Norm=Norm;
AudData.NormGain=NormGain;
AudData.Filters=Filters;
AudData.FilterType=FilterType;
AudData.GroupDelay=GroupDelay;