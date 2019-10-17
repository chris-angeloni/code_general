function [Y]=uniform(a,b,N,times);

m=0;
while m<N
   X=rand(1,N*times);
   X1=(b-a)*X+a;
   c=(b-a)/N;
   for m=1:N,
      i=find((X1>a+(m-1)*c)&(X1<a+m*c));
      Y(m)=mean(X1(i));
      if strcmp(num2str(Y(m)),'NaN')
          m=0;
          clear Y;
          break;
      end
   end
end;



