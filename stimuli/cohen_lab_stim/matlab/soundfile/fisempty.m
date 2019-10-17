%
%function [Flag]=fisempty(infile)
%
%
%       FILE NAME       : F IS EMPTY
%       DESCRIPTION     : Checks to see if a file is empty
%
%       infile          : Input File Name
%	Flag		: Returned Variable
%			  File is empty     == 1
%			  File is not empty == 0
%
function [Flag]=fisempty(infile)

%Opening File
fid=fopen(infile);

%Reading A Short Segment
X=fread(fid,1,'char');

%Checking to see if X is empty
Flag=isempty(X);

%Closing File
fclose(fid);
