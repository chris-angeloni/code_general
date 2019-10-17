function Y = cleanResample(X,rin,rout)

% function Y = cleanResample(X,rin,rout)
% resample to preserve "hard" stimulus boundaries by using nearest
% neighbor interpolation
%
% INPUTS:
%  X = matrix to resample
%  rin = sample period of the original (in s, eg. 1000Hz = .001s period)
%  rout = sample period desired (in s, must be a factor of rin)

n = rin/rout;
Y = reshape(repmat(X,n,1),size(X,1),[]);


% Y = zeros(size(X,2),size(X,1)*(rin/rout));
% xq = linspace(1,length(X),length(X) * (rin/rout));
% for i = 1:size(X,2)
%     Y(i,:) = interp1(X(:,i),xq,'previous');
% end