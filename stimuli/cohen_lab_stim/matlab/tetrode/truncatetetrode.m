%function [Tetrode]=truncatetetrode(Tetrode,T)
%
%   FILE NAME: TRUNCATE TETRODE
%   DESCRIPTION: Truncate tetrode data to desired time period T (second)
%   
%   T: A vector containing T1 the start and T2 the end of the time peroid (second) 
%
%   (C) C.Chen July 2008

function [Tetrode]=truncatetetrode(Tetrode,T)

if nargin<2
    T=Inf;
end

Fs=floor(Tetrode(1).Fs);
if length(T)==1
    T1=0;
    T2=round(Fs*T);
else    
    T1=round(Fs*T(1));
    T2=round(Fs*T(2));
end    


for k=1:4
    [N1,N2]=size(Tetrode(k).ContWave);
    ContWave=reshape(Tetrode(k).ContWave,1,N1*N2); 
    Tetrode(k).ContWave=ContWave(max(1,T1):min(T2,length(ContWave)));
end