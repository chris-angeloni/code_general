function [p my erry] = errorBars(X,Y,color,err,smth)

% function [p my erry] = errorBars(X,Y,color,err,smth)

if ~exist('err','var') || isempty(err)
    err = 'sem';
end

% smooth if selected
if exist('smth','var') && ~isempty(smth)
    for i = 1:size(Y,1)
        Y(i,:) = SmoothGaus(Y(i,:),smth);
    end
end
    

% by default, assume each column is what is being averaged over
my = nanmean(Y,1);
if strcmp(err,'sem')
    erry = nanstd(Y,[],1) ./ sqrt(size(Y,1));
    erry = repmat(erry,2,1);
elseif strcmp(err,'prctile')
    erry = prctile(Y,[2.5 97.5],1);
    erry = abs(my-erry);
elseif strcmp(err,'std')
    erry = nanstd(Y,[],1);
    erry = repmat(erry,2,1);
end

p = errorbar(X,my,erry(1,:),erry(2,:),'Color',color);
