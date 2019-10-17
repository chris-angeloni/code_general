%   T: A vector containing T1 the start and T2 the end of the time peroid (second) 

function [C]=tetrodecov(Tetrode,T,fl,fh,US)

if nargin<5
    US=4;
end    
if nargin<4
    fh=5000;
end    
if nargin<3
    fl=300;
end
if nargin<2
    T=Tetrode(1).Trig(end);
end

[Tetrode]=truncatetetrode(Tetrode,T);
%Filter continous waveform
Fs=Tetrode(1).Fs;
H=bandpass(fl,fh,250,Fs,40,'n');
L=(length(H)-1)/2;
Y=[];
for i=1:4
    disp(['Filtering Channel ' int2str(i)])
    X=conv(Tetrode(i).ContWave,H);
    N=length(X);
    X=X(L+1:N-L);
    Y(i,:)=X;
end 
[C]=covblocked(Y',US,0,1024*512);       %Covariance
end    