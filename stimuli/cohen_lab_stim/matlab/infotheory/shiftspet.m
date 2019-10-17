%
%function [spet]=shiftspet(spet,Fs,Minshift,Maxshift,T)
%
%
%       FILE NAME       : SHIFT SPET
%       DESCRIPTION     : Shuffles a 'spet' variable by SHIFTING the ISI
%
%       spet            : Array of spike event times
%       Fs              : Sampling rate
%       Minshift        : Minumum allowable shift in seconds (Optional)
%       Maxshift        : Maximum allowable shift in seconds (Optional)
%       T               : Spike train duration (sec, Optional)
%                        
%   (C) Monty A. Escabi, August 2006 (Last Edit)
%
function [spet]=shiftspet(spet,Fs,Minshift,Maxshift,T)

%Input Arguments
if nargin<3
	Minshift=spet(2)/Fs;
end
if nargin<4
	Maxshift=max(spet)/Fs;
elseif nargin<5
    T=max([Maxshift max(spet)/Fs]);    
end

%Randomly Shifting the spet array - Wraparound ISIs to begining of SPET
%Array
Shift=Minshift+(Maxshift-Minshift)*rand;
i1=find(spet/Fs<Shift);
i2=find(spet/Fs>=Shift);
spet1=spet(i1);
spet2=spet(i2);
spet=[spet2-round(Shift*Fs) spet1+round(T*Fs-Shift*Fs)];
