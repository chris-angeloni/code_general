%function [Image]=dispframes(N1,N2,file)
%
%       FILE NAME       : DISP FRAMES 
%       DESCRIPTION     : Displays the Average of frames N1 to N2
%
%       N1              : Starting Frame Number 
%	N2 		: Ending Frame Number
%       file            : File used for movie
%	Image		: Returned Image
%
function [Image]=dispframes(N1,N2,file)

%Loading Movie Files
for n=N1:N2
        f=['load ',file,'.',num2str(n),'.mat'];
        disp(f);
        eval(f);
        f=['MV',num2str(n),'=I;'];
        eval(f);
end

%Averaging Frames N1 to N2
f=['Image=zeros(size(MV',num2str(N1),'));'];
eval(f);
for n=N1:N2
	f=['Image=MV',num2str(n),'+Image;'];
	eval(f);
end



