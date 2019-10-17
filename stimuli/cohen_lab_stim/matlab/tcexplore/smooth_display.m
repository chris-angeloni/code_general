function smoothed_data = smooth_display(data)
% function smoothed_data = smooth_display(data)
% smooths the 2D array display by performing a local
% weighted average of each bin with the adjacent bins

[r, c] = size(data);
l_shift = [data(:,1) data];
r_shift = [data data(:,c)];
u_shift = [data(1,:); data];
d_shift = [data; data(r,:)];

l_shift = l_shift(1:r,1:c);
r_shift = r_shift(1:r,2:c+1);
u_shift = u_shift(1:r,1:c);
d_shift = d_shift(2:r+1,1:c);

ul_shift = [l_shift(1,:); l_shift];
ur_shift = [r_shift(1,:); r_shift];
dl_shift = [l_shift; l_shift(r,:)];
dr_shift = [r_shift; r_shift(r,:)];

ul_shift = ul_shift(1:r,1:c);
ur_shift = ur_shift(1:r,1:c);
dl_shift = dl_shift(2:r+1,1:c);
dr_shift = dr_shift(2:r+1,1:c);

smoothed_data = 4*data + (l_shift + r_shift + u_shift + d_shift) + sqrt(2)/2*(ul_shift + ur_shift + dl_shift + dr_shift);
smoothed_data = smoothed_data / (8 + 2*sqrt(2));
