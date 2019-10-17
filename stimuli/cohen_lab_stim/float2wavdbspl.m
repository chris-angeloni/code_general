%
%function []=float2wavdbspl(filename,T,Ncopy,Fs,N,M)
%
%	FILE NAME	: FLOAT 2 WAV DB SPL
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  File used for Computing Fano Factor as a Function
%			  of Modulation depth and SPL
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%
%       filename	: Input file name Header
%	T 		: Total Time to spend at a specific MdB
%	Ncopy		: Number of Copies
%			  Sound is repeated Ncopy Times for each
%			  Modulation Depths
%			  Note that each segement at a given MdB is 
%			  T/Ncopy seconds long				
%
%	Fs		: Sampling Rate (Default=44100)
%	N		: Inter Trigger Time 	(Default=32000)
%			  Block Size
%	M		: Segment Length	(Default=128k)
%
function []=float2wavdbspl(filename,T,Ncopy,Fs,N,M)

%Input Arguments
if nargin<4
	Fs=44100;
        N=32000;
        M=1024*128;
elseif nargin<5
	N=32000;
	M=1024*128;
elseif nargin<6
	M=1024*128;
end

%Number of Samples used at Each Modulation Depth
NL=ceil(ceil(T*Fs/32000)/Ncopy)*Ncopy;		%Number of 32000 sample segments used
L=32000*NL;					%Total number of samples used
dL=L/Ncopy;					%Offset Length

%Input File Names
infile1=[filename '30Lin.bin'];
infile2=[filename '15dB.bin'];
infile3=[filename '30dB.bin'];
infile4=[filename '45dB.bin'];
infile5=[filename '60dB.bin'];

%Output File Names
outfile1=[filename '30Lin.float'];
outfile2=[filename '15dB.float'];
outfile3=[filename '30dB.float'];
outfile4=[filename '45dB.float'];
outfile5=[filename '60dB.float'];
outfile11=[filename '30Lin.int'];
outfile22=[filename '15dB.int'];
outfile33=[filename '30dB.int'];
outfile44=[filename '45dB.int'];
outfile55=[filename '60dB.int'];

%Generating Trigger File
trigfile('trig3.int',32000,500,dL,'y');
trigfile('trig2.int',32000,500,dL,'n');
!cp trig3.int trigger1.int
appendfile('trig2.int','trigger2.int',Ncopy*5-1,'int16',1024*128);
append2file('trigger2.int','trigger1.int','int16');
!cp trigger1.int trigger2.int
%!rm trig1.int
%!rm trig2.int

%Generating Sound Segments
for k=1:Ncopy

	%Truncating Files to length T seconds
	truncfile(infile1,[outfile1 num2str(k)],dL*(k-1),dL,1024*128,'float');	
	truncfile(infile2,[outfile2 num2str(k)],dL*(k-1),dL,1024*128,'float');	
	truncfile(infile3,[outfile3 num2str(k)],dL*(k-1),dL,1024*128,'float');	
	truncfile(infile4,[outfile4 num2str(k)],dL*(k-1),dL,1024*128,'float');	
	truncfile(infile5,[outfile5 num2str(k)],dL*(k-1),dL,1024*128,'float');	

	%Converting to 'int16'
	float2int([outfile1 num2str(k)],[outfile11 num2str(k)],1024*128);
	float2int([outfile2 num2str(k)],[outfile22 num2str(k)],1024*128);
	float2int([outfile3 num2str(k)],[outfile33 num2str(k)],1024*128);
	float2int([outfile4 num2str(k)],[outfile44 num2str(k)],1024*128);
	float2int([outfile5 num2str(k)],[outfile55 num2str(k)],1024*128);

	%Flipping The Files 
	flipfile([outfile11 num2str(k)],[outfile11 num2str(k) '.flip'],'int16',1024*128);
	flipfile([outfile22 num2str(k)],[outfile22 num2str(k) '.flip'],'int16',1024*128);
	flipfile([outfile33 num2str(k)],[outfile33 num2str(k) '.flip'],'int16',1024*128);
	flipfile([outfile44 num2str(k)],[outfile44 num2str(k) '.flip'],'int16',1024*128);
	flipfile([outfile55 num2str(k)],[outfile55 num2str(k) '.flip'],'int16',1024*128);

	%Removing Sound Segments
	f=['!rm ' outfile1 num2str(k) ' ' outfile2 num2str(k) ' ' outfile3 num2str(k) ' ' outfile4 num2str(k) ' ' outfile5 num2str(k) ' '];
	eval(f)
end

%Concatenating Sound Segments and Triggers
for k=1:Ncopy

	%Contra Sound
	append2file([outfile33 num2str(k)],'temp.int','int16',1024*128);
	append2file([outfile11 num2str(k)],'temp.int','int16',1024*128);
	append2file([outfile44 num2str(k)],'temp.int','int16',1024*128);
	append2file([outfile22 num2str(k)],'temp.int','int16',1024*128);
	append2file([outfile55 num2str(k)],'temp.int','int16',1024*128);
	
	%Ipsi Sound
	append2file([outfile33 num2str(k) '.flip'],'temp.int.flip','int16',1024*128);
	append2file([outfile11 num2str(k) '.flip'],'temp.int.flip','int16',1024*128);
	append2file([outfile44 num2str(k) '.flip'],'temp.int.flip','int16',1024*128);
	append2file([outfile22 num2str(k) '.flip'],'temp.int.flip','int16',1024*128);
	append2file([outfile55 num2str(k) '.flip'],'temp.int.flip','int16',1024*128);

	%Removing Sound Segments
	f=['!rm ' outfile11 num2str(k) ' ' outfile22 num2str(k) ' ' outfile33 num2str(k) ' ' outfile44 num2str(k) ' ' outfile55 num2str(k) ' '];
	eval(f);
	f=['!rm ' outfile11 num2str(k) '.flip ' outfile22 num2str(k) '.flip ' outfile33 num2str(k) '.flip ' outfile44 num2str(k) '.flip ' outfile55 num2str(k) '.flip '];
	eval(f);

end

%Closing all Files
fclose('all');

%Interlacing all 4 channels
interlace4('temp.int','temp.int.flip','trigger1.int','trigger2.int',[filename 'dBAll.sw'],1024*128);

%Removing Files
%f=['!rm ' file1 ' ' file2 ' ' file3 ' ' file4 ' ' file5];
%eval(f);

%Converting to WAV File
f=['!sox -r ' num2str(Fs,5) ' -c 4 ' filename 'dBAll.sw ' filename 'dBAll.wav' ];
eval(f);

%Removing SW File
f=['!rm ' filename 'dBAll.sw '];
eval(f);

