function y = bilogist(x, P);
%function y = bilogist(x, [p1 p2 p3 p4 p5])
%
% computes the difference of two logistic functions (kind of):
%
%                    1                          1           
% y = p1 * ( -------------------  -  ----------------------- )
%             1+exp(-p2*(x-p3))       1+exp(p4*(x-(p3+p5)))  
%
% p1:    asymptotic maximum value
% p2,p4: maximum slopes  (e.g., 4 and -4)
% p3:    location of lesser inflection point
% p5:    separation between inflection points

y = logist(x, P(1:3)) - logist(x, [P(1) -P(4) P(3)+P(5)]);

return

y = P(1) * ...
    (1 ./ (1+exp(-P(2)*(x-P(3)))) - ...
     1 ./ (1+exp( P(4)*(x-(P(3)+P(5))))));

