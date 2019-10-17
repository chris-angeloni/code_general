%function []=wav2toint1(infile,Flag)
%
%       FILE NAME       : WAV 2 TO INT 1
%       DESCRIPTION     : Averages the channels of a two channel 'wav'
%			  sound file to a one channel binary 'int16' 
%			  Output file is given infile name with extension
%			  '.sw'
%
%       infile		: Input file name
%	Flag		: Pick a channel to extract or average over
%			  2 channels
%			  Options:  'left', 'right', or 'Avg'
%			  Default:  'Avg'
%
function []=wav2toint1(infile,Flag)

%Input Arguments
if nargin<2
	Flag='Avg';
end

%Output File Name
index=findstr('.wav',infile);
outfile=[infile(1:index-1) '.sw'];

%Running Sox
if strcmp(Flag,'left')
	f=['!sox -c 2 ' infile ' -c 1 ' outfile ' pick -l'];
elseif strcmp(Flag,'right')
	f=['!sox -c 2 ' infile ' -c 1 ' outfile ' pick -r'];
elseif strcmp(Flag,'Avg')
	f=['!sox -c 2 ' infile ' -c 1 ' outfile];
end
eval(f);
