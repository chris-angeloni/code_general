%function []=float2wav4chmod(infile,modfile,outfile,Fs,L,N,M)
%
%	FILE NAME	: FLOAT 2 WAV 4 CH MOD
%       DESCRIPTION     : Converts a binary 'float' file to a 4 channel wav
%			  And it coherrently modulates both channels with
%			  the signal in modfile ('float' format)
%			  File with the following properties:
%			  ch1:  Sound
%			  ch2:  Sound inverted in time
%			  ch3:  Trigger
%			  ch4:  Trigger
%	
%			  Both infile and modfile must have the signals 
%			  in 'float' format
%
%       infile		: Input file name
%	modfile		: 2nd Order Envelope Modulation File
%	outfile		: Output file name 
%	Fs		: Sampling Rate (Default=44100)
%	L		: Number of Blocks in Between Double Triggers
%			  (Default=400)
%	N		: Inter Trigger Time	(Default=32000)
%	M		: Segment Length	(Default=128k)
%
function []=float2wav4chmod(infile,modfile,outfile,Fs,L,N,M)

%Input Arguments
if nargin<4
	Fs=44100;
	L=400;
        N=32000;
        M=1024*128;
elseif nargin<5
	L=400;
	N=32000;
	M=1024*128;
elseif nargin<6
	N=32000;
	M=1024*128
elseif nargin<7
	M=1024*128;
end

%Finding File Names
index=findstr('.',outfile);
infileflip=[infile '.flip'];
infilemod=[infile '.mod'];
infileflipmod=[infile 'flip.mod'];
file1=[outfile(1:index-1) '.int'];
file2=[outfile(1:index-1) '2.int'];
file3='trig1.int';
file4='trig2.int';
file5=[outfile(1:index-1) '.sw'];

%Flipping from Left to Right
flipfile(infile,infileflip,'float',M);

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

%Adding Second Order Modulation Envelope to Sound
addmod(infile,modfile,infilemod)
addmod(infileflip,modfile,infileflipmod)

%Converting Sound to int16 and Flipping from Left to Right
float2int(infilemod,file1,M);
float2int(infileflipmod,file2,M);

%Interlacing all 4 channels
interlace4(file1,file2,file3,file4,file5,M);

%Removing Files
f=['!rm ' file1 ' ' file2 ' ' file3 ' ' file4 ' ' infilemod ' ' infileflip ' ' infileflipmod];
eval(f);

%Converting to WAV File
f=['!sox -r ' num2str(Fs) ' -c 4 ' file5 ' ' outfile];
eval(f);

%Removing SW File
f=['!rm ' file5];
eval(f);

