function Y=filtertetrode(Tetrode,fl,fh,US)

if nargin<3
   fl=300;
end
if nargin<2
   fh=5000;
end


Fs=Tetrode(1).Fs;
%filter continous waveform
H=bandpass(fl,fh,250,Fs,40,'n');
L=(length(H)-1)/2;
Y=[];

for i=1:4
    disp(['Filtering Channel ' int2str(i)])
    Data=Tetrode(i);    
    [N1,N2]=size(Data.ContWave);
    X=conv(reshape(Data.ContWave,1,N1*N2),H);
    N=length(X);
    X=X(L+1:N-L); 
    Y(i,:)=X;
end   