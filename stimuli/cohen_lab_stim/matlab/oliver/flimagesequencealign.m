%
%function [] = flimageplot(filename1,filename2)
%	
%	FILE NAME       : FL IMAGE PLOT
%	DESCRIPTION 	: Plots a florescent Image
%
%   filename1       : Green Channel Image
%   filename2       : Red Channel Image
%
%RETURNED VARIABLES
%
%   X               : Image in RGB format
%
% (C) Monty A. Escabi, April 2007
%
function [] = flimagesequencealign(filename1,filename2)

%Searching for all files with header
index=findstr(filename1,'No');
Header=filename1(1:index-1);


FITCList=dir([Header '*FITC*']);
RhList=dir([Header '*Rh*'])