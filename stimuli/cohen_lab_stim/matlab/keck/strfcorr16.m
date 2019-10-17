%
%function [RSTRF16] = strfcorr16(STRFData16,AudioChannel,MaxDelay,MaxFreqShift)
%
%   FILE NAME 	: STRF CORR 16
%   DESCRIPTION : Computes the correlation between 16 STRFs to determine
%                 the level of similarity. Returns the optimal delay,
%                 frequency shift, and the 2-D STRF correlation function
%                 for each STRF combination ( N=16*(16-1)/2 ). Maximum 
%                 correlation value is normalized as a similarity index 
%                 (-1<SI<1, Escabi & Schreiner 2003).
%
%   STRFData16  : Sixteen channel STRF data structure
%   AudioChannel  : Sound Channel for correlations
%   MaxDelay    : Maximum Allowable Delay (msec)
%   MaxFreqShift: Maximum Allowable Freq Shift (Octaves)
%
% RETURNED DATA
%
%   RSTRF16     : Array of data structures containing the following elements:
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
%                 map       - Mapping function for converting RSTRF index
%                             to correlation pair [k l]
%
%   (C) Monty A. Escabi, Oct 2005 (Edit Nov 2007)
%
function [RSTRF16] = strfcorr16(STRFData16,AudioChannel,MaxDelay,MaxFreqShift)

%Input Arguments
if nargin<3
    MaxDelay=[];
end
if nargin<4
    MaxFreqShift=[];
end

%Computing Correlations
count=1;
map=[];
for k=1:16
    for l=1:k-1
        
        %Mapping function from STRF indices to counter
        map=[map; k l];
        
        %Computing STRF Correlations
        if AudioChannel==1
                [RSTRF16(count)] = strfcorr(STRFData16(k).STRF1,STRFData16(l).STRF1,STRFData16(1).taxis,STRFData16(1).faxis,STRFData16(1).PP,MaxDelay,MaxFreqShift);
        else
                [RSTRF16(count)] = strfcorr(STRFData16(k).STRF2,STRFData16(l).STRF2,STRFData16(1).taxis,STRFData16(1).faxis,STRFData16(1).PP,MaxDelay,MaxFreqShift);
        end
        
        %Display Progress
        clc
        f=['Correlation: [' num2str( map(count,1) ) ' , ' num2str( map(count,2) ) ']'];
        disp(f)
        
        %Incrementing Counter
        count=count+1;
        
    end
end

%Adding Mapping Function to Data Structure
for k=1:120
    RSTRF16(k).map=map;
end