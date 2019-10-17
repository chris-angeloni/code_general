%
%function []=batchjitter(channel,MaxTau,Fsd)
%
%       FILE NAME       : BATCH JITTER
%       DESCRIPTION     : Estimates the jitter autocorrlation from a two-trial
%			  stimulus repeat. Saves to file (header=JITTER)
%
%	channel		: Desired data channel for analysis
%	MaxTau		: Maximum Correlation Delay (sec)
%	Fsd		: Desired Sampling Rate
%
function []=batchjitter(channel,MaxTau,Fsd)

List=dir(['*ch' int2str(channel) '.mat']);

for k=1:length(List)

	%Loading Files
	clear TrigA TrigB Trig TrigTimes
	f=['load ' List(k).name];
	eval(f)
	TrigFile=List(k).name;
	i=findstr(TrigFile,'.mat');
	TrigFile=[TrigFile(1:i-5) '_Trig.mat'];
	if exist(TrigFile)==2
		f=['load ' TrigFile];
		eval(f)
	end

if exist('TrigA')
	%Finding All Non-Outlier Spet Variables
	count=-1;
	while exist(['spet' int2str(count+1)])
	        count=count+1;
	end
	Nspet=(count+1)/2;
	
	for l=0:Nspet-1

		%Display
		SpikeFile=List(k).name;
		i=findstr(SpikeFile,'.mat');
		SpikeFile=[SpikeFile(1:i-1) '_u' int2str(l)];
		clc
		disp(['Finding Jitter Correlation: ' SpikeFile])
	
		%Finding Spike ISI arrays
                f=['spet=spet' int2str(l) ';'];
                eval(f);
		[spetA,spetB,T]=trig2spet(TrigA,TrigB,spet,Fs);

		if length(spetA)>10 & length(spetB)>10	%At least 10 spikes	
			%Computing Jitter Correlation	
			[Tau,Raa,Rab,Rpp,Rmodel,sigma,p,lambda]=...
			jittercorrfit(spetA,spetB,Fs,Fsd,T,MaxTau);

			%Saving to file
			f=['save ' SpikeFile ...
			'_JITTER Tau Raa Rab Rpp Rmodel sigma p lambda'];
			eval(f)
		end
	end
end

end
