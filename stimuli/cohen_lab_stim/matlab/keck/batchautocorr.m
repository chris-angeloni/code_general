%
%function []=batchautocorr()
%
%       FILE NAME       : BATCH AUTOCORR
%       DESCRIPTION     : Computes the spike train autocorrelations for all 
%			  Units and saves to file. Saved with header='AUTOCORR'
%
%	channel		: Desired data channel for analysis
%
function []=batchautocorr(channel,T,Fsd)

List=dir(['*ch' int2str(channel) '.mat']);

for k=1:length(List)

	%Loading Files
	f=['load ' List(k).name];
	eval(f)

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
		disp(['Finding Corrlation: ' SpikeFile])
	
		%Finding Spike ISI arrays
                f=['spet=spet' int2str(l) ';'];
                eval(f);

		if length(spet>25)	%At least 25 spikes	
			%Computing Autocorrelation	
			[R]=xcorrspike(spet,spet,Fs,Fsd,T,'n','n','n');
        	        N=(length(R)-1)/2;
        	        Tau=(-N:N)/Fsd;

			%Saving to file
			f=['save ' SpikeFile '_AUTOCORR Tau R'];
			eval(f)
		end
	end

end
