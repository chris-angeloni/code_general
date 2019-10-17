function [Sig p]=sigtest(MTFtrue,MTFrand,alpha)

for i=1:length(MTFtrue)
realdata = MTFtrue(1,i).rjack;
refdata = MTFrand(1,i).rjack;
[Sig(i) p(i)]=ttest2(realdata,refdata,alpha);
% Sig(i)=ztest(realdata,mean(refdata),std(refdata),alpha);
end
