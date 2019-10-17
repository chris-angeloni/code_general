%
%function []=batchampdist(M)
%
%	FILE NAME 	: BATCH AMP DIST
%	DESCRIPTION 	: Batch for Emperically estimating the Linear and dB
%			  amplitude distributions of a 16 bit sampled 
%			  waveform ( .sw )
%
%	M		: Block Size used to extimate std and mean
%			  trajectories (number of samples). Note that
%			  this corresponds to a sampling of these 
%			  trajectories at a rate of Fs/M where Fs is
%			  the sampling rate of the ".sw" file
%
function []=batchampdist(M)

%Preliminaries
more off

%Generating a File List
f=['ls *.sw' ];
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
	for k=1:30
		if k+returnindex(l)<returnindex(l+1)
			Lst(l,k)=List(returnindex(l)+k);
		else
			Lst(l,k)=setstr(32);
		end
	end
end

%Batching Ampdist
for k=1:size(Lst,1)
	index=findstr(Lst(k,:),'.sw');
	filename=[ Lst(k,1:index-1) '.sw'];
	if exist(filename)

		%Evaluating Amp Dist and Saving
		[Amp,P,AmpdB,PdB,Taxis,StdLin,StddB,MeandB]=ampdist(filename,...
			M,'n');
		f=['save ' Lst(k,1:index-1) , ...
		'_AmpDist M Amp P AmpdB PdB Taxis StdLin StddB MeandB'];
		disp(f);
		eval(f);

	end
end
