%
%function [HSpike,HSec]=infieth(spet,Fs,Fsd,MaxDT)
%
%
%       FILE NAME       : INF IETH
%       DESCRIPTION     : Spike Train Enthropy computed directly from the
%			  inter-event time probability distribution. This 
%			  method assumes that the spike train is completely 
%			  random and has no serial statistics. This would be
%			  the case for the shuffeled spike train.
%			  Note that the enthropy obtained here is for the
%			  information that results from looking at spike 
%			  train segments of MaxDT. The Enthropy increases 
%			  with increasing MaxDT.
%
%       spet		: Spike Event Times 
%	Fs		: Sampling Rate for 'spet'
%	Fsd		: Sampling rate for generating IET Histogram
%	MaxDT		: Maximum Inter-Event Time for Analysis
%			  Default==1 (sec)
%
%	Trig		: Corresponding Trigger Array
%			  Used to determine the start and end of the stimulus
%			  and the corresponding spikes (Optional)
%	T		: Time to remove at the begining of spike train
%			  to avoid adaptive effects (Default=30 sec)
%
%Returned Variables
%	HSpike		: Enthropy per Spike
%	HSec		: Enthropy per Second
%
function [HSpike,HSec]=infieth(spet,Fs,Fsd,MaxDT,Trig,T)

%Checking Input Arguments
if nargin<4
	MaxDT=1;
end
%Extracting Spikes Within Trigger Sequence
if nargin>=5
	index=find(spet>Trig(1) & spet<max(Trig));
	spet=spet(index);
	spet=spet-min(spet)+1;
end
if nargin<6
	T=30;
end

%Spike Event Time Array - Removes First T seconds (Default T=30)
index=find(spet>T*Fs);
spet=spet(index);
spet=spet-min(spet)+1;

%Computing Inter-Event Time Distribution
[DT,IETH]=iethspike(spet,Fs,Fsd,MaxDT,'n');

%Mean Spike Rate
Rate=length(spet)/(max(spet)-min(spet))*Fs;

%Computing Enthropy
index=find(IETH>0);
HSpike=-sum(IETH(index).*log2(IETH(index)));
HSec=HSpike*Rate;

