%
% function [RTF] = mtfpsychogenerateoptfast(Data,Fsd,tc,FM,RD,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: RTF PSYCHO OPT GENERATE
%	DESCRIPTION : Generates a 'psychophysical' equivalent RTF. For each
%                 modulation condition (modulation frequency and index)
%                 computes the Van Rossum spike distance metric (SDM) 
%                 referenced on a signal with modulation index of 0. The
%                 SDM is then normalized as a discrimination index
%                 (D-prime). A search is then performed across integration
%                 time constants (tc) in order to find the optimal
%                 discrimination index and optimal discrimination
%                 resolution.
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%
%   Fsd         : Desired sampling rate for analysis (Hz)
%   tc          : Time constant ARRAY for computing spike distance (msec).
%                 A search is performed across all tc to find the optimal
%                 discrimination index and tc.
%   FM          : Modulation Rate Sequency (From Param.mat File)
%   RD          : Ripple Density Sequence (From Param.mat File)
%   GAMMA       : Modulation Index Sequency (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%   RTF	        : RTF Data Structure
%
%                   RTF.Dp          - Raster Structure for each FM and RD
%                   RTF.FMAxis      - Modulation frequency axis (Hz)
%                   RTF.RDAxis      - Ripple density axis (cycles/oct)
%                   RTF.GammaAxis   - Modulation index axis
%                   RTF.tc          - Analysis time constant (msec)
%
%   (C) Monty A. Escabi, Jan 2010
%
function [RTF] = mtfpsychogenerateoptfast(Data,Fsd,tc,FM,RD,GAMMA,TD,OnsetT,Unit)

%Generating Psycho MTF across multiple tc
for k=1:length(tc)
    [RTF(k)] = rtfpsychogeneratefast(Data,Fsd,tc(k),FM,RD,GAMMA,TD,OnsetT,Unit);
    clc
    disp(['tc Optimization: ' num2str(100*k/length(tc)) ' % done'])
end

%Adding Time constant to returned data
for k=1:length(tc)
    RTF(k).tc=tc(k);
end