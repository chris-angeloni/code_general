%
%function [STRFData16] = strfreorder16(STRFData16,Order)
%
%   FILE NAME 	: STRF RE ORDER 16
%   DESCRIPTION : Orders the 16 channel STRF data structure 
%
%   STRFData16    : Sixteen channel STRF data structure
%   Order         : Desired array ordering (Default assigment if not
%                   supplied)
%
% RETURNED DATA
%
%   STRFData16    : Reordered sixteen channel STRF data structure
%
%   (C) Monty A. Escabi, Dec 2005
%
function [STRFData16] = strfreorder16(STRFData16,Order)

%Input Argumens
if nargin<2
    Order=[9 8 10 7 13 4 12 5 15 2 16 1 14 3 11 6];  
end

%Reordering STRFs
for k=1:16
    STRFData16temp(k)=STRFData16(Order(k));
end
STRFData16=STRFData16temp;