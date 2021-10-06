function [p e my erry] = errorBars(X,Y,color,err,smth,ERROR,method,varargin)

%% function [p my e erry] = errorBars(X,Y,color,err,smth,ERROR,method,varargin)
if nargin == 1 | size(X,1) ~= 1
    Y = X;
    X = 1:size(X,2);
end

if ~exist('err','var') || isempty(err)
    err = 'sem';
end

if ~exist('color','var') || isempty(color)
    color = 'k';
end

if ~exist('method','var') || isempty('method');
    method = 'mean';
end

if ~exist('ERROR','var') || isempty(ERROR)
    
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
        y = [my + erry; my-erry];    
    elseif strcmp(err,'prctile')
        if strcmp(method,'median')
            my = nanmedian(Y,1);
        end
        erry = prctile(Y,[2.5 97.5],1);
        y = [erry(1,:); erry(2,:)];
    elseif strcmp(err,'std')
        erry = nanstd(Y,[],1);
        y = [my + erry; my-erry];
    end
    x = [X fliplr(X)];

else
    
    % y means
    my = mean(Y,1);
    
    % plot using supplied error
    if size(ERROR,1) > size(ERROR,2)
        ERROR = ERROR';
    end
    erry = ERROR;
    if size(erry,1) == 1
        y = [my - erry; my + erry];
    else
        y = erry;
    end
    
end

hold on;
if ~exist('varargin','var') | isempty(varargin)
    p = plot(X,my,'color',color);
    e = plot(repmat(X,2,1),y,'color',color);
else
    p = plot(X,my,varargin{:},'color',color);
    e = plot(repmat(X,2,1),y,varargin{:},'color',color,'Marker','none','LineStyle','-');
end

end
