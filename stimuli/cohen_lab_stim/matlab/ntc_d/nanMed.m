function y = nanmed(x)

[m,n] = size(x);
x = sort(x); % NaNs are forced to the bottom of each column

% Replace NaNs with zeros.
nans = isnan(x);
i = find(nans);
x(i) = zeros(size(i));
if min(size(x))==1,
  n = length(x)-sum(nans);
  if rem(n,2)     % n is odd    
      y = x((n+1)/2);
  else            % n is even
      y = (x(n/2) + x(n/2+1))/2;
  end
else
  n = size(x,1)-sum(nans);
  y = zeros(size(n));

  % Odd columns
  odd = find(rem(n,2)==1 & n>0);
  idx =(n(odd)+1)/2 + (odd-1)*m;
  y(odd) = x(idx);

  % Even columns
  even = find(rem(n,2)==0 & n>0);
  idx1 = n(even)/2 + (even-1)*m;
  idx2 = n(even)/2+1 + (even-1)*m;
  y(even) = (x(idx1)+x(idx2))/2;

  % All NaN columns
  i = find(n==0);
  y(i) = i + nan;
end

return
