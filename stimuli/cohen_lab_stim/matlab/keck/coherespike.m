%
%function [F,Cxy]=coherespike(spet1,spet2,Fs,Fsd,df,Overlap,Disp)
%
%       FILE NAME       : COHERE SPIKE
%       DESCRIPTION     : Spike Train Coherence
%                         Uses Welch Averaging Method
%
%       spet1, spet2	: Input Spike Event Times
%       Fs              : Sampling Rate for spet
%       Fsd             : Sampling Rate Used for PSD
%       df              : Frequency Resolution
%       Overlap         : Percent Overlap in Welch Average
%                         CSD - Element of [0 1]
%                         Default:  .5
%       Disp            : Display - 'y' or 'n'
%                         Default: 'y'
%       W               : Window function (if available ignores value of df)
%                         (NFFT is choosen as length(W))
%
%RETURNED VALUES
%       F               : Frequency Array ( Hz )
%       Cxy             : Coherence Estimate
%       K               : Number of Segments in Periodogram Average
%       Stdx            : Spike train 1 standard deviation
%       Stdy            : Spike train 2 standard deviation
%
function [F,Cxy]=coherespike(spet1,spet2,Fs,Fsd,df,Overlap,Disp,W)

%Preliminaries
if nargin<6
	Overlap=.5;
end
if nargin<7
	Disp='y';
end

%Converting SPET to a sampled diract impulse array of same length
Ts=1/Fsd;
X1=spet2impulse(spet1,Fs,Fsd);
X2=spet2impulse(spet2,Fs,Fsd);
N=min(length(X2),length(X1));
X1=X1(1:N);
X2=X2(1:N);

%Finding Window and Size for a Resolution of YdF
if exist('W')==1
    NFFT=length(W);
else
	W=designw(df,50,Fsd);
	NFFT=2^nextpow2(length(W));
end

%Computing Coherence - Using Welch Averaging Method
D=round(NFFT*Overlap);
[Cxy,F]=cohere(X1-mean(X1),X2-mean(X2),NFFT,Fsd,W,D);

%Plotting Coherence
if strcmp(Disp,'y')
	subplot(211)
	plot(F,abs(Cxy))
	xlabel('Frequency ( Hz )')
	ylabel('Coherence')
	subplot(212)
	plot(F,unwrap(angle(Cxy)))
	xlabel('Frequency ( Hz )')
	ylabel('Phase Spectrum')
	hold on
	%plot([min(F) max(F)],[Cxyp(1) Cxyp(1)],'r')
	%plot([min(F) max(F)],[Cxyp(2) Cxyp(2)],'r')
	%plot([min(F) max(F)],[1+sigma 1+sigma],'g')
	%plot([min(F) max(F)],[1-sigma 1-sigma],'g')
	hold off
end
