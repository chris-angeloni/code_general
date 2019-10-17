%function [CorrData]=audiogramdynchancorr(data,Fs,dX,f1,fN,Fm,OF,dT,MaxDelay,OFc,Norm,GDelay,dis,ATT,ATTc)
%	
%	FILE NAME 	: AUDIOGRAM DYN CHAN CORR
%	DESCRIPTION : Moves along the data in windows of size dT,
%                 Computes the short-term / dynamic audiogram cross
%                 correlation function: R(t,tau)
%
%	data     : Input data vector (sound vector) or output data structure
%              from audiogram.m (AudData)
%	Fs		 : Sampling Rate
%	dX		 : Spectral Filter Bandwidth Resolution in Octaves
%			   Usually a fraction of an octave ~ 1/8 would allow 
%			   for a spectral envelope resolution of up to 4 
%			   cycles per octave
%			   Note that X=log2(f/f1) as defined for the ripple 
%			   representation 
%	f1		 : Lower frequency to compute spectral decomposition
%	fN		 : Upper freqeuncy to compute spectral decomposition
%	Fm		 : Maximum Modulation frequency allowed for temporal
%			   envelope at each band. If Fm==inf full range of Fm is used.
%	OF		 : Oversampling Factor for temporal envelope
%			   Since the maximum frequency of the envelope is 
%			   Fm, the Nyquist Frequency is 2*Fm
%			   The Frequency used to sample the envelope is 
%			   2*Fm*OF
%   dT       : Temporal Window Resolution (sec) - defined according to
%              uncertainty principle so that dT = 2 * std(Wt) where Wt is a
%              temporal Kaiser Window
%   MaxDelay : Maximum delay time (sec)
%   OFc      : Oversampling Factor for correlation calculation
%   Norm     : Amplitude normalization (Optional)
%              En:  Equal Energy (Default)
%              Amp: Equal Amplitude
%   GDelay   : Remove group delay of filters prior to computing correlation 
%              (Optional, 'y' or 'n': Default=='n')
%	dis		 : display (optional): 'log' or 'lin' or 'n'
%			   Default == 'n'
%	ATT		 : Attenution / Sidelobe error in dB for Audiogram Filterbank
%              (Optional, Default == 60 dB) 
%   ATTc     : Attenuation / Sidelobe error for temporal window used to compute 
%              dynamic correlation (Optional, Default == 40dB)
%
%RETURNED VARIABLES
%   CorrData        : Correlation data structure
%     .Rxy          : Short Term Correlation
%     .RxyN         : Normalized short term correlation (as a Pearson
%                     correlation coefficeint)
%     .RxyN2        : Normalized short term correlation (similar to
%                     RxyN but the means of X and Y are not removed)
%     .tauaxis      : Delay Axis (sec)
%     .taxis        : Time Axis (sec)
%     .Param.X      : Adds all input parameters from above 
%     .Param.Fst    : Sampling rate for temporal axis of dynamic
%                     correlation
%     .Param.Wt     : Temporal window used to segment dynamic correlation
%
%  (C) Monty A. Escabi, Aug 2015 (Edit Nov 2016, MAE)
%
function [CorrData]=whi(data,Fs,dX,f1,fN,Fm,OF,dT,MaxDelay,OFc,Norm,GDelay,dis,ATT,ATTc)

%Input Parameters
if nargin<11
    Norm='En';
end
if nargin<12
    GDelay='n';
end
if nargin<13
	dis='n';
end
if nargin<14
	ATT=60;
end
if nargin<15
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

%Generating Window
Fst=1/(AudData.taxis(2)-AudData.taxis(1));
[Beta,dN] = fdesignkdt(ATTc,dT,Fst);    %Fix ATT = 40 dB; Use Kaiser window to select data in time; dN is the window size to compute dynamic corrlation
Wt=kaiser(dN,Beta)';                    % Temporal Kaiser Window, April 2016, MAE
MaxLag=ceil(MaxDelay*Fst);

% %Computing Correlation Matrix
%  for k=1:size(S,1)                  %Loop across channels
%      for l=1:size(S,1)              %Lopp across channels
%          [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrstsym(S(k,:),S(l,:),MaxLag,Fst,Wt,OFc);
%          Corr1(k,l,:,:)=RxyN;
% 
%      end
%  end

count=1;
  for k=1:size(S,1)         %Loop across channels
     for l=1:k              %Lopp across channels
         
         %Displaying progress
         clc
         disp(['Percent Done: ' num2str(count/(size(S,1)*(size(S,1)-1)/2)*100,2) ' %'])
         
         %Computing short-term correlations
         [Rxy,RxyN,RxyN2,tauaxis,taxis]=xcorrstsym(S(k,:),S(l,:),MaxLag,Fst,Wt,OFc);
         CorrData.Rxy(k,l,:,:)=Rxy;
         CorrData.Rxy(l,k,:,:)=flipud(Rxy);
         
         CorrData.RxyN(k,l,:,:)=RxyN;
         CorrData.RxyN(l,k,:,:)=flipud(RxyN);
         
         CorrData.RxyN2(k,l,:,:)=RxyN2;
         CorrData.RxyN2(l,k,:,:)=flipud(RxyN2);
         
         CorrData.tauaxis=tauaxis;
         CorrData.taxis=taxis;
         
         %Increment counter
         count=count+1;
     end
  end

  %Adding Correlation Parameters
  CorrData.Pram.Fs=Fs;
  CorrData.Pram.dX=dX;
  CorrData.Pram.f1=f1;
  CorrData.Pram.fN=fN;
  CorrData.Pram.Fm=Fm;
  CorrData.Pram.OF=OF;
  CorrData.Pram.dT=dT;
  CorrData.Pram.MaxDelay=MaxDelay;
  CorrData.Pram.OFc=OFc;
  CorrData.Pram.Norm=Norm;
  CorrData.Pram.GDelay=GDelay;
  CorrData.Pram.ATT=ATT;
  CorrData.Pram.ATTc=ATTc;
  CorrData.Pram.Fst=Fts;
  CorrData.Pram.Wt=Wt;
