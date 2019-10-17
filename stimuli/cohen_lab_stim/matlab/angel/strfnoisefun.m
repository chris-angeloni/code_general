% function [Tresh]=strfnoisefun(X,Num,sigma);  
%
% Function:
%              looking for the level of noise by bootstrap
% Input:
%           X        the matrix of Noise on the STRF at special spike rate
%           Num      the number of loops in bootstrap
%           sigma    the confidence of bootstrap, for example, 0.95
% Output
%           Tresh    the level of noise
%
% ANQI QIU
% 2002/5/13


function [Tresh]=strfnoisefun(X,Num,sigma);

[M,N]=size(X);

for i=1:N,
	[XStat,P1]=bootstrap(X(:,i),Num,'mean',100,'n');
        [Xstd,P2]=bootstrap(X(:,i),Num,'std',100,'n');  
        k=1;
        while sum(P1(1:k))/sum(P1)<sigma
		k=k+1;
	end;
	j=1;
	while sum(P2(1:j))/sum(P2)<sigma
                j=j+1;
        end;
	Tresh(i)=XStat(k)+erfinv(sigma)*sqrt(2)*Xstd(j);
end;
        










