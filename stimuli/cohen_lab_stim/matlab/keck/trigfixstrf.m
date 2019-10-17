%
%function [TrigTimes]=trigfixstrf(TrigTimes,Ndouble,NTrig)
%
%       FILE NAME   : TRIG FIX STRF
%       DESCRIPTION : Checks a trigger sequence for Multiple Triggers
%                     and for missing triggers of a Moving Ripple
%                     or Ripple Noise Trigger File
%
%   	TrigTimes   : Trigger Time Vector (in sample number)
%   	Ndouble		: Number of blocks between double triggers
%   	NTrig		: Number of Triggers in original sound file
%
function [TrigTimes]=trigfixstrf(TrigTimes,Ndouble,NTrig)

%Finding the Mean Trigger Time in samples
%Assumes no Missing Trigger
dTrig=diff(TrigTimes);
MeanTrig=mean(dTrig);
index=find(dTrig<MeanTrig*1.1);
MeanTrig=mean(dTrig(index));

%Finding Multiple Triggers
index=find(dTrig<MeanTrig*.98);

%Finding unecessary extra triggers
ii=[1 find(diff(index)>1)+1 ];
xtraindex=index;
xtraindex(ii)=-9999*ones(size(ii));
xtraindex=xtraindex(find(xtraindex~=-9999));

%Finding Double Trigger Locations
doubleindex=index;
ii=[ find(diff(index)<=1)+1 ];
doubleindex(ii)=-9999*ones(size(ii));
doubleindex=doubleindex(find(doubleindex~=-9999));

%Removing Multiple Triggers
if length(xtraindex)>0
	Trig=TrigTimes;
	Trig(xtraindex)=-9999*ones(size(xtraindex));
	Trig=Trig(find(Trig~=-9999));
else
	Trig=TrigTimes;
end

%Reconstructing Triggers in the Begining if Missed during Recording
if doubleindex(1)~=1
	Trig=[round(Trig(1)-(Ndouble-doubleindex(1)+1:-1:1)*mean(diff(Trig)))  Trig];
end

%Reconstructing Triggers at the End if Missed during Recording
if length(Trig)<NTrig
	Trig=[Trig Trig(length(Trig))+round((1:NTrig-length(Trig))*mean(diff(Trig)))];
end

%Renaming Temporary Trig Variable
TrigTimes=Trig(1:NTrig);
