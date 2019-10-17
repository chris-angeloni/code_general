% function [Y,Grade] = grade(X,Mean,Std,warp)
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
%	Y		: Normally Distributed Numerical Grades
%	Grades		: Overall Grade (A+, A, A-, B+, ...) 
%
function [Y,Grade]=grades(X,Mean,Std,warp)

%Converting Grade Distribution to Normal(Mean,Std) 
%Based on Rank Order Procedure
N=length(X);
X=X+rand(size(X))*.001;
Y1=sort(X);
Y2=(0:N-1)'/(N-1);
Y3=erfinv(Y2*2*warp-warp);
Y4=Y3/std(Y3)*Std+Mean;

%Reassigning Grade Based on Rank Order
for k=1:N
	i=find(X==Y1(k));
	Y(i)=Y4(k);
end

%Plotting Statistics
subplot(221)
hist(X,15)
Max=max(hist(X,15));
axis([-5 105 0 Max*1.3])
xlabel('Raw Score')
title('Raw Score Distribution')

subplot(223)
plot(X,Y,'r.')
xlabel('Raw Score')
ylabel('Curved Grade')

subplot(224)
hist(Y,15)
Max=max(hist(Y,15));
axis([-5 105 0 Max*1.3])
xlabel('Curved Score')
title('Grade Distribution')

%Finding Grade
YY=round(Y);
YY=Y;
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
