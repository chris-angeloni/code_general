%
%function []=unzip(filename,M,ext)
%
%       FILE NAME       : UNZIP
%       DESCRIPTION     : Gunzips a sequence of files
%
%       filename        : Filename prefix
%       M               : Sequence Array (ie, M=1:128)
%	ext		: File extension
%
function []=unzip(filename,M,ext)

ch=setstr(39);

for k=M
if find(ext=='.')>=1
		f=(['unix(' ch 'gunzip ' filename num2str(k) ext ch ')']);
	else
		f=(['unix(' ch 'gunzip ' filename num2str(k) '.' ext ch ')']);
	end
	f=(['unix(' ch 'gunzip ' filename num2str(k) ext ch ')']);
	eval(f);
	disp(f);
end



