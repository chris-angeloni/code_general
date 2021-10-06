function plot_unity(varargin)

if nargin < 1
    varargin = {};
end

XL = get(gca,'xlim');
YL = get(gca,'ylim');
lims = [min([XL YL]) max([XL YL])];

plot(lims,lims,varargin{:})