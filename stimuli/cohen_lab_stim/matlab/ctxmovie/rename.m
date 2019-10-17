%function []=rename(fileold,filenew,N)
%
%	FILE NAME 	: RENAME 
%	DESCRIPTION 	: Renames an movie sequence
%
%	N		: Number of Frames
%	fileold		: Old filename
%	filenew		: New Filename
%
function []=rename(fileold,filenew,N)

for i=1:N
	f=['load ',fileold,'.',num2str(i),'.mat;'];
	disp(f);
	eval(f);

	f=['save ',filenew,'.',num2str(i),'.mat;'];
	disp(f)
	eval(f);

%	f=['clear ',fileold,'.',num2str(i),'.mat;'];
%	disp(f);
%	eval(f);
end
