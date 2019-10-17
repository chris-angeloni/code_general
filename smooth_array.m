function y = smooth_array(x, width)
% Gaussian smoothing of x, using std=width

t = (-5*width):(5*width);
g = exp(-t.^2 / (2* width^2));
g = g/sum(g);

y = conv(x, g, 'same');