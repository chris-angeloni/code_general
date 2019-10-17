function [WVSTATS]=waveformstats(waveform,validchannels)

%Obtain statistics for a tetrode waveform
%WVSTATS data structure contains fields:
%   .Peak


if nargin<2
    validchannels=[1 2 3 4];
end    

wv1=mean(squeeze(waveform(:,1,:)));
wv2=mean(squeeze(waveform(:,2,:)));
wv3=mean(squeeze(waveform(:,3,:)));
wv4=mean(squeeze(waveform(:,4,:)));
wvmean=cat(1,wv1,wv2,wv3,wv4);

Fs=48828;
N=length(wvmean);
time=[-(N-1)/2:1:(N-1)/2]/Fs*1000;

% stats from meanwaveform
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
    wvSNR(i)=waveformSNR(squeeze(waveform(:,i,:)));
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


% mean waveform similarity 
wv=wvmean(validchannels,:);
R=corrcoef(wv');
R=triu(R,1);
r=mean(mean(R(find(R))));

% mean waveform disparity across four channels
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

% values distribution at midpoint (peak/valley) 
% using the 'dip' test for unimodality. 
for i=1:4
    midpt=floor(size(waveform,3)/2)+1;
    wv=squeeze(waveform(:,i,:));
    X=(wv(:,midpt));
    X=X/max(abs(X));
    [dip, p] = HartigansDipSignifTest(X, 100);
    PeakDip(i)=dip;
    PeakDipP(i)=p;
end

% adding to data structure
WVSTATS.Peak=Peak;
WVSTATS.Valley=Valley;
WVSTATS.Peakt=Peakt;
WVSTATS.Valleyt=Valleyt;
WVSTATS.p2pvalue=p2pvalue;
WVSTATS.p2pwidth=p2pwidth;
WVSTATS.wvslope=wvslope;
WVSTATS.wvSNR=wvSNR;
WVSTATS.wvcon=wvcon;
WVSTATS.wvSI=wvSI;
WVSTATS.wvmean=wvmean;
WVSTATS.fftpeak=fftpeak;
WVSTATS.fftwidth50=fftwidth50;
WVSTATS.PeakDip=PeakDip;
WVSTATS.PeakDipP=PeakDipP;
