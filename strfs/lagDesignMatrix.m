function X = lagDesignMatrix(S,lags)

%% function X = lagDesignMatrix(S,lags)
%
% simple lagging of design matrix S by lag steps

if size(S,2) < size(S,1)
    S = S';
end

nfs = size(S,1);
X = zeros(nfs*lags,size(S,2));
for i = 1:lags
    
    rowI = (i-1)*nfs+1:i*nfs;
    X(rowI,:) = circshift(S,(i-1),2);

end

%X = flipud(X);


