%
%function [Taxis,CHist]=condspike(spet,Fs,Fsd,Disp)
%
%       FILE NAME       : COND SPIKE
%       DESCRIPTION     : Conditional Post Spike Histogram
%			  Generates Histogram of First Spike Following
%			  Spike Event 
%
%	spet		: Input Spike Event Times
%       Fs		: Samping Rate of SPET
%	Fsd		: Sampling Rate for CSH
%	T		: Post Spike Interval Length ( sec )
%	Disp		: Display : 'y' or 'n'
%			  Default : 'y' 
%
function [Taxis,CHist]=condspike(spet,Fs,Fsd,T,Disp)

%Preliminaries
if nargin<5
	Disp='y';
end

%Finding Conditioned Histogram
N=round(T*Fsd);
X=spet2impulse(spet,Fs,Fsd)/Fsd;
index=find(X==1);
CHist=zeros(1,N);
for k=1:length(index)
	if index(k)+N<length(X)
		CHist=CHist+X(index(k)+1:index(k)+N);
	end
end
if sum(CHist)~=0
	CHist=CHist/sum(CHist);
end
Taxis=(1:N)/Fsd;

%Plotting Conditioned Histogram
if strcmp(Disp,'y')
	bar(Taxis,CHist)
	ylabel(' Probability of Spike');
	xlabel('Post Spike Time ( sec )')
end
