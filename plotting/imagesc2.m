function h = imagesc2 (x,y,img_data,clim,nancol)
% a wrapper for imagesc, with some formatting going on for nans

if nargin < 2
    img_data = x;
    h = imagesc(img_data);
end
if nargin == 2
    if numel(y) == 2
        img_data = x;
        clim = y;
        h = imagesc(img_data,clim);
    else
        error(['imagesc2.m: if supplying two arguments, first is image, ' ...
               'second is color limit']);
    end
end
if nargin > 2
    h = imagesc(x,y,img_data);
end
if nargin > 3
    h = imagesc(x,y,img_data,clim);
end
if nargin < 5
    nancol = [0 0 0];
end
if nargin > 5
    error('imagesc2.m: too many arguments');
end

% setting alpha values
if ndims( img_data ) == 2
  set(h, 'AlphaData', ~isnan(img_data))
elseif ndims( img_data ) == 3
  set(h, 'AlphaData', ~isnan(img_data(:, :, 1)))
end

% set background to nancol
set(gca, 'Color', nancol)

if nargout < 1
  clear h
end