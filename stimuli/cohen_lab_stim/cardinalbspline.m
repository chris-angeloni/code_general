%
%function [B]=cardinalbspline(X,p)
%
%       FILE NAME       : CARDINAL B SPLINE
%       DESCRIPTION     : Generates the p-th order cardinal b-spline
%                         function
%
%       X               : Array from -1 to 1
%       p               : B spline order (number of knots=p+1)
%
%RETURNED VALUES
%       B               : Vector containing the cardinal b-spline fucntion
%                         sampled at the values specified by the vector X
%
%   (C) M. Escabi, Jan 2008
%
function [B]=cardinalbspline(X,p)

%Making X-axis strictly negative
%This is done because the factorials blow up for X>0 whenever p is very
%large. We can do this because the B-spline is symetric for + and - values
%of X
i=find(X>0);
X(i)=-X(i);

%Formula from Chui
B=zeros(size(X));
for k=0:p
    
    B=B+pi*p/factorial(p-1)*(-1)^k* factorial(p)/factorial(p-k)/factorial(k) * max(p/2*(X+1)-k,0).^(p-1);

end