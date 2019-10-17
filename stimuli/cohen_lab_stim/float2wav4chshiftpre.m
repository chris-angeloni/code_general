%function []=float2wav4chshiftpre(infile,outfile,Fs,L,N,M)
%
%	FILE NAME	: FLOAT 2 WAV 4 CH SHIFT PRE
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  File with the following properties:
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%
%       infile		: Input file name
%	outfile		: Output file name 
%	Fs		: Sampling Rate (Default=44100)
%	L		: Number of Blocks in Between Double Triggers
%			  (Default=400)
%	N		: Inter Trigger Time	(Default=32000)
%	M		: Segment Length	(Default=128k)
%
function []=float2wav4chshiftpre(infile,outfile,Fs,L,N,M)

%Input Arguments
if nargin<3
	Fs=44100;
	L=400;
        N=32000;
        M=1024*128;
elseif nargin<4
	L=400;
	N=32000;
	M=1024*128;
elseif nargin<5
	N=32000;
	M=1024*128
elseif nargin<6
	M=1024*128;
end

%Finding File Names
index=findstr('.',outfile);
file1=[outfile(1:index-1) '.int'];
file2=[outfile(1:index-1) '2.int'];
file3='trig1.int';
file4='trig2.int';
file5=[outfile(1:index-1) '1.sw'];
file6=[outfile(1:index-1) '2.sw'];
file7=[outfile(1:index-1) '3.sw'];

%Converting Sound to int16 and Flipping from Left to Right
float2int(infile,file1,M);
flipfile(file1,file2,'int16',M);

%Finding the Input File length
FileL=0;
fid=fopen(infile);
while ~feof(fid)
	X=fread(fid,1024*128,'float');
	FileL=length(X)+FileL;
end
fclose(fid);

%Generating Trigger Files
trigfile(file3,N,L,FileL);
f=['!cp ' file3 ' ' file4];
eval(f)

%Interlacing all 4 channels
interlace4(file1,file2,file3,file4,file5,M);

%Removing Files
f=['!rm ' file1 ' ' file2 ' ' file3 ' ' file4];
eval(f);

%Concatenating File Twice
f=['!cp ' file5 ' ' file6];
eval(f)
catfile(file5,file6,file7,'int16',1024*256);

%Converting to WAV File
f=['!sox -r ' num2str(Fs) ' -c 4 ' file7 ' ' outfile];
eval(f);

%Removing SW File
f=['!rm ' file5 ' ' file6 ' ' file7];
eval(f);

