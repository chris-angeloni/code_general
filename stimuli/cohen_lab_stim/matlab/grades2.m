% function [Grade] = grades2(X)
%
%	FILE NAME       : GRADE
%	DESCRIPTION     : Converts a grade distribution to Normal with Mean
%			  and Std based on a rank order procedure
%
%	X		: Input grades (0-100)
%	Mean		: Desired Mean (0-100)
%	Std		: Desired Std  (0-100)
%	warp		: Warps the destribution as desired 
%			  Takes numbers < 1 but is usually ~=0.9 - 1.0
%
%OUTPUT VARIABLES
%
%	Grades		: Overall Grade (A+, A, A-, B+, ...) 
%
function [Grade]=grades2(X)

%Plotting Statistics

hist(X,15)
Max=max(hist(X,15));
axis([-5 105 0 Max*1.3])
xlabel('Raw Score')
title(['Mean = ' num2str(mean(X),2) ', SD = ' num2str(std(X))])

%Finding Grade
N=length(X);
YY=X;
Grade='  ';
for k=1:N
	if YY(k)<60
		Grade(k,1)='F';	
	elseif YY(k)<70 & YY(k)>=60
		Grade(k,1)='D';	
	elseif YY(k)<80 & YY(k)>=70
		Grade(k,1)='C';	
	elseif YY(k)<90 & YY(k)>=80
		Grade(k,1)='B';	
	elseif YY(k)>=90
		Grade(k,1)='A';	
	end

	if Grade(k,1)~='F' & YY(k)<97
		Residual=YY(k)-floor(YY(k)/10)*10;
		if Residual<3
			Grade(k,2)='-';
		elseif Residual>=7
			Grade(k,2)='+';
		end
	end
end
