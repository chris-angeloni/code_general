%
%function []=dbvssplfile(filename,Fsd,Fsdx,SPL,Ncopy,T,ZeroBin)
%
%       FILE NAME       : DB VS SPL FILE
%       DESCRIPTION     : Generates a dB vs SPL Response Curve and
%			  X-Correlation Matrix 
%			  Saves data to file using DBVSSPL and 
%			  DBVSSPLXCORR
%	
%	filename	: Input SPET File Name
%	Fsd		: Sampling rate for dB vs. SPL Mean and Var  Analysis
%	Fsdx		: Sampling Rate For dB vs. SPL X-Correlation 
%	SPL		: Array of SPL Used During Experiment
%	Ncopy		: Number of Copies used in 'float2wavdbvsspl'
%	T		: Maximum Temporal Lag for Xcorrelation (sec)
%	ZeroBin		: Fix Zeroth Bin for dB vs. SPL X-Correlation
%			  Default : 'n'
%
function []=dbvssplfile(filename,Fsd,Fsdx,SPL,Ncopy,T,ZeroBin)

%Input Arguments
if nargin<7
	ZeroBin='n';
end

%Adding MAT Suffix
if isempty(findstr('.mat',filename))
	filename=[filename '.mat'];
end

%Loading SPET and TRIG File
f=['load ' filename];
eval(f);
index=findstr('ch',filename);
f=['load ' filename(1:index-1) 'Trig.mat'];
eval(f);

%Finding All Non-Outlier spet
count=-1;
while exist(['spet' int2str(count+1)])
	count=count+1;
end
Nspet=(count+1)/2;

%Finding Double and Tripple Triggers
[Trig2,Trig3]=trigfixdbvsspl(TrigTimes,Fs);

%Computing dB vs. SPL Response Curves
index=findstr('.mat',filename);
for k=0:Nspet-1

	%Computing dB vs. SPL Response Curve
	f=['spet=spet' int2str(k) ';'];
	eval(f);
	[dBAxis,SPLAxis,Xcorr]=dbvssplxcorr(spet,Trig2,Trig3,SPL,Fs,Fsdx,Ncopy,T,ZeroBin,'n');
	[dBAxis,SPLAxis,Var,Mean]=dbvsspl(spet,Trig2,Trig3,SPL,Fs,Fsd,Ncopy,'n');
	N=length(spet);

	%Saving dBSPL File
	Command=['save ' filename(1:index-1) '_u' int2str(k) '_dBSPL '];
	Command=[Command ' dBAxis SPLAxis Var Mean Xcorr Fsd Fsdx N'];
	if ~strcmp(version,'4.2c')
		Command=[Command ' -v4'];
	end
	eval(Command);

	%Clearing Unecessary Variables
	f=['clear dbAxis SPLAxis Var Mean spet spet' int2str(k)];
	eval(f)

end
