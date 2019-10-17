%
%function [F,Cxy,Cxyc,Cxyp,K,Stdx,Stdy]=csdspike(spet1,spet2,Fs,Fsd,df,T,p,Overlap,Mean,Disp)
%
%       FILE NAME       : CSD SPIKE
%       DESCRIPTION     : Modified CSD for Spike Train
%                         Uses Welch Averaging Method
%
%       spet1, spet2	: Input Spike Event Times
%       Fs              : Sampling Rate for spet
%       Fsd             : Sampling Rate Used for PSD
%       df              : Frequency Resolution
%       T               : Spike train duration (sec)
%                         (Optional, Otherwised determinded by SPET array)
%       p               : Significance Probability
%                         Default:  .01
%                         Same value used for Poisson Null Hypothesis  
%                         and for confidence limits on Cross Spectral
%                         Density
%       Overlap         : Percent Overlap in Welch Average
%                         CSD - Element of [0 1]
%                         Default:  .5
%       Mean            : Remove Mean from Spike Train Prior to Computing CSD	
%                         Default=='n'
%       Disp            : Display - 'y' or 'n'
%                         Default: 'n'
%
%RETURNED VALUES
%       F               : Frequency Array ( Hz )
%       Cxy             : Cross Power Spectrum Estimate
%       Cxyc            : p Confidence Interval for Cxy
%       Cxyp            : p Confidence Interval for poison spike train
%                         Null Hypothesis
%       K               : Number of Segments in Periodogram Average
%       Stdx            : Spike train 1 standard deviation
%       Stdy            : Spike train 2 standard deviation
%
% (C) Monty A. Escabi, Edited July 2006
%
function [F,Cxy,Cxyc,Cxyp,K,Stdx,Stdy]=csdspike(spet1,spet2,Fs,Fsd,df,T,p,Overlap,Mean,Disp)

%Preliminaries
if nargin<6
    T=max([spet1 spet2])/Fs;
end
if nargin<7
	p=.01;
end
if nargin<8
	Overlap=.5;
end
if nargin<9
	Mean='n';
end
if nargin<10
	Disp='n';
end

%Converting SPET to a sampled diract impulse array of same length
Ts=1/Fsd;
X1=spet2impulse(spet1,Fs,Fsd,T);
X2=spet2impulse(spet2,Fs,Fsd,T);
N=min(length(X2),length(X1));
X1=X1(1:N);
X2=X2(1:N);
No1=sum(X1*Ts);
No2=sum(X2*Ts);

%Finding Window and Size for a Resolution of YdF
W=designw(df,50,Fsd);
L=2^nextpow2(length(W));
%L=length(W);

%Removing Mean
if strcmp(Mean,'y')
	X1=X1-mean(X1);
	X2=X2-mean(X2);
end

%Computing PSD - Using Welch Averaging Method
NOverlap=round(L*Overlap);
[Cxy,Cxyc,F]=csd(X1,X2,L,Fsd,[],NOverlap,1-p,'none');
Varx=1/Ts*No1/N;		%Variance of X which == mean Pxx for Poison
Vary=1/Ts*No2/N;		%Variance of Y which == mean Pxx for Poison
Stdx=sqrt(Varx);		%STD of X which == mean Pxx for Poison
Stdy=sqrt(Vary);		%STD of Y which == mean Pyy for Poison
%Cxy=Cxy/sqrt(Varx*Vary);
%Cxyc=Cxyc/sqrt(Varx*Vary);
Cxy=Cxy*Ts;
Cxyc=Cxyc*Ts;

%Finding the STD Threshold required to exceed a Right Tail
%Probability of p
Tresh=sqrt(2)*erfinv(1-2*p);

%Computing Confidence Limits - Assuming Null Hypothesis - Spike Train == Poison
%Normalized PSD For Poison -> PSDPoison/Var=1
%For Welsh Averaging Periodogram Method 
%Referenc Hayes, Pg 391-419
%Using 50% Overlap -> D=L/2;
%For Poison:  Var[Px^2]=1/L^2/Ts^4*NoW*(Now-1)
%So we can Average over K Trials to get Confidence Limits
%Recall std ~ 1/sqrt(K)
%
K=N/(L-NOverlap)-1;                 %Number of Segments in Periodogram Average
NoW1=No1*L/N;                       %Number of Spikes in an averaging window 
sigma1=1/L^2/Ts^4*NoW1*(NoW1-1);	%VAR of VAR For a single segment of poison
sigma1=sqrt(1/K*sigma1);            %STD of the VAR after K averages
%sigma1=sigma1/Varx;                %Normalized STD of VAR to Var of X - the Mean PSD!
sigma1=sigma1*Ts;                   %NOT Normalized

%Confidence Limit
Cxyp=[Stdx*Stdy+sigma1*Tresh Stdx*Stdy-sigma1*Tresh];

%PLoting Power Spectrum
if strcmp(Disp,'y')
	subplot(211)
	plot(F,abs(Cxy))
    hold on
	plot([min(F) max(F)],[Cxyp(1) Cxyp(1)],'r')
	plot([min(F) max(F)],[Cxyp(2) Cxyp(2)],'r')
	plot([min(F) max(F)],[Stdx*Stdy+sigma1 Stdx*Stdy+sigma1],'g')
	plot([min(F) max(F)],[Stdx*Stdy-sigma1 Stdx*Stdy-sigma1],'g')
	hold off
	xlabel('Frequency ( Hz )')
	ylabel('Cross Power Spectrum')
	subplot(212)
	plot(F,unwrap(angle(Cxy)))
	xlabel('Frequency ( Hz )')
	ylabel('Phase Spectrum')
end
