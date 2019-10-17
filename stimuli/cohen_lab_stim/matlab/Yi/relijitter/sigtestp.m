function [SIG]=sigtestp(Mu1,Mu2,Sigma1,Sigma2,alpha,FMAxis)

for FMi=1:length(FMAxis)
  [SIG(FMi)]=sigztest(Mu1(FMi),Sigma1(FMi),Mu2(FMi),Sigma2(FMi),alpha)
end