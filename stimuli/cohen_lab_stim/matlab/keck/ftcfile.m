%
%function [] = ftcfile(dtcfile,spetfile,MinT,MaxT,att)
%
%	FILE NAME 	: FTC FILE
%	DESCRIPTION 	: Creates a Frequency Tunning Curve and Saves to File
%
%	dtcfile		: DTC File
%	spetfile	: Spike Sorted Spet File
%	MinT		: Minimum delay to measure FTC response (msec)
%	MaxT		: Maximum delay to measure FTC response (msec)
%	att		: External attenuation setting
%
function [] = ftcfile(dtcfile,spetfile,MinT,MaxT,att)

%Loading Trigger and Spet Files
f=['load ' spetfile];
eval(f);
i=findstr(spetfile,'_ch');
trigfile=[spetfile(1:i-1) '_Trig.mat'];
f=['load ' trigfile];
eval(f);

%Finding All Non-Outlier spet
count=-1;
while exist(['spet' int2str(count+1)]) 
	count=count+1;
end
Nspet=(count+1)/2;
              
%Creating Frequency-Tunning Curves
for k=0:Nspet-1

	%Generating Frequency Tunning Curve
	f=['spet=spet' int2str(k) ';'];
	eval(f);
	[faxis,spl,FTC] = ftcresponse(dtcfile,Trig,spet,Fs,MinT,MaxT,att);

	plotftc(faxis,spl,FTC,5,MaxT-MinT);
	pause(0)

	%Saving Frequency Tunning Curve File
	i=findstr(spetfile,'_ch');
	outfile=[spetfile(1:i+3) '_u' num2str(k) '_FTC'];
	f=['save ' outfile ' faxis spl FTC'];
	eval(f)

end
