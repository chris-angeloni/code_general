function F=gaussfun2(BETA,X)
  % Input Parameters: X
  % Model Parameters: beta
  
  sigma=BETA(1);
  p=BETA(2);
  
  lambdaTot=X.lambdatot;
  lambdaI=X.lambdai;
  Tau=X.Tau;
  T=X.T;
  Fsd=X.Fsd;
  
  lambdaN=lambdaTot-p*lambdaI;
  if lambdaN<0
      lambdaN=0;
  end
  
  DC=lambdaN^2+2*p*lambdaI*lambdaN;
  peak=p^2*lambdaI;
  a=1/sqrt(4*pi*sigma.^2); 
  F=DC+peak*a*(exp(-Tau.^2/(4*sigma^2))+exp(-(Tau-T).^2/(4*sigma^2))+exp(-(Tau+T).^2/(4*sigma^2))+exp(-(Tau-2*T).^2/(4*sigma^2))+exp(-(Tau+2*T).^2/(4*sigma^2)));
  
