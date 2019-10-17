% DESCRIPTION: bootstrap polynomial P(X)

% R.slopboot      : slop
% R.interceptboot : intercept
% Yi Zheng, Dec 2007, 

function [R]=bootpolynomial(data1,data2,NB)

for l=1:NB
  j = randsample(length(data1),length(data1),'true');
  r=polyfit(data1(j),data2(j),1);
  R.slopboot(l) = r(1);
  R.interceptboot(l) = r(2);
end
  