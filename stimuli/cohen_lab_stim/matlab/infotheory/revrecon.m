%
%
%function []=revrecon(STRF1,STRF2,spet,Fs,Fss)
%
%       FILE NAME       : STRF REV REC
%       DESCRIPTION     : Reverse Reconstruction STRF Filter
%			  Obtained by computing the optimal wiener filter 
%			  STRF (See Hayes).  Takes as input the STRF obtained
%			  using 'rtwstrfdb' or 'rtwstrflin' and the output 
%			  spike train
%
%	revfile		: Reverse reconstruction input file
%	STRF1,STRF2	: Contra and Ipsi Lateral STRFs 
%	spet		: Array of spike event times in sample number
%	Trig		: Array of Trigger times in sample number
%	Fs		: Sampling rate for spet
%	Fss		: Sampling Rate for reverse reconstruction
%			  This must be the same as the sampling rate 
%			  used for STRF
%
%	RETURNED VALUES
%
%function []=revrecon(revfile,STRF1,STRF2,spet,Trig,Fs,Fss,NT)

%Finding Reconstruction STRF Filters
[WSTRF1,WSTRF2]=strfrevrec(STRF1,STRF2,spet,Fs,Fss);

pcolor(WSTRF1),shading flat, colormap jet

%Reconstructing input from spike train
Y=spet2impulse(spet,Fs,Fss);
Xrec=conv(Y,fliplr(WSTRF1(200,:)));

%Reading input file
fid=fopen(revfile);
X=fread(fid,728*100,'int16')';

%Finding Optimal Gain
for k=1:300
	L=round(Trig(k)/Fs*Fss);
	XrecB=Xrec(L:L+NT-1);
	XB=X((k-1)*NT+1:k*NT);
plot(XB,'r')
hold on
plot(XrecB)
axis([0 100 -.5 .5])
%pause
hold off
	G1(k)=mean(XrecB.*XB);
	G2(k)=mean(XrecB.^2);
end
G=sum(G1)/sum(G2);

%Finding Error Between X and Xrec
