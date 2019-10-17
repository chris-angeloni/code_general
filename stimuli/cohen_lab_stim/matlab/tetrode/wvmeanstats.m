function [Peak,Valley,Peakt,Valleyt,p2pvalue,p2pwidth,wvslope,wvcon,wvSI,fftpeak,fftwidth50]=wvmeanstats(wvmean,validchannels)

if nargin<2
    validchannels=[1 2 3 4];
end   

Fs=48828;
N=length(wvmean);
time=[-(N-1)/2:1:(N-1)/2]/Fs*1000;


for i=1:4
    wv=wvmean(i,:);
    [MAX,I]=max(wv);
    [MIN,J]=min(wv);
    Peak(i)=MAX;
    Valley(i)=MIN;
    Peakt(i)=time(I);
    Valleyt(i)=time(J);
    p2pvalue(i)=MAX-MIN;
    p2pwidth(i)=abs(J-I);
    wvslope(i)=max(abs(diff(wv)));
    N=1024;f=(0:N/2)*Fs/N;
    W=kaiser(length(wv),5)';
    X=fft(wv.*W,N)/N;
    X=abs(X(1:N/2+1))/max(abs(X));
    [MAX,I]=max(X);
    J=find(f>1000 & X<.5);
    fftpeak(i)=f(I);
    fftwidth50(i)=f(J(1));
end    
p2pwidth=p2pwidth/Fs*1000;
wvslope=wvslope*Fs/1000;
    
 
wv=wvmean(validchannels,:);
if validchannels==4                %%ignore channel with smallest energy
    I=find(p2pvalue>min(p2pvalue));
    wv=wv(I,:);
end 
R=corrcoef(wv');
R=triu(R,1);
r=mean(mean(R(find(R)))); 

wvcon=1;
count=0;
for k=1:length(R)
    s_k=wv(k,:);
    for l=k+1:length(R)
        s_l=wv(l,:);
        con=var(s_k-s_l)/sqrt(var(s_k)*var(s_l));
        wvcon=wvcon*con;
        count=count+1;
    end    
end
wvcon=wvcon^(1/count);
wvSI=r;