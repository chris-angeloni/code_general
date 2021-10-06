function MSE = lagAndRepeat(td,d,lag,rep)

% repeat value
TD = repmat(td,round(rep),1);

% lag
maxLength = length(d);
lagEnd = round(lag)+length(TD)-1;
ind = round(lag):min(lagEnd,maxLength);
MSE = mean((d(ind) - TD) .^ 2);