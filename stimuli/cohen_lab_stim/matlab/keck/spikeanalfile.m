%
%function []=spikeanalfile(filename,Fsd,T,TC,df,p,T1,T2,L,Disp)
%
%       FILE NAME       : SPIKE ANAL FILE
%       DESCRIPTION     : Computes the X-Correlation , Fano Factor, and PSD, IETH of
%			  a File
%
%	filename	: Input SPET File Name
%	Fsd		: Sampling Rate for R(T), PSD(W), FF(T), and IETH
%	T		: X-Correlation Temporal Lag (sec) and Time for IETH
%	TC		: Post Spike Conditioned Spike Histogram Time Width ( sec )
%	df		: Frequency Resolution for PSD
%	p		: Significance Probability for PSD
%	T1		: Smallest Fano Factor counting window size (sec)
%			  Note: T1 >= 1/Fsd
%	T2		: Maximum Fano Factor counting window size (sec)
%	L		: Number of Fano Factor Samples
%	Disp		: Display : Optional : Default = 'n'
%
function []=spikeanalfile(filename,Fsd,T,TC,df,p,T1,T2,L,Disp)

%Checking Input Arguments
if nargin<10
	Disp='n';
end

%Loading File
f=['load ' filename];
eval(f);

%Finding Number of Non-Outlier SPET Variables
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

%Saving Variables
GlobalVariables=[' Fsd T df T1 T2 p L TC'];
Variables=[];
	
%Running PSD, XCORR, FANO on all non-outlier spet data
for m=0:Nspet-1

	%Re-asigning 'spet' as generic variable
	f=['spet=spet' int2str(m) ';'];
	eval(f);

	%Computing Only if > 50 Spikes
	if length(spet)>50
		%Output Display
		clc
		disp(['Analyzing ' filename] )

		%Evaluating PSD, FF, XCORR
		f=['R=xcovspikeb(spet,spet,Fs,Fsd,T,256,Disp);'];
		eval(f);
		pause(0);

		f=['[DT,IETH]=iethspike(spet,Fs,Fsd,T,Disp);'];
		eval(f)
		pause(0);
		f=['[Faxis,PSD,PSDC]=psdspike(spet,Fs,Fsd,df,p,.5,Disp);'];
		eval(f);
		pause(0);
		f=['[TT,FF]=fanospike(spet,T1,T2,L,Fs,Fsd,Disp);'];
		eval(f);
		pause(0);
		f=['[TaxisC,CHist]=condspike(spet,Fs,Fsd,TC,Disp);'];
		eval(f)
		pause(0)

		%Finding Number of Spikes
		f=['No=' int2str(length(spet)) ';'];
		eval(f)

		%Saving Variables
		index=findstr(filename,'.mat');
		Variables=[' No R Faxis PSD PSDC TT FF DT IETH TaxisC CHist '];
		clc
		disp(['Saving ' filename(1:index-1) '_u' int2str(m) '_SpkA.mat'] )
		if strcmp(version,'4.2c')
			eval(['save ' filename(1:index-1) '_u' int2str(m) '_SpkA ' Variables GlobalVariables])
		else
			eval(['save ' filename(1:index-1) '_u' int2str(m) '_SpkA ' Variables GlobalVariables ' -v4']);
		end

	end

	%Clearing Variables
	eval(['clear spet spet' int2str(m)  Variables])

end
