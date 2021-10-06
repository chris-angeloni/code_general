function [hh, edges] = histogram_symlog(x,n,C,varargin)

if nargin < 2
    n = 30;
end

if nargin < 3
    C = -1;
end

if nargin < 4
    varargin = {};
end

% log tranformed histogram to get the x ticks
xlog = sign(x) .* log10(1+abs(x)/(10^C));
hh = histogram(xlog,n,varargin{:});
edges = hh.BinEdges;
t0 = max(abs(get(gca,'XLim')));

% transform the x ticks
C = 10^C;
t0 = sign(t0) .* C .* (10.^(abs(t0))-1);
t0 = sign(t0) .* log10(abs(t0));
t0 = ceil(log10(C)):ceil(t0);
t1 = 10.^t0;

% mirror over zero to get the negative ticks
t0 = [fliplr(t0),-inf,t0];
t1 = [-fliplr(t1),0,t1];
t1 = sign(t1).*log10(1+abs(t1)/C);
for ii = 1:length(t0)
    if t1(ii) == 0
        lbl{ii} = '0';
        % uncomment to display +/- 10^0 as +/- 1
%     elseif t0(ii) == 0
%         if t1(ii) < 0
%             lbl{ii} = '-1';
%         else
%             lbl{ii} = '1';
%         end
    elseif t1(ii) < 0
        lbl{ii} = ['-10^{',num2str(t0(ii)),'}'];
    elseif t1(ii) > 0
        lbl{ii} = ['10^{',num2str(t0(ii)),'}'];
    else
        lbl{ii} = '0';
    end
end
set(gca,'xtick',t1,'XTickLabel',lbl)
