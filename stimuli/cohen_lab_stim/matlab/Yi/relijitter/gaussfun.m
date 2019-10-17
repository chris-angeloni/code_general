function F=gaussfun(x,xdata,T)
  F=x(1)+x(2)*exp(-xdata.^2/(2*x(3)^2))+x(2)*exp(-(xdata-T).^2/(2*x(3)^2))+x(2)*exp(-(xdata+T).^2/(2*x(3)^2))+x(2)*exp(-(xdata-2*T).^2/(2*x(3)^2))+x(2)*exp(-(xdata+2*T).^2/(2*x(3)^2));
  

  