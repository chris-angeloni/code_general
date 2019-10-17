%
%function [H] = boostingkernel(X,Y,N,fv)
%
%	FILE NAME 	: BOOSTING KERNEL
%	DESCRIPTION	: Estimates an optimal linear impulse response (kernel)
%                 for a given X and Y. The kernel is estimated by
%                 minimizing the mean squared error using boosting.
%
%	X           : Input Signal
%	Y           : Output Signal
%	N           : Filter order
%   fv          : Fraction of data to use for cross validation (0<fv<1).
%                 The remaningin fraction is used for optimization.
%
% (C) Monty A. Escabi, February 2012
%
function [H] = boostingkernel(X,Y,N,fv)

%Number of samples used for cross validation and optimization
Lv=floor(fv*length(Y));     %Number of samples for validation
L=length(Y);                %Number of samples
Lo=L-Lv;                    %Number of samples for optimization

%Estimate Boosting resolion
eps=1/200*sqrt(var(Y)/var(X))
H=zeros(1,N);
E=[];
for k=1:250
   
    %Adaptive gain for boosting
    if k<21
        alpha=-1;
    else
        alpha=mean(diff(E(k-20:k-1))/sum(Y.^2));    %Mean normalized gradient over 20 itterations is negative
        %alpha=abs((E(k-1)-E(k-20))/sum(Y.^2));
%        alpha=1
    end

    %Searching over all possible boosts
    Ep=[];      %Error for negative boost
    En=[];      %Error for possitive boost
    for l=1:N
     
       %Error for possitive boost
       ht=H;
       ht(l)=ht(l)+eps;
       Yp=conv(ht,X);
       Yp=Yp(1:length(Y));
       ip=randperm(L);
       ipo=ip(1:Lo);
       ipc=ip(Lo+1:end);
       Epo(l)=sum((Y(ipo)-Yp(ipo)).^2)/sum(Y(ipo).^2);
       Epv(l)=sum((Y(ipc)-Yp(ipc)).^2)/sum(Y(ipc).^2);
       
       %Error for negative boost
       ht=H;
       ht(l)=ht(l)-eps;
       Yn=conv(ht,X);
       Yn=Yn(1:length(Y));
       in=randperm(L);
       ino=in(1:Lo);   
       inc=in(Lo+1:end);
       Eno(l)=sum((Y(ino)-Yn(ino)).^2)/sum(Y(ino).^2);
       Env(l)=sum((Y(ipc)-Yn(ipc)).^2)/sum(Y(inc).^2);
       
    end
    
    %Determining the optimal boosting parameter for the kth itteration
    Minp=min(Epo);
    Minn=min(Eno);
    ip=find(Epo==Minp);
    in=find(Eno==Minn);
    if Minp<Minn
        H(ip)=H(ip)+eps;      %Boosting kth itteration
        E(k)=Minp;
        Ev(k)=min(Epv);
    else
        H(in)=H(in)-eps;      %Boosting kth itteration
        E(k)=Minn;
        Ev(k)=min(Env);
    end


    A(k)=alpha;
    
        
        
    subplot(211)
    plot(H)
    subplot(212)
    plot(E)
    hold on
    plot(Ev,'r')

%    plot(A,'r')
    pause(0) 
    
    %Exit Loop if normalized gradient for cross validation error >0
%    if alpha>0
%        break;
%    end
    
end