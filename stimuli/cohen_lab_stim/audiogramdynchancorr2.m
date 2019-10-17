%function [CorrData]=audiogramdynchancorr(data,Fs,dX,f1,fN,Fm,OF,dT,Overlap,Norm,GDelay,dis,ATT,ATTc)
%	
%	FILE NAME 	: audiogramdynchancor
%	DESCRIPTION : Moves along the data in windows of size dT,
%                 Computes the short-term / dynamic audiogram channel 
%                 correlation coefficient Matrix and stores all of them in 
%                 a 3D matrix called dynCorrMap.
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
%    dT     : Temporal Window Resolution (sec) - defined according to
%             uncertainty principle so that dT = 2 * std(Wt) where Wt is a
%             temporal Kaiser Window
%   Overlap : Percent overlap between consecutive windows. Overlap = 0 to 1. 0 indicates no
%             overlap. 0.9 would indicate 90 % overlap.
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%   GDelay  : Remove group delay of filters prior to computing correlation 
%             (Optional, 'y' or 'n': Default=='n')
%	dis		: display (optional): 'log' or 'lin' or 'n'
%			  Default == 'n'
%	ATT		: Attenution / Sidelobe error in dB for Audiogram Filterbank
%             (Optional, Default == 60 dB) 
%   ATTc    : Attenuation / Sidelobe error for temporal window used to compute 
%             dynamic correlation (Optional, Default == 40dB)
%
%RETURNED VARIABLES
%   CorrData        : Correlation data structure
%     .dynCorrMap   : Dynamic Correleation Matrix
%     .faxis        : Frequency Axis
%
% (C) Monty A. Escabi, Aug 2015 (Edit April 2016, MAE)
%
function [CorrData]=audiogramdynchancorr(data,Fs,dX,f1,fN,Fm,OF,dT,Overlap,Norm,GDelay,dis,ATT,ATTc)

%Input Parameters
if nargin<10
    Norm='En';
end
if nargin<11
    GDelay='n';
end
if nargin<12
	dis='n';
end
if nargin<13
	ATT=60;
end
if nargin<14
    ATTc=40;
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
    S=AudData.Sc;
else
    S=AudData.S;
end

%Computing Amplitude Distribution
Fst=1/(AudData.taxis(2)-AudData.taxis(1));
%dN=round(dT*Fst);                      %Window size to compute distribution
[Beta,dN] = fdesignkdt(ATTc,dT,Fst);    %Fix ATT = 40 dB; Use Kaiser window to select data in time; dN is the window size to compute dynamic corrlation
Wt=kaiser(dN,Beta)';                    % Temporal Kaiser Window, April 2016, MAE
dNt=round(dT*Fst*(1-Overlap));          %Temporal sampling period determined from overlap and window size (in sample numbers)
count=1;
 while count*dNt+dN<size(S,2)
     offset=(count-1)*dNt;
     for k=1:size(S,1)                  %Loop across channels
         for l=1:size(S,1)              %Lopp across channels
             Sk=(S(k,offset+1:offset+dN)-mean(S(k,offset+1:offset+dN))).*Wt;  %Temporal Kaiser Window, April 2016, MAE
             Sl=(S(l,offset+1:offset+dN)-mean(S(l,offset+1:offset+dN))).*Wt;  %Temporal Kaiser Window, April 2016, MAE
             R=corrcoef(Sk,Sl);
             Corr(k,l)=R(1,2);
         end
    end
     dynCorrMap(:,:,count)= Corr; 
     count=count+1;
     clc,disp(['Dynamic Correlation Percent Done: ' num2str(count/(size(S,2)/dNt)*100,3) ' %'])
 end

%Adding to data structure
CorrData.faxis=AudData.faxis;
CorrData.dynCorrMap=dynCorrMap;
