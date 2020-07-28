function [p pl my] = patchErrorBars(X,Y,color,err,smth)

% function [p pl my] = patchErrorBars(X,Y,color,err,smth)

if nargin == 1
    Y = X;
    X = 1:size(X,2);
end

if ~exist('err','var') || isempty(err)
    err = 'sem';
end

if ~exist('color','var') || isempty(color)
    color = 'k';
end

% smooth if selected
if exist('smth','var') 
    if ~isempty(smth)
        for i = 1:size(Y,1)
            Y(i,:) = SmoothGaus(Y(i,:),smth);
        end
    end
end
    

% by default, assume each column is what is being averaged over
my = nanmean(Y,1);
if strcmp(err,'sem')
    erry = nanstd(Y,[],1) ./ sqrt(size(Y,1));
    y = [my + erry fliplr(my-erry)];    
elseif strcmp(err,'prctile')
    erry = prctile(Y,[2.5 97.5],1);
    y = [erry(1,:) fliplr(erry(2,:))];
elseif strcmp(err,'std')
    erry = nanstd(Y,[],1);
    y = [my + erry fliplr(my-erry)];
end
x = [X fliplr(X)];

hold on
p = patch(x,y,1);
p.EdgeAlpha = 0;
p.FaceColor = color;
p.FaceAlpha = .4;
pl = plot(X,my,'Color',color,'LineWidth',1);


