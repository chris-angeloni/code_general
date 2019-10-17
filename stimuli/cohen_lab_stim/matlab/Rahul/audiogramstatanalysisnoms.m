%
%function [AudStatsData,AudData] = audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,SUFFIX)
%	
%	FILE NAME   : AUDIOGRAM STAT ANALYSIS NO MS
%	DESCRIPTION : Analyzes the spectro-temproal statistics of a sound
%                 database. The METAData contains information of the sound
%                 database that will be analyzed. See XLS2METADATA for
%                 details. The program first generates and audiogram for
%                 each sound. Subsequently it will measure statistics from
%                 the audiogram including: the amplitude statistcs,
%                 multi-scale statistics, channel correlations, and
%                 modualtion spectrum.
%
%                 Does not compute multi-scale statistics
%
%   filename: Filename for WAV sound to be analyzed
%   T1      : Start time for data to be analyzed (sec) - if 0 uses the
%             first sample point as begining of file
%   T2      : End time for data to be analyzed (sec) - if Inf uses the last
%             sample point as the end of file
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
%	OF		: Oversampling Factor for temporal envelope
%			  Since the maximum frequency of the envelope is 
%			  Fm, the Nyquist Frequency is 2*Fm
%			  The Frequency used to sample the envelope is 
%			  2*Fm*OF
%   Norm    : Amplitude normalization (Optional)
%             En:  Equal Energy (Default)
%             Amp: Equal Amplitude
%   ATT     : Attenution / Sidelobe error in dB (Optional)
%             Default == 60 d
%   dT      : Temporal Window Used to Compute Amplitude Distribution (sec)
%   Overlap : Percent overlap between consecutive windows used to genreate
%             contrast distribution. Overlap = 0 to 1. 0 indicates no
%             overlap. 0.9 would indicate 90 % overlap.
%   GDelay  : Remove group delay of filters prior to computing ripple 
%             spectrum (Optional, 'y' or 'n': Default=='n')
%   dFm     : Temporal modulaiton frequency resolution (Hz) for Ripple
%             Spectrum (see RIPPLESPEC.M)
%   Save    : Save analyzed data to file : 'y' or 'n' (Optional, Default='n')
%   SUFFIX  : Filename suffix (Optional, if desired)
%
%RETURNED VARIABLES
%
%   AudStatsData    : Audiogram statistics Data Structure
%                     .X            - Sound segment
%                     .AmpData      - Amplitude / contrast statistics (see
%                                     AUDIOGRAMAMPDIST)
%                     .CorrData     - Channel Correlations (see
%                                     AUDIOGRAMCHANCORR.m)
%                     .RipSpec      - Ripple Spectrum (see RIPPLESPEC.m)
%                     .filename     - filename
%                     .Fs           - Sampling Rate
%                     .Param        - Data structure containig all of the
%                                     input parameters used for the anlaysis 
%
%   AudData         : Audiogram (see AUDIOGRAM.m)
%
%   If Save=='y' the three data sturcture fields are stored into a data
%   file with the original filename header and a Suffix 'AUDSTATS'
%
% (C) Monty A. Escabi, January 2013
%
function [AudStatsData,AudData] = audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,SUFFIX)

%Input Args
if nargin<17
    Save='n';
end
if nargin<18
    SUFFIX='';
end

%Find File Header
i=strfind(filename,'.wav');
Header=filename(1:i-1);

%Extracting or Generating Audiogram
if exist([Header '_FULL_AUDSTATS.mat'],'file')      %Extracting audiogram from previously computed FULL file
    
    %Loading AudData from FULL file
    load([Header '_FULL_AUDSTATS.mat'],'AudData')
    [X,Fs]=wavread(filename);   %Reading WAV Data
    
    %Truncing Audiogram from T1 to T2
    Fst=1/(AudData.taxis(2)-AudData.taxis(1));
    N1=max(ceil(T1*Fst),1);
    N2=min(floor(T2*Fst),length(AudData.taxis));
    AudData.S=AudData.S(:,N1:N2);
    AudData.taxis=AudData.taxis(N1:N2)-AudData.taxis(N1);
    
else                                                %Using Original Sound waveform to generate Audiogram

    %Reading WAV FILE and normalizing data
    [X,Fs]=wavread(filename);   %Reading WAV Data
    if size(X,2)==2
        X=X(:,1);               %Selecting Channel 1
    end
    X=X/std(X);                 %Normalizing for unit variance

    %Selecting Sound Segments
    N1=max(ceil(T1*Fs),1);
    N2=min(floor(T2*Fs),length(X));
    X=X(N1:N2);

    %Generating Auidogram for selected Segment   
    [AudData]=audiogram(X,Fs,dX,f1,fN,Fm,OF,'Amp','log');
end

%Analyzing Audiogram Statistics
dis='n';
[AmpData]=audiogramampdist(AudData,Fs,dX,[],[],[],[],dT,Overlap);
[CorrData]=audiogramchancorr(AudData,Fs,dX,f1,fN,Fm,OF,Norm,GDelay,dis,ATT);
[RipSpec]=ripplespec(AudData,Fs,dX,dFm,f1,fN,Fm,OF,Norm,GDelay,dis,ATT);

%Combinging results into a single data structure
AudDataStats.X=X;
AudStatsData.AmpData=AmpData;
AudStatsData.CorrData=CorrData;
AudStatsData.RipSpec=RipSpec;
AudStatsData.filename=filename;
AudStatsData.Param.Fs=Fs;
AudStatsData.Param.T1=T1;
AudStatsData.Param.T2=T2;
AudStatsData.Param.dX=dX;
AudStatsData.Param.f1=f1;
AudStatsData.Param.fN=fN;
AudStatsData.Param.Fm=Fm;
AudStatsData.Param.fm1=fm1;
AudStatsData.Param.dfm=dfm;
AudStatsData.Param.OF=OF;
AudStatsData.Param.Norm=Norm;
AudStatsData.Param.ATT=ATT;
AudStatsData.Param.dT=dT;
AudStatsData.Param.Overlap=Overlap;
AudStatsData.Param.GDelay=GDelay;
AudStatsData.Param.dFm=dFm;

%Saving Data
if strcmp(Save,'y')
    i=strfind(filename,'.');
    outfile=[filename(1:i-1) '_' SUFFIX '_AUDSTATS'];
    save(outfile,'AudStatsData','AudData');
end