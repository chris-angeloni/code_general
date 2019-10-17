%
%function [DT,IETH]=iethspike(spet,Fs,Fsd,MaxDT,Disp)
%
%       FILE NAME       : IETH
%       DESCRIPTION     : Inter Event Time Histogram of Spike
%			  Train 
%
%	spet		: Input Spike Event Times
%       Fs		: Samping Rate of SPET
%	Fsd		: Sampling Rate for IETH
%	MaxDT		: Maximum Inter Event Time
%	Disp		: Display : 'y' or 'n'
%			  Default : 'y' 
%
function [DT,IETH]=iethspike(spet,Fs,Fsd,MaxDT,Disp)

%Preliminaries
if nargin<5
	Disp='y';
end

%Finding IETH Histogram
N=round(MaxDT*Fsd);
dt=diff(spet)/Fs;
DT=(1:N)/Fsd;
IETH=hist(dt,DT);
IETH=IETH(1:N-1);
DT=DT(1:N-1);
IETH=IETH/sum(IETH);

%Plotting IETH
if strcmp(Disp,'y')
	plot(DT,IETH)
	ylabel(' Probability ');
	xlabel('Ineter Event Time ( sec )')
end
