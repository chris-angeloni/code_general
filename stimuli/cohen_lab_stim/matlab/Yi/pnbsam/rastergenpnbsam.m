% function [RASPNB,RASSAMN] = rastergenpnbsam(Data,flag,FM,T,TD,OnsetT,Unit,N)
%
%	FILE NAME 	: RASTER GENERATE
%	DESCRIPTION : Generate Raster spet format and time trial format
%
%   Data        : Data structure returned by TDT
%   flag        : Array containing 0 or 1. Used to designate SAM (flag=0) 
%                 and PNB (flag=1) for each of the recorded triggers in
%                 Data.
%   FM          : Array containing the modulation frequencies for each of
%                 the trigger sound events in Data.
%   T           : Array containing the stimulus durations for each trial
%                 and stimulus condition.
%   TD          : The type of dot-raster. If TD is a number in sec, then it
%                 will truncate each trial to TD seconds. If TD==[], then
%                 it does nothing. If TD='cyc', then it will truncate to an
%                 equal number of cycles where the total duraion for each
%                 trial is determined by T.
%   OnsetT      : Time to remove at begining of raster (sec, Default==0)
%   Unit        : Unit Number (typically 0)
%
% RETURNED DATA
%
%	RASSAMN	    : SAMN Dot Raster in spet format
%                .spet         - Spike event time 
%                .Fs           - Sampling rate (Hz)
%                .T            - Response duration 
%                .Fm           - Modulation frequency
%
%	RASPNB	    : PNB Dot Raster in spet format
%                .spet         - Spike event time 
%                .Fs           - Sampling rate (Hz)
%                .T            - Response duration 
%                .Fm           - Modulation frequency
%
% (C) Monty A. Escabi, July 2009
%
function [RASPNB,RASSAMN] = rastergenpnbsam(Data,flag,FM,T,TD,OnsetT,Unit)

%Selecting Unit Sort
if nargin<7
   indexU = 1:length(Data.SortCode);                                    %Use all Units
else
   indexU = find(Unit==Data.SortCode);                                  %Use specified Unit
end
if nargin<6
    OnsetT = 0;
end
%Generating Modulation Frequency Axis
[FMSort,i]=sort(FM);
index=find(diff(FMSort)>0);
FMAxis=FMSort([index max(index)+mean(diff(index))]);
T=T(i);
T=T([index max(index)+mean(diff(index))]);

%Number of trials for each condition
N=length(FM)/2/length(FMAxis);

%Converting Snip Time Stamps to SPET
spet = round(Data.SnipTimeStamp(indexU)*Data.Fs);                       %Converint to SPET
Trigall = round(Data.Trig*Data.Fs);                                     %Syncrhonization Triggers
Trigall = [Trigall Trigall(length(Trigall))+mean(diff(Trigall))];       %Adding End Trigger
       
%Generating SAM Raster (Flag==0)
Trig = Trigall(find(flag==0));
Trig = [Trig Trig(length(Trig))+mean(diff(Trig))];
for k=1:length(FMAxis);
    indexFM = find(FM == FMAxis(k) & flag==0); 
    for n=1:N
        indexSPET=find(spet<Trigall(indexFM(n)+1) & spet>Trigall(indexFM(n)));
        RASSAMN(n+(k-1)*N).spet = round( (spet(indexSPET)-Trigall(indexFM(n))) );
        RASSAMN(n+(k-1)*N).Fs = Data.Fs;  
        RASSAMN(n+(k-1)*N).Fm = FMAxis(k);
        RASSAMN(n+(k-1)*N).T  = T(k);
    end
end

%Generating PNB Raster (Flag==0)
Trig = Trigall(find(flag==1));
Trig = [Trig Trig(length(Trig))+mean(diff(Trig))];
for k=1:length(FMAxis);
    indexFM = find(FM == FMAxis(k) & flag==1); 
    for n=1:N
        indexSPET = find(spet<Trigall(indexFM(n)+1) & spet>Trigall(indexFM(n)));
        RASPNB(n+(k-1)*N).spet = round( (spet(indexSPET)-Trigall(indexFM(n))) );
        RASPNB(n+(k-1)*N).Fs = Data.Fs;
        RASPNB(n+(k-1)*N).Fm = FMAxis(k);
        RASPNB(n+(k-1)*N).T  = T(k);
    end
end

%Truncating dot-rasters to desired duation. If TD>0 then it will truncate
%to the desired duration. If TD==[] then the programs keeps the raw
%dot-raster which includes the pause. If TD is an array, it will truncate
%each condition according to the array. This is useful for keeping equal
%number of trials per condition.
if TD>0 & length(TD)==1
   for k=1:length(RASPNB)
      index=find(RASPNB(k).spet<TD*Data(1).Fs);
      RASPNB(k).spet=RASPNB(k).spet(index);
      index=find(RASSAMN(k).spet<TD*Data(1).Fs);
      RASSAMN(k).spet=RASSAMN(k).spet(index);
      RASPNB(k).T=TD;
      RASSAMN(k).T=TD;
   end
elseif strcmp(TD,'cyc')
    for k=1:length(RASPNB)
          index=find(RASPNB(k).spet<T(floor((k-1)/N)+1)*Data(1).Fs);
          RASPNB(k).spet=RASPNB(k).spet(index);
          index=find(RASSAMN(k).spet<T(floor((k-1)/N)+1)*Data(1).Fs);
          RASSAMN(k).spet=RASSAMN(k).spet(index);
          RASPNB(k).T=T(floor((k-1)/N)+1);
          RASSAMN(k).T=T(floor((k-1)/N)+1);
   end
end

%Removing Onset Time - removes an integer number of cycles and at least
%OnsetT seconds
for k=1:length(RASPNB)
%    TT=ceil(OnsetT*RASPNB(k).Fm)/RASPNB(k).Fm;
    TT=OnsetT;
    index = find(RASPNB(k).spet> TT*RASPNB(1).Fs);
    RASPNB(k).spet=RASPNB(k).spet(index);
    index = find(RASSAMN(k).spet> TT*RASSAMN(1).Fs);
    RASSAMN(k).spet=RASSAMN(k).spet(index);
end