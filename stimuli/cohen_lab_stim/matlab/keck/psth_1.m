%
%function [taxis,PSTH,RASTER]=psth(TrigTimes,spet,Fs,Fss)
%
%       FILE NAME       : PSTH
%       DESCRIPTION     : Generates a Post Stimulis Time Histogram 
%
%       TrigTimes       : Trigger Time vector (in sample number)
%       spet            : Spike event time vector (in sample number)
%   	Fs              : Sampling rate for spet and TrigTimes
%       Fss             : Sampling rate for PSTH
%
%   (C) Monty A. Escabi, August 2006 (Last Edit)
%
function [taxis,PSTH,RASTER]=psth(TrigTimes,spet,Fs,Fss)

%Generating PSTH
Ts=1/Fss;
N=round(max(diff(TrigTimes))*Fss/Fs);
M=length(TrigTimes);
PSTH=zeros(1,N+100);
RASTER=zeros(M-1,N+100);
for k=1:M-1
	index=find(spet>TrigTimes(k) & spet<TrigTimes(k+1));
	spetk=round( 1 + ( spet(index)-TrigTimes(k) )*Fss/Fs );
	if length(spetk)>0
		for j=1:length(spetk)
			RASTER(k,spetk(j))=RASTER(k,spetk(j))+1;
		end
	end
end
taxis=(1:N+100)/Fss;
PSTH=sum(RASTER)/(M-1)/Ts;
RASTER=sparse(RASTER)/Ts;