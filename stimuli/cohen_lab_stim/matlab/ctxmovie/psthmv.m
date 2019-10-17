%function [] = psthmv(fileId,scriptfile,outfile,sequence,var,M)
%
%	FILE NAME 	: PSTH MV 
%	DESCRIPTION 	: Generates a PSTH Movie
%
%	fileId		: File Identifier (Prefix for Infile) - including path
%	scriptfile	: Script File - including path
%	outfile		: Prefix for Output File - including path
%	sequence	: Sequence Number
%	var		: HHH file Variation Number
%	M		: Number of Movie Frames
%
function [] = psthmv(fileId,scriptfile,outfile,sequence,var,M)

%Getting Script data for desired sequence
scrdat=scrdata(scriptfile,sequence);

%Getting Movie Data
mvdata=getpsth(fileId,scrdat,sequence,var);

%Interpolating Frames
mvinterp(mvdata,outfile,M);
