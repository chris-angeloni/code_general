%
%function []=synapticraddyfile2(header,outfile)
%
%       FILE NAME       : SYNAPTIC RADDY FILE
%       DESCRIPTION     : Synaptic Noise Current Signal Generator used by 
%			  Raddy Ramos to test the input-output properties of 
%			  a collection of neurons from a large enseble. Takes
%			  files generated from BATCHSYNAPTICRADDY and generates
%			  a single WAV sound file.
%
%			  Searches only for one synaptic input condition and
%			  appends all files into a WAV file
%
%	header		: Header for input and output files
%	outfile		: Output File Name (no extension)
%	NEv		: Number of variable excitatory presynaptic neurons
%	NIv		: Number of variable inhibitory presynaptic neurons
%	NEf		: Number of fixed excitatory presynaptic neurons
%	NIf		: Number of fixed inhibitory presynaptic neurons

%RETURNED VARIABLES
%
function []=synapticraddyfile2(header,outfile,NEv,NIv,NEf,NIf)

%Finding Files
NEv=int2strconvert(NEv,3);
NIv=int2strconvert(NIv,3);
NEf=int2strconvert(NEf,3);
NIf=int2strconvert(NIf,3);
File.List=dir(['*' header '*NEv' NEv '_NIv' NIv  '_NEf' NEf '_NIf' NIf '*']);

%Finding Maximum Amplitude from All Files
N=size(File.List,1);
Max=-9999;
for k=1:N
	%Loading files
	f=['load ' File.List(k).name];
	eval(f)

	%Finding Max
	Max=max([Max abs(SynapticNoise)]);
end

%Opening Output Files
fid=fopen([outfile '.sw'],'wb');

%Appending Signals
Trigger=31000*[ones(1,1000) zeros(1,1000)];
for k=1:N
	
	%Display
	disp(['Appending File: ' File.List(k).name])

	%Loading files
	f=['load ' File.List(k).name];
	eval(f)

	%250 msec Quiet Period 
	L=round(0.25 * Inputs.Fs);
	S=zeros(1,L);

	%Generating Signal and Interleaving Triggers
	X=round(0.98*1024*32/Max*[SynapticNoise S]);
	Trig=zeros(1,length(X));
	if k/10~=round(k/10) & k~=1
		Trig(1:2000)=Trigger;
	else
		Trig(1:4000)=[Trigger Trigger];
	end
	Y(1:2:length(X)*2)=X;
	Y(2:2:length(X)*2)=Trig;

	%Appending Signal to Output File
	fwrite(fid,Y,'int16');

end

%Appending the Maximum amplitude to File List Information
File.Max=Max;

%Closing All Opened Files
fclose('all');

%Converting SW file to WAV file
f=['!sox -r ' num2str(Inputs.Fs) ' -c 2 ' outfile '.sw ' outfile '.wav'];
eval(f) 
