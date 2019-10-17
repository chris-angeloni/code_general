% DESCRIPTION: bootstrap polynomial P(X)

% Yi Zheng, Dec 2007, 

function [m,se]=bootcorr(data1,data2,NB)

for l=1:NB
  j = randsample(length(data1),length(data1),'true');
  ranka=tiedrank(data1(j));
  rankb=tiedrank(data2(j));
  [RHO,PVAL] = CORR(ranka',rankb','type','Spearman')
  boot(l) = RHO;
end

se=std(boot);
m=mean(boot);
  