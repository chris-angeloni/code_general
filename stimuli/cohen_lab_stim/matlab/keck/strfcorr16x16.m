%
%function [RSTRF16x16,SIMap] = strfcorr16x16(STRFData16_1,STRFData16_2,AudioChannel,MaxDelay,MaxFreqShift)
%
%   FILE NAME 	: STRF CORR 16X16
%   DESCRIPTION : Computes the STRF correlation between two 16 channel
%                 probes to determine the level of similarity across
%                 recording sites. Returns the optimal delay, frequency
%                 shift, 2-D STRF correlation function, and similarity
%                 index for each STRF combination ( N=16*(16-1)/2 ).
%                 Maximum correlation value is normalized as a 
%                 similarity index (-1<SI<1, Escabi & Schreiner 2003).
%
%   STRFData16_1  : Sixteen channel STRF data structure for site 1
%   STRFData16_2  : Sixteen channel STRF data structure for site 2
%   AudioChannel  : Sound Channel for correlations
%   MaxDelay      : Maximum Allowable Delay (msec) (Optional==full dimmension)
%   MaxFreqShift  : Maximum Allowable Freq Shift (Octaves) (Optional==full dimmension)
%
% RETURNED DATA
%
%   RSTRF16x16    : Data structures Matrix containing the following elements:
%                 R         - STRF 2-D crosscorrelation function.
%                 tau       - Delay axis (msec)
%                 dX        - Octave Frequency axis (Octaves)
%                 delay     - Optimal temporal delay that maximizes 
%                             correlation fxn (msec).
%                 freqshift - Optimal frequency shift that maximizes
%                             correlation fxn (Oct). 
%                 SI        - Spectrotemporal SI (at optimal delay &
%                             frequency shift)
%                 SIt       - Temporal SI (maximum SI at zero spectral
%                             shift & variable temporal delay)
%                 SIf       - Spectral SI (maximum SI at zero delay and
%                             variable spectral shift)
%                 SI00      - Spectrotemporal SI at zero delay and zero
%                             frequency shift
%   SIMap         : Similarity data structure map across all channel combinations
%                   SI      - Maximum spectrotemporal similarity index
%                   SIt     - Temporal SI (maximum SI at zero spectral
%                             shift & variable temporal delay)
%                   SIf     - Spectral SI (maximum SI at zero delay and
%                             variable spectral shift)
%
%   (C) Monty A. Escabi, Dec 2005 (Edit Nov 2007)
%
function [RSTRF16x16,SIMap] = strfcorr16x16(STRFData16_1,STRFData16_2,AudioChannel,MaxDelay,MaxFreqShift)

%Input Arguments
if nargin<4
    MaxDelay=[];
end
if nargin<5
    MaxFreqShift=[];
end

%Computing Correlations
for k=1:16
    for l=1:16
        
        %Computing STRF Correlations
        if AudioChannel==1
                [RSTRF16x16(k,l)] = strfcorr(STRFData16_1(k).STRF1,STRFData16_2(l).STRF1,STRFData16_1(1).taxis,STRFData16_1(1).faxis,STRFData16_1(1).PP,MaxDelay,MaxFreqShift);
        else
                [RSTRF16x16(k,l)] = strfcorr(STRFData16_1(k).STRF2,STRFData16_2(l).STRF2,STRFData16_1(1).taxis,STRFData16_1(1).faxis,STRFData16_1(1).PP,MaxDelay,MaxFreqShift);
        end
        
        %Similarity Index Map
        SIMap.SI(k,l)=RSTRF16x16(k,l).SI;
        SIMap.SIt(k,l)=RSTRF16x16(k,l).SIt;
        SIMap.SIf(k,l)=RSTRF16x16(k,l).SIf;
        
        %Display Progress
        clc
        f=['Correlation: [' num2str( k ) ' , ' num2str( l ) ']'];
        disp(f)
        
    end
end