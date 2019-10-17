%function []=float2int(infile,outfile,M,MACHINE)
%
%       FILE NAME       : FLOAT 2 INT
%       DESCRIPTION     : Converts a binary 'float' file to binary 'int16'
%
%   infile      : Input file name
%	outfile     : Output file name 
%	M           : Segment Length
%   MACHINE     : Machine format for 'float', Default='n', Native
%                 see FREAD for additional information
%
function []=float2int(infile,outfile,M,MACHINE)

%Input Arguments
if nargin<4
    MACHINE='n';
end

%Opening Files
fidin=fopen(infile,'r');
fidout=fopen(outfile,'w');

%Finding Max for Normalizing
Max=-1E10;
while ~feof(fidin)
	X=fread(fidin,M,'float',0,MACHINE);
	Max=max([ Max abs(X')]);
end

%Converting to 'int16'
fseek(fidin,0,-1);
while ~feof(fidin)
	X=fread(fidin,M,'float',0,'l');
	X=round(X/Max*1024*32*.99);
	fwrite(fidout,X,'int16');
end

%Closing Files
fclose('all');
