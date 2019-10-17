%
%function [ILD] = ildgenerate(Data,ParamList,T1,T2)
%
%	FILE NAME 	: ILD Generate
%	DESCRIPTION : Generates a ILD response curve
%
%	Data        : Data structure obtained using "READTANK"
%                 Data is formated as follows:
%
%                   Data.Snips              - Snipet Waveforms
%                   Data.Fs                 - Sampling Rate
%                   Data.SnipsTimeStamp     - Snipet Time Stamps
%                   Data.SortCode           - Sort Code for the Snipets
%                   Data.ChannelNumber      - Channel Number for the
%                   Snipets
%                   Data.Trig               - Trigger Event Times
%                   Data.Attenuation        - Event Attenuation Level
%                   Data.Frequency          - Event Frequency 
%                   Data.StimOff            - Stimulus Offset Time
%                   Data.StimOn             - Stimulus Onset Time
%                   Data.EventTimeStanp     - Event Time Stamp
%
%   T1          :   ILD measurement window start time
%   T2          :   ILD measurement window end time
%
% RETURNED DATA
%
%	ILD	        : ILD response curve data structure
%
%                   ILD.ILDAxis             - ILD Axis (dB)
%                   ILD.data                - ILD Data Matrix ( trials x
%                                             ILD )
%                   FTC.NILD                - Number of ILD repeats
%                   FTC.T1                  - FTC Window start time
%                   FTC.T2                  - FTC Window end time
%
%   (C) Monty A. Escabi, May. 2008
%
function [ILD] = ildgenerate(Data,ParamList,T1,T2)

%Number of Snips
Nsnips=max(Data.SortCode)+1;

%Some Definitions
EventTS=[Data.Trig max(Data.Trig)+mean(diff(Data.Trig))];
SnipTS=Data.SnipTimeStamp;

%Extracting Spike Count Data for each Event
for k=1:length(EventTS)-1
    for l=0:Nsnips-1
        
        index=find(SnipTS>EventTS(k)+T1/1000 & SnipTS<EventTS(k)+T2/1000 & Data.SortCode==l);
        ILD(l+1).Data(k)=length(index);
        
    end 
end

%Generating ILD Axis
index=[1 find(diff(sort(ParamList.ILD))~=0)+1];
ILDAxis=sort(ParamList.ILD);
for k=0:Nsnips-1
    ILD(k+1).ILDAxis=ILDAxis(index);
end

%Arranging ILD Data into Matrix with response trials
[ILDAxis,index]=sort(ParamList.ILD);
N2=length(ILD.ILDAxis);
N1=length(ParamList.ILD)/N2;
for k=0:Nsnips-1
    ILD(k+1).data=reshape(ILD(k+1).Data(index),N1,N2);
end

%Adding Number of trials, T1 and T2 to ILD Data Structure
for k=1:Nsnips
     ILD(k).NILD=N1;
     ILD(k).T1=T1;
     ILD(k).T2=T2;
end