% function [c]=CXCORR(a,b,maxlag)
% DESCRIPTION   : circular correlation

% (c) Yi Zheng, March 2007


function [c]=CXCORR(a,b,maxlag)

if nargin<3
    %maxlag = length(a)-1
    maxlag = length(a)-1
end

% bb=b;
% for k=(maxlag+1):(2*maxlag+1)
%     c(k)=a*bb';
%     bb=[bb(end),bb(1:end-1)]; %circular shift
%     % bb=[0,bb(1:end-1)];  %linear shift
% end

% bb=b;
% for k=maxlag:-1:1
%     bb=[bb(2:end),bb(1)]; % circular shift
%     % bb=[bb(2:end),0];   % linear shift
%     c(k)=a*bb';
% end

bb=b;
for k=maxlag:-1:0
    bb=[bb(2:end),bb(1)]; % circular shift
    % bb=[bb(2:end),0];   % linear shift
    c(k+1)=a*bb';
end