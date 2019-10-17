function [Y,F] = SmoothGaus(X, M);

if size(X, 1) >1
    X = transpose(X);
end

sigma = M^.5;
G = -M:M;
F = exp( - (G.^2/(2*sigma)^2));
F = F/(sum(F));
Y = conv(X, F);
Y = Y(M+1:end-M);
Y(1:M) = Y(1:M)*sum(F)./( sum(F(1:M)) + cumsum(F(M+1:M*2)) );
Y(end:-1:end-M+1) = Y(end:-1:end-M+1)*sum(F)./( sum(F(1:M)) + cumsum(F(M+1:M*2)) );
