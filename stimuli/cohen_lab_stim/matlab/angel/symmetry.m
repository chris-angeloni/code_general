%function  [ASI]=symmetry(x,y); 
%
%Function      
%                   to determine function symmetry
%
%Input
%            x      input
%            y      y=f(x)
%Output
%            ASI    the degree of symmetry of y
%                   if ASI=0, this curve is symmetric
%
% Copyright ANQI QIU
% 03/01/2002


function [ASI]=symmetry(x,y);

x0=sum(x.*y)/sum(y);
ASI=sum((x-x0).^3.*y)/(sum((x-x0).^2.*y)).^1.5;
