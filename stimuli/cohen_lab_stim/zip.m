%
%function []=zip(filename,M,ext)
%
%       FILE NAME       : ZIP
%       DESCRIPTION     : Gzips a sequence of files
%
%       filename        : Filename prefix
%       M               : Sequence Array (ie, M=1:128)
%	ext		: File extension
%
function []=zip(filename,M,ext)

ch=setstr(39);

for k=M
	if find(ext=='.')>=1
		f=(['unix(' ch 'gzip ' filename num2str(k) ext ch ')']);
	else
		f=(['unix(' ch 'gzip ' filename num2str(k) '.' ext ch ')']);
	end
	eval(f);
	disp(f);
end



