%
%function [AmpData]=audiogramampdist(data,Fs,dX,f1,fN,Fm,OF,dT,ND,Norm,dis,ATT)
%	
%	FILE NAME 	: AUDIOGRAM AMP DIST
%	DESCRIPTION : Computes time-dependent envelope amplitude / contrast
%                 distribution from the audiogram of a sound
%
%   data    : Input data vector (sound vector) or output data structure
%             from audiogram.m (AudData)
%   Fs      : Sampling Rate
%   dX      : Spectral Filter Bandwidth Resolution in Octaves
%             Usually a fraction of an octave ~ 1/8 would allow
%             for a spectral envelope resolution of up to 4
%             cycles per octave
%             Note that X=log2(f/f1) as defined for the ripple
%             representation
%   f1      : Lower frequency to compute spectral decomposition
%   fN      : Upper freqeuncy to compute spectral decomposition
%   Fm      : Maximum Modulation frequency allowed for temporal
%             envelope at each band. If Fm==inf full range of Fm is used.
%   OF      : Oversampling Factor for temporal envelope
%             Since the maximum frequency of the envelope is
%             Fm, the Nyquist Frequency is 2*Fm
%             The Frequency used to sample the envelope is
%             2*Fm*OF
%   dT      : Temporal Window Used to Compute Amplitude Distribution (sec)
%   Overlap : Percent overlap between consecutive windows used to genreate
%             contrast distribution. Overlap = 0 to 1. 0 indicates no
%             overlap. 0.9 would indicate 90 % overlap.
%   ND      : Polynomial Order: Detrends the local spectrum
%             by fiting a polynomial of order ND. The fitted
%             trend is then removed(Default==1, No detrending)
%   Norm    : Amplitude normalization (Optional)
%             'En'  = Equal Energy (Default)
%             'Amp' = Equal Amplitude
%   dis     : display (optional): 'log' or 'lin' or 'n'
%             Default == 'n'
%   ATT     : Attenution / Sidelobe error in dB (Optional)
%             Default == 60 dB
%
%RETURNED VARIABLES
%
%   AmpData : Data Structure containg the following 
%
%             .PDist1       - Time dependent amplitude distribution - mean
%                             removed
%             .PDist2       - Time dependent amplitude distribution - best
%                             polynomial fit of power spectrum removed
%             .PDist3       - Time dependent amplitude distribution - mean
%                             power spectrum removed
%             .StddB1,2,3   - Standard deviation (dB)
%             .MeandB1,2,3  - Mean amplitude (dB)
%             .KurtdB1,2,3  - Kurtosis
%             .Time         - Time Axis
%             .Amp          - Amplitude Axis ( decibels )
%             .dT           - Temporal Window Used to Compute Amplitude
%                             Distribution (sec)
%             .dN           - Temporal Window Used to Compute Amplitude
%                             Distribution (samples)
%
% (C) Monty A. Escabi, (Edit May 2014)
%
function [AmpData]=audiogramampdist(data,Fs,dX,f1,fN,Fm,OF,dT,Overlap,ND,Norm,dis,ATT)

%Input Parameters
if nargin<10
	ND=1;
end
if nargin<11
    Norm='En';
end
if nargin<12
	dis='n';
end
if nargin<13
	ATT=60;
end

%Generating Audiogram if necessary
if ~isstruct(data)
    data=data/std(data);    %Normalizing for unit variance
    [AudData]=audiogram(data,Fs,dX,f1,fN,Fm,OF,Norm,dis,ATT);
else
    AudData=data;
end

%Detrending Probability Distribution
SdB=20*log10(AudData.S);
i=find(~isinf(SdB));
MindB=min(SdB(i));
i=find(isinf(SdB));
SdB(i)=MindB*ones(size(SdB(i)));                %Remove values with -Inf - i.e., note that when S == 0 -> SdB=-Inf
SdB1=SdB-mean(mean(SdB));                       %Subtract Mean Value
[P,S] = polyfit(log2(AudData.faxis),mean(SdB'),ND);
[Sline] = polyval(P,log2(AudData.faxis),S);
SdB2=SdB-Sline'*ones(1,size(SdB,2));            %Subtract straight line fit
SdB3=SdB-mean(SdB,2)*ones(1,size(SdB,2));       %Subtract Mean Spectrum

%Computing Amplitude Distribution
Fst=1/(AudData.taxis(2)-AudData.taxis(1));
dN=round(dT*Fst);                               %Window size to compute distribution
dNt=round(dT*Fst*(1-Overlap));                  %Temporal sampling period for computing distribution (in sample numbers)
count=1;
PDist1=[];
PDist2=[];
PDist3=[];
while count*dNt+dN<size(AudData.S,2)
    offset=(count-1)*dNt;
  
    %Mean value removed
    SS1=reshape(SdB1(:,offset+1:offset+dN),1,numel(SdB1(:,offset+1:offset+dN)));
    [P1,Amp]=hist(SS1,[-100:1:100]);
    PDist1=[PDist1 P1'/length(SS1)];
    
    %Straight line removed
    SS2=reshape(SdB2(:,offset+1:offset+dN),1,numel(SdB2(:,offset+1:offset+dN)));
    [P2,Amp]=hist(SS2,[-100:1:100]);
    PDist2=[PDist2 P2'/length(SS2)];
    
    %Mean spectrum removed
    SS3=reshape(SdB3(:,offset+1:offset+dN),1,numel(SdB3(:,offset+1:offset+dN)));
    [P3,Amp]=hist(SS3,[-100:1:100]);
    PDist3=[PDist3 P3'/length(SS3)];
    
	Amp=Amp';
    count=count+1;

end

%Finding Mean, Std, and Kurtosis Trajectories
Time=(0:size(PDist1,2)-1)*dNt/Fst;
[Time,StddB1,MeandB1,KurtdB1]=ampstdmean(Time,Amp,PDist1);
[Time,StddB2,MeandB2,KurtdB2]=ampstdmean(Time,Amp,PDist2);
[Time,StddB3,MeandB3,KurtdB3]=ampstdmean(Time,Amp,PDist3);

%Storing Data to Structure
AmpData.PDist1=PDist1;
AmpData.PDist2=PDist2;
AmpData.PDist3=PDist3;
AmpData.StddB1=StddB1;
AmpData.MeandB1=MeandB1;
AmpData.KurtdB1=KurtdB1;
AmpData.StddB2=StddB2;
AmpData.MeandB2=MeandB2;
AmpData.KurtdB2=KurtdB2;
AmpData.StddB3=StddB3;
AmpData.MeandB3=MeandB3;
AmpData.KurtdB3=KurtdB3;
AmpData.Amp=Amp;
AmpData.Time=Time;
AmpData.dT=dT;
AmpData.dN=dN;