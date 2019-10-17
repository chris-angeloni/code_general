function [waveform]=getspetwaveform(spet,Fs,Tetrode,T1,T2,fl,fh,US)


%Fs: sampling frequency for spet
%T1: Time before spike event time needed to plot (msec)
%T2: Time after spike event time needed to plot (msec)
if nargin<8
    US=4;
end    
if nargin<7
    fh=5000;
end
if nargin<6
    fl=300;
end    
[Tetrode]=truncatetetrode(Tetrode,Tetrode(1).Trig(end));
%Y=filtertetrode(Tetrode,fl,fh);
H=bandpass(fl,fh,250,Tetrode(1).Fs,40,'n');
L=(length(H)-1)/2;

M= round(T2/1000*Fs/4)+round(T1/1000*Fs/4)+1;
waveform=zeros(length(spet),4,(M-1)*US);
for i=1:length(spet) 
    if round(spet(i)/4)-round(T1/1000*Fs/4)>0 && round(spet(i)/4)+round(T2/1000*Fs/4)< length(Tetrode(1).ContWave)
        for j=1:4            
            X=Tetrode(j).ContWave(:,round(spet(i)/4)-round(T1/1000*Fs/4)-L: round(spet(i)/4)+round(T2/1000*Fs/4)+L);
            X=conv(X,H);
            N=length(X);
            X=X(2*L+1:N-2*L); 
            X=interp1(1:length(X),X,1:1/US:length(X)-1/US,'spline');
            waveform(i,j,:)=X;
            
        end
    end    
end
