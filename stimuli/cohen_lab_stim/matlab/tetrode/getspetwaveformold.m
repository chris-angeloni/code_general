function [waveform]=getspetwaveform(spet,Fs,Tetrode,T1,T2,fl,fh)


%Fs: sampling frequency for spet
%T1: Time before spike event time needed to plot (msec)
%T2: Time after spike event time needed to plot (msec)

if nargin<7
    fh=5000;
end
if nargin<6
    fl=300;
end    

[Tetrode]=truncatetetrode(Tetrode,Tetrode(1).Trig(end));
Y=filtertetrode(Tetrode,fl,fh);

M= round(T2/1000*Fs/4)+round(T1/1000*Fs/4)+1;
waveform=zeros(length(spet),4,M);
for i=1:length(spet) 
    if round(spet(i)/4)-round(T1/1000*Fs/4)>0 && round(spet(i)/4)+round(T2/1000*Fs/4)< size(Y,2)
        waveform(i,:,:)=Y(:,round(spet(i)/4)-round(T1/1000*Fs/4): round(spet(i)/4)+round(T2/1000*Fs/4));
    end    
end

