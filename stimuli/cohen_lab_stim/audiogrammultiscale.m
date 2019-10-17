%
%function [AudioGramMS]=audiogrammultiscale(data,Fs,dX,f1,fN,Fm,fm1,dfm,Nms,OF,Norm,MSflag,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM MULTI SCALE
%	DESCRIPTION : Computes the audiogram and decomposes it for multiple
%                 "scales". Each scale consists of the filtered audiogram
%                 that is passed through a bandpass modualtion filter.
%
%	data    : Input data vector (sound vector) or output data structure
%             from audiogram.m (AudData)
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
%   fm1     : Lowest modulation frequency for multi-scale decomposition
%   dfm     : Modulation filter bandwidht (Octave for MSflag=1; Hz for
%             MSflag==2) for multi-scale decomposition
%   Nms     : Number of multi-scale decompositions
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%   MSflag  : Multi-scale flag
%             MSflag==1     - proportional filters (Octave, default)
%             MSflag==2     - equal resolution filters (Hz)
%   dis     : display (optional): 'log' or 'lin' or 'n'
%             Default == 'n'
%   ATT     : Attenution / Sidelobe error in dB (Optional)
%             Default == 60 dB
%
%RETURNED VARIABLES
%
%   AudData : Data structure containing audiogram results
%             .taxis        : Time axis
%             .faxis        : Frequency axis
%             .S            : Audiogram
%             .Sc           : Audiogram corrected for group delays. Filter 
%                             group delays are removed from the filterbank.
%             .Sms          : Multi scale envelope. Corrected for 
%                             envelope MS filter group delay
%             .SmsdB        : Multi scale dB envelope. Corrected for
%                             envelope MS filter group delay.
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
%             .fml          : Lower frequency for MS modualtion filter
%             .fmh          : Upper frequency for MS modulation filter
%             .MSFilter     : Multi-scale modualtion filters
%             .MSGroupDelay : Multi-scale filter group delays
%
% (C) Monty A. Escabi, Sept. 2012
%
function [AudDataMS]=audiogrammultiscale(data,Fs,dX,f1,fN,Fm,fm1,dfm,Nms,OF,Norm,MSflag,dis,ATT)

%Input Parameters
if nargin<11
    Norm='En';
end
if nargin<12
    MSflag==1;
end
if nargin<13
	dis='n';
end
if nargin<14
	ATT=60;
end

%Temporal Down Sampling Factor - see Audiogram.m
DF=ceil(Fs/2/Fm/OF);

%Generating Audiogram if necessary
if ~isstruct(data)
    data=data/std(data);    %Normalizing for unit variance
    [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
else
    AudData=data;
end

%Number of temporal samples used for each analysis block
faxis=AudData.faxis;
taxis=AudData.taxis;
Fst=1/(taxis(2)-taxis(1));

%Finding Multi-Scale Filter Cutoff
if MSflag==1
    fml=fm1*(2^dfm).^((1:Nms)-1);
    fmh=fml*2^dfm;
else
    fml=f1+dfm*((1:Nms)-1);
    fm2=fm1+dfm;
end

%Removing Zero-Value Bins (otherwise dB envelope has -Inf)
S=AudData.S;
i=find(S~=0);
Min=min(S(i));
i=find(S==0);
S(i)=ones(size(i))*Min;

%Multi-Scale decomposition of Spectrotemporal Envelope
for l=1:Nms

    %Generating Envelope Multi Scale Filters
    [H] = bandpass(fml(l),fmh(l),fmh(l)-fml(l),Fst,40);
    N=(length(H)-1)/2;
    MSFilter(l).H=H;

    %Finding Envelope Filter Group Delays   
    P=(MSFilter(l).H).^2/sum((MSFilter(l).H).^2);
    t=(1:length(MSFilter(l).H))/Fs;
    MSGroupDelay(l)=sum(P.*t);
    
    for k=1:size(S,1)
        St=conv(S(k,:),H);              %Filter envelope
        StdB=conv(20*log10(S(k,:)),H);  %Filter dB envelope 
        SS(k,:,l)=St(N+1:end-N);        %Remove envelope filter group delay
        SSdB(k,:,l)=StdB(N+1:end-N);    %Remove envelope filter group delay
    end

end

%Adding to data structure
AudDataMS=AudData;
AudDataMS.Sms=SS;       %Corrected for envelope group delay
AudDataMS.SmsdB=SSdB;   %MS envelope in dB. Corrected for envelope group delay
AudDataMS.fml=fml;
AudDataMS.fmh=fmh;
AudDataMS.MSFilter=MSFilter;
AudDataMS.MSGroupDelay=MSGroupDelay;