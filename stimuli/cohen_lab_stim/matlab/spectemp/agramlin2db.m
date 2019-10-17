%
%function [stedb]=agramlin2db(ste)
%
%	FILE NAME 	: AGRAM LIN 2 DB
%	DESCRIPTION 	: Converts an 'ste' data segment from Linear amplitude
%			  to dB amplitude
%
%	ste		: SpectroTemporal Envlope
%	Min		: Minimum amplitude value (choosen from the range 0-Max)
%
%RETUERNED VARIABLES
%
%	stedb		: dB SpectroTemporal Envelope
%
function [stedb]=agramlin2db(ste,Min)

%Finding Extraneous Values (anything <= 0)
index1=find(ste<=0);
index2=find(ste>0);

%Converting Values
if nargin<2
	Min=min(min(ste(index2)));
end
if length(index1)>0
	ste(index1)=Min*ones(size(index1));
end

%Converting to Decibel Envelope
stedb=20*log10(ste);

%Perform a 9-Point Median/Mean Filter Only on Changed Values
[i1,i2]=find(stedb==20*log10(Min));
for k=1:length(i1)
	if i1(k)>1 & i1(k)<size(stedb,1) & i2(k)>1 & i2(k)<size(stedb,2) 
		stedb(i1(k),i2(k))=median(reshape(stedb(-1+i1(k):i1(k)+1,i2(k)-1:i2(k)+1),1,9));
		stedb(i1(k),i2(k))=mean(reshape(stedb(-1+i1(k):i1(k)+1,i2(k)-1:i2(k)+1),1,9));
	end
end
