%
% function [Data] = sgsr2ftcescabi(dataFile,dataDir,dataseqs,seqstrdum,auralflag)
%
%	FILE NAME 	: FTC Generate
%	DESCRIPTION : Generates a frequency tunning curve on the TDT system
%
%   dataFile    : Data file name ( SGSR extension exluded)
%   dataDir     : Data directory
%   dataseqs    : Data sequences within SGSR file containig the data
%   seqstrdum   : Sequence string (e.g., 'Sequence000')
%   auralflag   : Flag for choosing aural configuration (Optional)
%                   if auralflag = 1 then chooses contra sound
%                   if auralflag = 2 then chooses ipsi sound
%                   if unspecified chooses contra sound
%
% RETURNED DATA
%
%	Data        : Data structure formatted as follows:
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
%   (C) Brian Bishop/Monty A. Escabi, Last edit Sept 2013
%
function [Data] = sgsr2ftcescabi(dataFile,dataDir,dataseqs,seqstrdum,auralflag)

%Input Arguments
if nargin<5
    auralflag=1;
end

%Full Filepath and Name
fulldatapath = [dataDir filesep dataFile '.SGSR'];

%Initialize variables
StimOn = [];
StimOff = [];
SnipTimeStamp = [];
Attenuation = [];
Frequency = [];

%Extracting Data
for nseq = 1:length(dataseqs)
    seqstr = seqstrdum;
    seqnumstr = num2str(dataseqs(nseq));
    seqstr(end-length(seqnumstr)+1:end) = seqnumstr;
    dd = load(fulldatapath, seqstr, '-mat');
    seqstruct = dd.(seqstr);
    spks = seqstruct.SpikeTimes.spikes.spt;
    [msubs nreps] = size(spks);
    for msub = 1:msubs
        for nrep = 1:nreps
            if nseq==1 && msub==1 && nrep==1
                StimOn = 0;
                %working with the duration will require more thought than this.
                StimOff = str2num(seqstruct.Header.StimParams.indiv.stim{1}.duration); 
            else
                StimOn = [StimOn StimOn(end)+seqstruct.Header.StimParams.interval];
                StimOff = [StimOff StimOn(end)+str2num(seqstruct.Header.StimParams.indiv.stim{1}.duration)];
            end
            
            SnipTimeStamp = [SnipTimeStamp spks{msub,nrep}+StimOn(end)];
            
            if auralflag==2     %Right Ear
                if strcmp(seqstruct.Header.StimName,'FRA')      %For new FRA option, Sept 2013
                    Attenuation = [Attenuation seqstruct.Header.IndepVar.yValues(msub)];
                    Frequency = [Frequency seqstruct.Header.varValuesRight(msub)]; 
                else
                    Attenuation = [Attenuation seqstruct.Header.StimParams.indiv.stim{2}.spl];
                    Frequency = [Frequency seqstruct.Header.varValuesRight(msub)];            
                end
            else                %Left ear
                if strcmp(seqstruct.Header.StimName,'FRA')      %For new FRA option
                    Attenuation = [Attenuation seqstruct.Header.IndepVar.yValues(msub)];
                    Frequency = [Frequency seqstruct.Header.varValuesLeft(msub)]; 
                else
                    Attenuation = [Attenuation seqstruct.Header.StimParams.indiv.stim{1}.spl];
                    Frequency = [Frequency seqstruct.Header.varValuesLeft(msub)];
                end
            end
        end
    end
end

%Adding data to structure using Monty's format
Data.Snips = [];
Data.Fs = seqstruct.Header.RecordParams.samFreqs;
Data.SnipTimeStamp = SnipTimeStamp*1e-3;    %Convert to sec
Data.SortCode = zeros(1,length(SnipTimeStamp));
Data.ChannelNumber = ones(1,length(SnipTimeStamp));
Data.Trig = [];
Data.Attenuation = Attenuation;
Data.Frequency = Frequency;
Data.StimOff = StimOff*1E-3;                %Convert to sec
Data.StimOn = StimOn*1E-3;                  %Convert to sec
Data.StimSweep = [];
Data.EventTimeStamp = StimOn*1E-3;
Data.ContWave = [];
Data.FsCont = [];