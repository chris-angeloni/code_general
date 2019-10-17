%
%function [HWord,HSpike,HSec,Rate]=infwordspike(spet,Fs,Fsd,B,N,T,Trig)
%
%
%       FILE NAME       : INF WORD SPIKE
%       DESCRIPTION     : Enthropy of spike train obtained by computing the
%			  Probability Distribution, P(W), of finding a B
%			  letter Word, W, in the Spike Train
%
%       spet		: Spike Event Times 
%	Fs		: Sampling Rate for 'spet'
%	Fsd		: Sampling rate for generating P(W) - Fsd <= 1000 Hz
%	B		: Length of Word, number of bits
%	N		: Number of Words used to generate running 
%			  Estimate of P(W) - Note that N/1000 is the temporal
%			  resolution of estimate
%	T		: Time to remove at the begining of spike train
%			  to avoid adaptive effects (Default==120 sec)
%	Trig		: Corresponding Trigger Array
%			  Used to determine the start and end of the stimulus
%			  and the corresponding spikes (Optional)
%		
%Returned Variables
%	HWord		: Information per Word Array (Computed Every N/1000 sec)
%	HSpike		: Information per Spike Array
%	HSec		: Information per Second Array
%	Rate		: Mean Spike Rate
%
function [HWord,HSpike,HSec,Rate,P]=infwordspike(spet,Fs,Fsd,B,N,T,Trig)

%Checking Input Arguments
if nargin<6
	T=120;
end
%Extracting Spikes Within Trigger Sequence
if nargin==7
	index=find(spet>Trig(1) & spet<max(Trig));
	spet=spet(index);
	spet=spet-min(spet)+1;
end

%Temporal Resolution
dt=1/Fsd;
L=ceil(1000/Fsd);

%Spike Event Time Array - Removes First T seconds (Default T=30)
index=find(spet>T*Fs);
spet=spet(index);
spet=spet-min(spet)+1;

%Making A Smoothing Window
W=ones(1,L);

%Converting Spet variable to an Impulse Time Series
%Sampled at 1kHz 
X=1/1000*spet2impulse(spet,Fs,1000);
X=conv(X,W);

%Binary Mask - Use Base D so that if there are more than 1 spikes per
%bin this allows extra posibilities for the distribution P(W)
Mask=[];
D=max(X);
for k=1:B
	Mask=[Mask D^(k-1)];
end

%Finding Word Distribution
P=0;
NN=0;
for k=1:length(X)-L*B

	%Finding Words
	Word=X(k+(0:L:L*B-1));

	%Generating Word Histogram
	n=sum(Mask.*Word);
	index=find(NN==n);
	if isempty(index)
		P=[P 1];
		NN=[NN n];
	else
		P(index)=P(index)+1;
	end

	%Computing Information
	if k/N==round(k/N)
		%Normalizing Word Histogram and Computing Enthropy per Word
		PP=P/sum(P);
		index=find(P~=0);
		H(k/N)=-sum(PP(index).*log2(PP(index)));
	end

	%Displaying Output
	if k/5000==round(k/5000)
		clc
		disp(['Percent Done: ' int2str(k/length(X)*100) ' %'])
	end
end

%Mean Spike Rate
Rate=length(spet)/( (max(spet)-min(spet))/Fs );

%Finding Standard Error by Resampling the Distribution 100 times
PP=P/sum(P);
for k=1:length(PP)
	CDF(k)=sum(PP(1:k));
end
CDF=[0 CDF];
for l=1:10

	%Reesampling the Distribution for Half the Samples
	X=rand(1,round(sum(P)/2));
	for k=1:length(CDF)-1
		index=find(X>=CDF(k) & X<CDF(k+1));
		Pr(k)=length(index);
		index=find(X>=CDF(k+1));
		X=X(index);
	end

	%Finding Enthropy Distribution
	%Normalizing Reesampled Word Histogram and Computing Enthropy per Word
	Pr=Pr/sum(Pr);
	index=find(Pr~=0);
	Hr(l)=-sum(Pr(index).*log2(Pr(index)));

	%Dsiplaying Output
	clc
	disp(['Percent Done: ' int2str(l*10) ' %'])

end

%Information Content per spike and per second
HWord=H(length(H))+i*std(Hr)/sqrt(2)
HSec=H(length(H))/dt/B+i*std(Hr)/sqrt(2)/dt/B;
HSpike=HSec/Rate;

