%
% function [RASData] = rastertexturegenerate(Data,PARAM,SOUND,TD,OnsetT,Unit,Chan)
%
%	FILE NAME 	: RASTER TEXTURE GENERATE
%	DESCRIPTION : Generates dot rasters for a sequence of texture sounds.
%                 The statistics of the sounds are modified using the
%                 programs of McDermott et al. The Paramters are coded as
%                 integers which represent a particular statistic.
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
%   PARAM       : Modulation rate sequency (From Param.mat File)
%   SOUND       : Structure containing the texture sounds file Headers
%                 (From Param.mat File)
%   TD          : Total stimulus duration (sec)
%   OnsetT      : Time to remove at onset (sec) (Default == 0 msec)
%   Unit        : Unit Number (Default==0)
%   Chan        : Channel Number (Default=0, assumes the data comes from a 
%                 single channel; If Chan == some number, then it assumes 
%                 Data is a multichannel recording)
%
% RETURNED DATA
%
%	RASData(k,l): RASTER Data Structure Matrix
%                   RASData.RASTER              - Raster Structure for each
%                                                 texture sound (k) and parameter condition (l)
%                   RASData.Param               - Modulation Frequency Axis
%                   RASData.Sound               - Spline modulation cutoff Axis
%
%   (C) Monty A. Escabi, April 8, 2016 (Edit Nov 2016)
%
function [RASData] = rastertexturegenerate(Data,PARAM,SOUND,TD,OnsetT,Unit,Chan)

%Input Arguments
if nargin<5 | isempty(OnsetT)
    OnsetT=0;
end
if nargin<7 | isempty(Chan)
    Chan=[];
end

%Finding Parameters and Sounds
Param=sort(PARAM);
index=find(diff(Param)~=0);
ParamAxis=Param([1 index+1]);
for k=1:length(SOUND)
    S(k)=sum(unicode2native(SOUND(k).FileHeader));
end
[Sounds,i]=sort(S);
SortSounds=SOUND(i);
index=find(diff(Sounds)~=0);
SoundAxis=Sounds([1 index+1]);
SoundHeaderAxis=SortSounds([1 index+1]);
clear Sounds Param

%Extracting Triggers and SPET Times                             %Edit Nov 2016
if isempty(Unit) & isempty(Chan)
    index=1:length(Data.SortCode);                              %Use all Units
elseif isempty(Unit) & ~isempty(Chan)
    index=find(Data.ChannelNumber==Chan);                       %Use specified Channel
elseif ~isempty(Unit) & isempty(Chan)
    index=find(Unit==Data.SortCode);                            %Use specified Unit
else
   index=find(Unit==Data.SortCode & Data.ChannelNumber==Chan);  %Use specified Unit & Channel
end
spet=round(Data.SnipTimeStamp(index)*Data.Fs);                  %Converint to SPET
Trig=round(Data.Trig*Data.Fs);                                  %Syncrhonization Triggers
Trig=[Trig Trig(length(Trig))+mean(diff(Trig))];                %Adding End Trigger
T=mean(diff(Trig))+1000;                                        %Trial Length + 1000 samples

%Isolating and Binning Data For Each Sound and Statistic Condition
%Generates a RASTER Data Structure
Ntotal=length(find(S==S(1) & PARAM==PARAM(1))) ;                    %Number of trials based on the total number of sounds
Ntrig=floor(length(Data.Trig)/length(SoundAxis)/length(ParamAxis)); %Number of recorded trials based on triggers
N=min(Ntotal,Ntrig);                                                %Number of Trials available
for k=1:length(SoundAxis)
    for l=1:length(ParamAxis)
    
        if ~isempty(find(SoundAxis(k)==S & ParamAxis(l)==PARAM))
            
            indexP=find(S==SoundAxis(k) & PARAM==ParamAxis(l));
            for n=1:N
                %Finding SPET for a given trial
                indexSPET=find(spet<Trig(indexP(n)+1) & spet>OnsetT+Trig(indexP(n)));       %Added Onset Time (MAE Nov 2016)
                RASData(k,l).RASTER(n).spet=round( (spet(indexSPET)-Trig(indexP(n))) );
                RASData(k,l).RASTER(n).Fs=Data.Fs;
                RASData(k,l).Sound=k;
                RASData(k,l).SoundFileHeader=SoundHeaderAxis(k);
                RASData(k,l).Param=ParamAxis(l);
                RASData(k,l).RASTER(n).T=TD;
                RASData(k,l).SoundAxis=SoundAxis;
                RASData(k,l).ParamAxis=ParamAxis;
                RASData(k,l).SoundHeaderAxis=SoundHeaderAxis;
            end
        end
    end
end