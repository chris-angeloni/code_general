function F=gaussfun4(x,xdata,T)
  
  % x(1):   lambdaideal
  % x(2):   lambdanoise
  % x(3):   p
  % x(4):   sigma
  
  DC=x(2)^2+2*x(3)*x(1)*x(2);
  peak=x(3)^2*x(1);
  F=DC+peak*exp(-xdata.^2/(2*x(4)^2))+peak*exp(-(xdata-T).^2/(2*x(4)^2))+peak*exp(-(xdata+T).^2/(2*x(4)^2))+peak*exp(-(xdata-2*T).^2/(2*x(4)^2))+peak*exp(-(xdata+2*T).^2/(2*x(4)^2));
  
