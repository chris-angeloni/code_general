%
% function [MTF] = mtfpsychogenerate(Data,FM,GAMMA,TD,OnsetT,Unit)
%
%	FILE NAME 	: MTF PSYCHO GENERATE
%	DESCRIPTION : Generates a 'psychophysical' equivalent MTF. For each
%                 modulation condition (modulation frequency and index)
%                 computes the Van Rossum spike distance metric (SDM) 
%                 referenced on a signal with modulation index of 0. The
%                 SDM is then normalized as a discrimination index
%                 (D-prime).
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
%   tc          : Time constant for computing spike distance (msec)
%   FM          : Modulation Rate Sequency (From Param.mat File)
%   GAMMA       : Modulation Index Sequency (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec)
%   Unit        : Unit Number
%
% RETURNED DATA
%
%	MTF	        : MTF Data Structure
%
%                   MTF.Dp          - Raster Structure for each FM
%                   MTF.FMAxis      - Modulation frequency axis
%                   MTF.GammaAxis   - Modulation index axis
%
%   (C) Monty A. Escabi 2004, March 2009
%
function [MTF] = mtfpsychogenerate(Data,Fsd,tc,FM,GAMMA,TD,OnsetT,Unit)

%Generating Psych Rastergram
[PsychRAS] = mtfpsychoraster(Data,FM,GAMMA,TD,OnsetT,Unit);
FMAxis=PsychRAS.FMAxis;
GAMMAAxis=PsychRAS.GAMMAAxis;

%Selecting Reference Noise Segments - Zero Modulation Index
RefRAS=[];
for k=1:size(PsychRAS,1)
    RefRAS=[RefRAS PsychRAS(k,1).RASTER];
end

%Selecting Data Segments
GAMMAAxis=GAMMAAxis(2:length(GAMMAAxis));
PsychRAS=PsychRAS(:,2:size(PsychRAS,2));

%Computing D-Prime MTF
for k=1:size(PsychRAS,1)
    for l=1:size(PsychRAS,2)
        i=find(GAMMAAxis(l)==[PsychRAS.GAMMA] & FMAxis(k)==[PsychRAS.FM]);
        [MTF.Dp(k,l)]=sdmrasterdprime(PsychRAS(k,l).RASTER,RefRAS,Fsd,tc);
        
        clc
        disp(['Computing PsychoMTF: ' num2str(100*( l+(k-1)*size(PsychRAS,2) )/numel(PsychRAS),3) ' % done'])

    end
end
MTF.FMAxis=FMAxis;
MTF.GammaAxis=GAMMAAxis;