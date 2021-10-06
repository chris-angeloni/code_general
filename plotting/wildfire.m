function cmap = wildfire(varargin)

a = importdata('wildfire_map.txt');
cmap = a(:,1:3);

if nargin > 0
    n = varargin{1};
    cmap = cmap(linspace(1,length(cmap),n),:);
end