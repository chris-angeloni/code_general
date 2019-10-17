%
%function [F,Pxx,Pxxc,Pxxp,K,Varx]=psdspike(spet,Fs,Fsd,df,T,p,Overlap,Mean,Disp)
%
%       FILE NAME   : PSD SPIKE
%       DESCRIPTION : Modified PSD for Spike Train
%                     Uses Welch Averaging Method
%
%       spet        : Input Spike Event Times
%       Fs          : Sampling Rate for spet
%       Fsd         : Sampling Rate Used for PSD
%       df          : Frequency Resolution
%       T           : Spike train duration (sec)
%                     (Optional, Otherwised determinded by SPET array)
%       p           : Significance Probability
%                     Default:  .01
%       Overlap     : Percent Overlap in Welch Average
%                     PSD - number between [0 1] (Default==0.5)
%       Mean        : Remove DC (Mean) component prior to estimating PSD
%                     'y' or 'n' (Default=='n')
%       Disp        : Display : 'y' or 'n' (Default=='n')
%
%RETURNED VALUE
%       F           : Returned Frequency Array ( Hz )
%       Pxx         : Power Spectrum Estimate
%       Pxxc        : p Confidence Interval for Pxy
%       Pxxp        : p Confidence Interval for poison spike train
%                     Null Hypothesis
%       K           : Number of segments in periodogram average
%       Varx        : Spike Train Varience 
%
% (C) Monty A. Escabi, Edited July 2006
%
function [F,Pxx,Pxxc,Pxxp,K,Varx]=psdspike(spet,Fs,Fsd,df,T,p,Overlap,Mean,Disp)

%Input Arguments
if nargin<5
    T=max([spet])/Fs;
end
if nargin<6
	p=.01;
end
if nargin<7
	Overlap=.5;
end
if nargin<8
	Mean='n';
end
if nargin<9
    Disp='y';
end

%Converting SPET to a sampled diract impulse array
Ts=1/Fsd;
X=spet2impulse(spet,Fs,Fsd,T);
N=length(X);
No=sum(X*Ts);

%Finding Window and Size for a Resolution of dF
W=designw(df,50,Fsd);
L=2^nextpow2(length(W));

%Computing PSD - Using Welch Averaging Method
D=round(L*Overlap);
if Mean=='y'
    X=X-mean(X);
end
[Pxx,Pxxc,F]=psd(X,L,Fsd,[],D,1-p,'none');
Varx=1/Ts*No/N;		%Variance of X which == mean Pxx for Poison
%Pxx=Pxx/Varx*Ts;
%Pxxc=Pxxc/Varx*Ts;
Pxx=Pxx*Ts;
Pxxc=Pxxc*Ts;

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
K=N/(L-D)-1;                    %Number of Segments in Periodogram Average
NoW=No*L/N;                     %Number of Spikes in an averaging window 
%sigma=1/L^2/Ts^4*NoW*(NoW-1);	%VAR of VAR For a single segment of poison

sigma=1/L^2/Ts^4*NoW*NoW;       %VAR of VAR For a single segment of poison
sigma=sqrt(1/K*sigma);          %STD of the VAR after K averages
%sigma=sigma/Varx*Ts;           %Normalized STD of VAR to Var of X - the Mean PSD!
sigma=sigma*Ts;                 %NOT Normalized!!!! as above

%Alternately use Formulas from Hayes - var[Px^2]=9/8*E[Px^2]
%We have:  E[Pxx^2]=1/L/Ts^2*NoW for Poison
%sigma=9/8/sqrt(K)*1/L/Ts^2*NoW;
%sigma=sigma/Varx;

%Confidence Limit
Pxxp=[Varx+sigma*Tresh Varx-sigma*Tresh];

%PLoting Power Spectrum
if strcmp(Disp,'y')
	plot(F,Pxx)
	hold on
	plot([min(F) max(F)],[Pxxp(1) Pxxp(1)],'r')
	plot([min(F) max(F)],[Pxxp(2) Pxxp(2)],'r')
	plot([min(F) max(F)],[Varx+sigma Varx+sigma],'g')
	plot([min(F) max(F)],[Varx-sigma Varx-sigma],'g')
	hold off
	xlabel('Frequency ( Hz )')
	ylabel('Power Spectrum')
end