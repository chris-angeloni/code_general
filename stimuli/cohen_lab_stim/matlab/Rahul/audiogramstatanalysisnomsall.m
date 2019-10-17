%
%function [] = audiogramstatanalysisnomsall(METAData,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save)
%	
%	FILE NAME   : AUDIOGRAM STAT ANALYSIS NO MS ALL
%	DESCRIPTION : Analyzes the spectro-temproal statistics of a sound
%                 database. The METAData contains information of the sound
%                 database that will be analyzed. See XLS2METADATA for
%                 details. The program first generates and audiogram for
%                 each sound. Subsequently it will measure statistics from
%                 the audiogram including: the amplitude statistcs,
%                 multi-scale statistics, channel correlations, and
%                 modualtion spectrum.
%
%   METAData: Data structure containing all of the META data for the
%             sound database to be analyzed
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
%
%RETURNED VARIABLES
%
% Data is saved to current directory
%
% (C) Monty A. Escabi, January 2013
%
function [] = audiogramstatanalysisnomsall(METAData,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm)

Save='y';
for k=1:length(METAData)
    
     %Getting filenames
     List=dir(['Track' int2strconvert(METAData(k).Track,3) '*.wav']);
     filename=List.name;
       
     %Analyzing Data from different segments
      if ~isnan(METAData(k).Segment1(1))
          T1=METAData(k).Segment1(1);
          T2=METAData(k).Segment1(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SEG1');
      end
      if ~isnan(METAData(k).Segment2(1))
          T1=METAData(k).Segment2(1);
          T2=METAData(k).Segment2(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SEG2');
      end
      if ~isnan(METAData(k).Segment3(1))
          T1=METAData(k).Segment3(1);
          T2=METAData(k).Segment3(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SEG3');
      end
      if ~isnan(METAData(k).Segment4(1))
          T1=METAData(k).Segment4(1);
          T2=METAData(k).Segment4(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SEG4');
      end
      if ~isnan(METAData(k).Soundscape1(1))
          T1=METAData(k).Soundscape1(1);
          T2=METAData(k).Soundscape1(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SNDSCP1');
      end
      if ~isnan(METAData(k).Soundscape2(1))
          T1=METAData(k).Soundscape2(1);
          T2=METAData(k).Soundscape2(2);
          audiogramstatanalysisnoms(filename,T1,T2,dX,f1,fN,Fm,fm1,dfm,OF,Norm,ATT,dT,Overlap,GDelay,dFm,Save,'SNDSCP2');
      end
      
end