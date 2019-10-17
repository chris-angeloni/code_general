function[Rxy]=correl(x,y)
%
%         function[Rxy]=correl(x,y)
%         calculate the correlation coeficient
%         of two vectors -input1 and input2 or 
%         gives the vector of correlation coeficients
%         of the raws of matrix input1 and input2.
%         Note, that input1 must have the
%         same size as input2.

[s1,s2]=size(x);
if s1==1 | s2==1,
 x=x(:);
 y=y(:);
end;
mx1=mean(x);
mx2=mean(x.^2);
my1=mean(y);
my2=mean(y.^2);
Sxx=mx2-mx1.^2;
Syy=my2-my1.^2;
Sxy=mean(x.*y)-mx1.*my1;
Rxy=Sxy./sqrt(Sxx.*Syy);
