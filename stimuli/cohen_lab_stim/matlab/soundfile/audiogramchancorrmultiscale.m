%
%function [CorrDataMS]=audiogramchancorrmultiscale(data,Fs,dX,f1,fN,Fm,fm1,dfm,Nms,OF,Norm,MSflag,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM CHAN CORR MULTI SCALE
%	DESCRIPTION : Computes the audiogram channel correlation coefficient at
%                 multiple scales. The audiogram is first decomposed into
%                 multilple modulation frequency channels (scales) and then
%                 the correlations between differnt frequency channels are
%                 computed.
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
%   Amp     : Envelope amplitude in 'dB' or 'Lin' - determines what type of
%             envelope to use for the correlation (Default=='dB')
%
%RETURNED VARIABLES
%
%   CorrDataMS  : Data structure containing multi-scale correlation data
%     .CorrMap  : Correleation map, CorrMap(k,l,m), k and l are the 
%                 frequency channels and m is the scale
%     .fml      : Lower frequency for MS modualtion filter
%     .fmh      : Upper frequency for MS modulation filter
%     .faxis    : Frequency Axis
%
% (C) Monty A. Escabi, Sept. 2012
%
function [CorrDataMS]=audiogramchancorrmultiscale(data,Fs,dX,f1,fN,Fm,fm1,dfm,Nms,OF,Norm,MSflag,dis,ATT)

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
if nargin<15
    Amp='dB';
end

%Temporal Down Sampling Factor - see Audiogram.m
%DF=ceil(Fs/2/Fm/OF);

% %Generating Audiogram if necessary
if ~isstruct(data)
    [AudDataMS]=audiogrammultiscale(data,Fs,dX,f1,fN,Fm,fm1,dfm,Nms,OF,Norm,MSflag,dis,ATT);
else 
    AudDataMS=data;
end

% if ~isstruct(data)
%     data=data/std(data);    %Normalizing for unit variance
%     [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
% else
%     AudData=data;
% end
% 
% %Number of temporal samples used for each analysis block
% faxis=AudData.faxis;
% taxis=AudData.taxis;
% Fst=1/(taxis(2)-taxis(1));
% 
% %Finding Multi-Scale Filter Cutoff
% if MSflag==1
%     fml=fm1*(2^dfm).^((1:Nms)-1);
%     fmh=fml*2^dfm;
% else
%     fml=f1+dfm*((1:Nms)-1);
%     fm2=fm1+dfm;
% end
%     
% %Multi-Scale decomposition of Spectrotemporal Envelope
% S=AudData.S;
% for l=1:Nms
% 
%     [H] = bandpass(fml(l),fmh(l),fmh(l)-fml(l),Fst,30);
%     N=(length(H)-1)/2;
% 
%     for k=1:size(S,1)
%         St=conv(S(k,:),H);          %Filter envelope channel
%         SS(k,:,l)=St(N+1:end-N);    %Remove filter group delay
%     end
% 
% end

%Selecting Envelope Type - dB or Lin
if strcmp(Amp,'dB')
    Sms=AudDataMS.SmsdB;
else
    Sms=AudDataMS.Sms;
end

%Computing Across channel correlation at multiple scales
for l=1:size(Sms,3)
    for k=1:size(Sms,1)
        for m=1:size(Sms,1)
            
            %Removing edges to avoid filtering edge artifacts
            N=(length(AudDataMS.MSFilter(l).H)-1)/2;
            L=size(Sms,2);
            Sk=Sms(k,N+1:L-N,l);
            Sm=Sms(m,N+1:L-N,l);
            
            %Corerlation
            R=corrcoef(Sk,Sm);
            CorrMap(k,m,l)=R(1,2);

        end
    end 
end

%Adding to data structure
CorrDataMS.CorrMap=CorrMap;
CorrDataMS.fml=AudDataMS.fml;
CorrDataMS.fmh=AudDataMS.fmh;
CorrDataMS.faxis=AudDataMS.faxis;