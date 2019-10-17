%
%function [Trig2,Trig3]=trigfixdbvsspl(TrigTimes,Fs)
%
%       FILE NAME       : TRIG FIX DB VS SPL
%       DESCRIPTION     : Finds Tripple and Double Triggers for a dB vs SPL
%			  Experiment File
%
%	TrigTimes	: Input Trigger Time Vector (in sample number)
%	Trig2		: Ouput Double Trigger Time Vector
%	Trig3		: Output Tripple Trigger Time Vector
%	Trig		: Output Triggers for STRF
%
function [Trig2,Trig3,Trig]=trigfixdbvsspl(TrigTimes,Fs)

%Finding Double and Tripple Triggers
dT=diff(TrigTimes)/Fs;
index2=find(dT<.2);
ii=find(diff(index2)==1);
index3=index2(ii);
for k=1:length(index3)
	iii=find(index2==index3(k));
	index2=[index2(1:iii-1) index2(iii+2:length(index2))];
end
Trig3=TrigTimes(index3);
Trig2=sort([TrigTimes(index2) Trig3]);
index2=sort([index2 index3]);

%plot(dT,'r+')
%Finding Single Triggers and Rearanging
index=find( dT>.7 | dT<.2 );
Trig=TrigTimes(index);
for k=2:length(Trig3)
	ii=find(Trig==Trig3(k));
	TrigNew=[];	
end
%ii=find(diff(index)>1);
%index=index(ii);

%size(index)
%for k=1:length(index3)
%	for j=1:length(index2)
%
%	
%	end	
%end

%plot(TrigTimes,'b+')
%hold on
%plot(index3,Trig3,'r+')
%plot(index2,Trig2,'g+')
