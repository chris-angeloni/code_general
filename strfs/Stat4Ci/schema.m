% 1. ReadCid.m that reads Classification Image Data at the individual trial level (in CID format); 
% 2. BuildCi.m that performs least-square multiple linear regression on this data; 
% 3. hrCi2cIm.m that transforms a 24 bits classification image into a color image, for storage;
% 4. cIm2hrCi.m that does the opposite; 
% 6. SmoothCi.m that convolves a classification image with a Gaussian filter; 
% 5. ZTransCi.m that Z-transforms a smoothed classification image; 
% 6. CiVol that calculates a vector of spherical intrinsic volumes for the search region in the classification image; 
% 7. HalfMax.m that computes the FWHM of the Gaussian filter used to smooth the classification image; 
% 8. stat_threhold.m that applies the Pixel and Cluster tests on a Z-transformed and smoothed classification image; and 
% 9. DisplayCi.m that displays the statistically thresholded classification image and ouputs a summary table.