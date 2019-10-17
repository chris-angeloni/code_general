%
%function [T,FF]=fanospike(spet,T1,T2,L,Fs,Fsd,Disp)
%
%       FILE NAME       : FANO SPIKE
%       DESCRIPTION     : Modified Fano Factor for Spike Train
%
%	spet		: Input Spike Event Times
%       T1		: Smallest counting window size (sec)
%			  Note: T1 >= 1/Fsd 
%	T2		: Maximum counting window size (sec)
%	L 		: Number of FF Samples
%	Fs		: Sampling Rate for SPET Array
%	Fsd		: Sampling Rate for Fano Factor Estimate 
%	FF		: Fano Factor
%	T		: Averaging window size
%			  ( sec )
%	Disp		: Display FF Plot : 'y' or 'n'
%			  Default : 'y'
%
function [T,FF]=fanspike(spet,T1,T2,L,Fs,Fsd,Disp)

%Preliminaries
if nargin < 7 
	Disp = 'y';
end
%Minimum and Maximum Window Size
alpha=(T1/T2)^(1/(L-1));

%Computing Fano Factor
for k=1:L

	%Sampling Rate Function at desired resolution
	X=spet2impulse(spet,Fs,Fsd*alpha^(k-1))/Fsd/alpha^(k-1);

	%Fano Factor
	FF(k)=var(X(1:length(X)-1))/mean(X(1:length(X)-1));
	T(k)=1/Fsd/alpha^(k-1);
end

if strcmp(Disp,'y')
	loglog(T,FF,'ro'), hold on
	loglog(T,FF,'b'), hold off
	xlabel('T ( sec )')
	ylabel('Fano Factor')
end
