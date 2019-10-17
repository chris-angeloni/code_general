%
%function [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT,FilterType)
%	
%	FILE NAME 	: AUDIOGRAM
%	DESCRIPTION : Spectro-temporal signal representation obtained 
%                 by applying a octave spaced filterbank and
%                 extracting envelope modulation signal. Uses critical
%                 bandwidth Gamma tone filters for the auditory
%                 model decomposition.
%
%	data        : Input data
%	Fs          : Sampling Rate
%	dX          : Spectral separation betwen adjacent filters in octaves
%                 Usually a fraction of an octave ~ 1/8 would allow 
%                 for a spectral envelope resolution of up to 4 
%                 cycles per octave
%                 Note that X=log2(f/f1) as defined for the ripple 
%                 representation 
%	f1          : Lower frequency to compute spectral decomposition
%	fN          : Upper freqeuncy to compute spectral decomposition
%	Fm          : Maximum Modulation frequency allowed for temporal
%                 envelope at each band. If Fm==inf full range of Fm is used.
%	OF          : Oversampling Factor for temporal envelope
%                 Since the maximum frequency of the envelope is 
%                 Fm, the Nyquist Frequency is 2*Fm
%                 The Frequency used to sample the envelope is 
%                 2*Fm*OF
%   Norm        : Amplitude normalization (Optional)
%                 En:  Equal Energy (Default)
%                 Amp: Equal Amplitude
%	dis         : display (optional): 'log' or 'lin' or 'n'
%                 Default == 'n'
%	ATT         : Attenution / Sidelobe error in dB (Optional) for modulation
%                 lowpass filter. Also used for BSpline filters when using
%                 BSpline option below
%                 Default == 60 dB
%   FilterType  : Type of filter to use (Optional): 'GammaTone' or 'BSpline'
%                 Default == 'GammaTone'
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
%             .Filter.H     : Data structure array containing the impulse
%                             responses (.H) of the gamma tone filters used 
%                             for the filterbank decomposition.
%             .GroupDelay   : Estimated group delays for each filter. Used 
%                             to correct the audiogram by removing the 
%                             filter delays.
%             .BW           : Bandwidths for filterbank
%             .Param        : Contains all of the input parameters
%
% (C) Monty A. Escabi, January 2008 (Edit June 2009, May/Sept 2016 MAE)
%
function [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT,FilterType)

%Input Parameters
if nargin<8 | isempty(Norm)
    Norm='En';
end
if nargin<9 | isempty(dis)
	dis='n';
end
if nargin<10 | isempty(ATT)
	ATT=60;
end
if nargin<11 | isempty(FilterType)
   FilterType='GammaTone'; 
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

%Temporal Down Sampling Factor
DF=max(ceil(Fs/2/Fm/OF),1);

%Desining Low Pass Filter for Extracting Envelope
He=lowpass(Fm,.25*Fm,Fs,ATT,'n');
Ne=(length(He)-1)/2;

%Generating Filters 
if strcmp(FilterType,'BSpline')     %Added B-Spline filter option
    for k=1:length(fc)
        Disp='n';
        f1=fc(k)-BW(k)/2;
        f2=fc(k)+BW(k)/2;
        TW=BW(k)*.10;    %Choose 10% of BW for TW
        [Filter(k).H] = bandpass(f1,f2,TW,Fs,ATT,Disp);
        N(k)=(length(Filter(k).H)-1)/2;
    end
else    %Default filtertype option, Gamma Tone filters
    for k=1:length(fc)
        [Filter(k).H]=gammatonefilter(3,BW(k),fc(k),Fs);
        N(k)=(length(Filter(k).H)-1)/2;
    end
end

%Finding Group Delays
for k=1:length(Filter)   
    P=(Filter(k).H).^2/sum((Filter(k).H).^2);
    t=(1:length(Filter(k).H))/Fs;
    GroupDelay(k)=sum(P.*t);
end

%FFT Size
NFFT=2 ^ nextpow2( length(data) + max(N)*2+1 +Ne*2+1);

%Filtering data, Extracting Envelope, and Down-Sampling
Ndata=length(data);
for k=1:length(fc)

	%Output Display
	clc,disp(['Filtering band ' int2str(k) ' of ' int2str(length(fc))]) 

    %Filter
    H=Filter(k).H;
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
AudData.Filter=Filter;
AudData.GroupDelay=GroupDelay;
AudData.BW=BW;                  %MAE, May 2016

%Storing Input Paramaters
AudData.Param.Fs=Fs;
AudData.Param.dX=dX;
AudData.Param.f1=f1;
AudData.Param.fN=fN;
AudData.Param.Fm=Fm;
AudData.Param.OF=OF;
AudData.Param.Norm=Norm;
AudData.Param.ATT=ATT;