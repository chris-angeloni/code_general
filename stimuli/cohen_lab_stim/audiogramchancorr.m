%
%function [CorrData]=audiogramchancorr(data,Fs,dX,f1,fN,Fm,OF,Norm,GDelay,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM CHAN CORR
%	DESCRIPTION : Computes the audiogram channel correlation coefficient.
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
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%   GDelay  : Remove group delay of filters prior to computing correlation 
%             (Optional, 'y' or 'n': Default=='n')
%	dis		: display (optional): 'log' or 'lin' or 'n'
%			  Default == 'n'
%	ATT		: Attenution / Sidelobe error in dB (Optional)
%			  Default == 60 dB
%
%RETURNED VARIABLES
%   CorrMata    : Data structure containing correlation data
%     .CorrMap  : Correleation map
%     .faxis    : Frequency Axis
%
% (C) Monty A. Escabi, July 2008 (Edit Feb,April 2016, MAE)
%
function [CorrData]=audiogramchancorr(data,Fs,dX,f1,fN,Fm,OF,Norm,GDelay,dis,ATT)

%Input Parameters
if nargin<8
    Norm='En';
end
if nargin<9
    GDelay='n';
end
if nargin<10
	dis='n';
end
if nargin<11
	ATT=60;
end

%Generating Audiogram if necessary
if ~isstruct(data)
    data=data/std(data);    %Normalizing for unit variance
    [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
else
    AudData=data;
end

%Removing Group Delay if Desired (July 2015)
if strcmp(GDelay,'y')    %Corrected audiogram is stored in 'data'
    S=AudData.Sc;        %Fixed 2/2/16, MAE
else
    S=AudData.S;         %Fixed 2/2/16, MAE
end

%Computing Across channel correlation
for k=1:size(S,1)
    for l=1:size(S,1)
        Sk=S(k,:)-mean(S(k,:)); %April 2016, MAE
        Sl=S(l,:)-mean(S(l,:)); %April 2016, MAE
        R=corrcoef(Sk,Sl);
        CorrMap(k,l)=R(1,2);
    end
end

%Adding to data structure
CorrData.CorrMap=CorrMap;
CorrData.faxis=AudData.faxis;