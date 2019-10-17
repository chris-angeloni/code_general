function y = logist(x, P);
% function logist(x, P);
% computes a logistic function:
%
%                    1           
% y = p1 * ( ------------------- )
%             1+exp(-p2*(x-p3))   
%
% p1:    asymptotic maximum value
% p2:    maximum slope
% p3:    location of inflection point

y = P(1) ./ (1+exp(-P(2)*(x-P(3))));

return
