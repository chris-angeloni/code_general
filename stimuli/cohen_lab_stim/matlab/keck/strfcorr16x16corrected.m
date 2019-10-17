%
%function [RSTRF16x16,SIMap] =
%         strfcorr16x16corrected(STRFData16_1,STRFData16_2,AudioChannel,NoiseFlag,MaxDelay,MaxFreqShift)
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
%                 Unlike STRFCORR16x16 this program compensates for 
%                 reductions in the SI due to internal noise.
%
%   STRFData16_1  : Sixteen channel STRF data structure for site 1
%   STRFData16_2  : Sixteen channel STRF data structure for site 2
%   AudioChannel  : Sound Channel for correlations
%   NoiseFlag     : Method for estimating noise variance
%                       1: Subtracts STRF from two independent trials (Default)
%                       2: Uses non significant samples to estimate noise
%                          variance
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
%                     SI      - Maximum spectrotemporal similarity index
%                     SIt     - Temporal SI (maximum SI at zero spectral
%                               shift & variable temporal delay)
%                     SIf     - Spectral SI (maximum SI at zero delay and
%                               variable spectral shift)
%
%   (C) Monty A. Escabi, November 2007
%
function [RSTRF16x16,SIMap] = strfcorr16x16corrected(STRFData16_1,STRFData16_2,AudioChannel,NoiseFlag,MaxDelay,MaxFreqShift)

%Input Arguments
if nargin<4
    NoiseFlag=1;
end
if nargin<5
    MaxDelay=[];
end
if nargin<6
    MaxFreqShift=[];
end

%Computing Correlations
for k=1:16
    for l=1:16
        
        %Computing STRF Correlations
        if AudioChannel==1  %Audio Channel 1
            
            %Extracting STRF Data for each channel to compare
            STRF_kA=STRFData16_1(k).STRF1A;
            STRF_kB=STRFData16_1(k).STRF1B;
            STRF_ks=STRFData16_1(k).STRF1s;
            STRF_lA=STRFData16_2(l).STRF1A;
            STRF_lB=STRFData16_2(l).STRF1B;
            STRF_ls=STRFData16_2(l).STRF1s;
            taxis=STRFData16_1(k).taxis;
            faxis=STRFData16_1(k).faxis;
            PP=STRFData16_1(k).PP;
            
            %Computing Correlation for Audio Channel 1
            [RSTRF16x16(k,l)] = strfcorrcorrected(STRF_kA,STRF_kB,STRF_ks,STRF_lA,STRF_lB,STRF_ls,taxis,faxis,PP,NoiseFlag,MaxDelay,MaxFreqShift);
    
        else                %Audio Channel 2

            %Extracting STRF Data for each channel to compare
            STRF_kA=STRFData16_1(k).STRF2A;
            STRF_kB=STRFData16_1(k).STRF2B;
            STRF_ks=STRFData16_1(k).STRF2s;
            STRF_lA=STRFData16_2(l).STRF2A;
            STRF_lB=STRFData16_2(l).STRF2B;
            STRF_ls=STRFData16_2(l).STRF2s;
            taxis=STRFData16_1(k).taxis;
            faxis=STRFData16_1(k).faxis;
            PP=STRFData16_1(k).PP;
            
            %Computing Correlation for Audio Channel 2
            [RSTRF16x16(k,l)] = strfcorrcorrected(STRF_kA,STRF_kB,STRF_ks,STRF_lA,STRF_lB,STRF_ls,taxis,faxis,PP,NoiseFlag,MaxDelay,MaxFreqShift);

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