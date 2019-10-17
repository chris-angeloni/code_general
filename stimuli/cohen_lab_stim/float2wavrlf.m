%
%function []=float2wavrlf(infile,SPL,T,Ncopy,Fs,N,M)
%
%	FILE NAME	: FLOAT 2 WAV RLF
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  File used for Computing Rate Level Function
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%
%       infile		: Input 'bin' file name
%	T 		: Total Time to spend at a specific Intensity
%	SPL		: Sound Preassure Level Array
%	Ncopy		: Number of Copies
%			  Sound is repeated Ncopy Times for each
%			  Intensity
%			  Note that each segement at a given Intensity is 
%			  T/Ncopy seconds long				
%
%	Fs		: Sampling Rate (Default=44100)
%	N		: Inter Trigger Time 	(Default=32000)
%			  Block Size
%	M		: Segment Length	(Default=128k)
%
function []=float2wavrlf(infile,SPL,T,Ncopy,Fs,N,M)

%Input Arguments
if nargin<5
	Fs=44100;
        N=32000;
        M=1024*128;
elseif nargin<6
	N=32000;
	M=1024*128;
elseif nargin<7
	M=1024*128;
end

%Number of Samples used at Each Intensity
NL=floor(floor(T*Fs/32000)/Ncopy)*Ncopy;	%Number of 32000 sample segments used for each Intensity
L=32000*NL;					%Total number of samples used
dL=L/Ncopy;					%Offset Length -Number of samples for each continuous segments

%Generating Trigger File
trigfile('trig3.int',32000,500,dL,'y');
trigfile('trig2.int',32000,500,dL,'n');
!cp trig3.int trigger1.int
appendfile('trig2.int','trigger2.int',Ncopy*length(SPL)-1,'int16',1024*128);
append2file('trigger2.int','trigger1.int','int16');
!cp trigger1.int trigger2.int

%Ouput File Name 
index=findstr(infile,'.bin');
outfile=[infile(1:index-1)];

%Generating Sound Segments
for k=1:Ncopy
	
	%Truncating Files to length T seconds
	truncfile(infile,[outfile '.float' num2str(k)],dL*(k-1),dL,1024*128,'float');

	%Converting to 'int16'
	float2int([outfile '.float' num2str(k)],[outfile '.' num2str(k) '.sw'],1024*128);

	%Flipping The Files 
	flipfile([outfile '.' num2str(k) '.sw'],[outfile '.' num2str(k) '.flip.sw'],'int16',1024*128);

	%Removing Sound Segments
	f=['!rm ' outfile '.float' num2str(k)];
	eval(f);
end

%Concatenating Sound Segments and Triggers
for k=1:Ncopy
	for l=1:length(SPL)

		%Attenuating Contra Sound
		attfile([outfile '.' num2str(k) '.sw'],'temp.att.sw',SPL(l),'int16')
		append2file('temp.att.sw','temp.sw','int16',1024*128);
	
		%Attenuating Ipsi Sound
		attfile([outfile '.' num2str(k) '.flip.sw'],'temp.att.flip.sw',SPL(l),'int16')
		append2file('temp.att.flip.sw','temp.flip.sw','int16',1024*128);

	end
end

%Closing all Files
fclose('all');

%Interlacing all 4 channels
interlace4('temp.sw','temp.flip.sw','trigger1.int','trigger2.int',[outfile 'SPLRLF.sw'],1024*128);

%Removing Files
%f=['!rm ' file1 ' ' file2 ' ' file3 ' ' file4 ' ' file5];
%eval(f);

%Converting to WAV File
f=['!sox -r ' num2str(Fs,5) ' -c 4 ' outfile 'SPLRLF.sw ' outfile 'SPLRLF.wav' ];
eval(f);

%Removing SW File
f=['!rm *.sw *int'];
eval(f);

