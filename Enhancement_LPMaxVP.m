function J = Enhancement_LPMaxVP(IMG,win_size)
% Input:  (1) IMG: dehazed image from LPMinVP | format: gray 0~1
%         (2) win_size: windows width | default value is 9
% Output: (1) J: ENHANCEMED IMAGE
% Usage:  IMG is a gray image, which is enhanced based on LPMaxVP
% Copyright:
%          
% Contract: jiehan_tj@tongji.edu.cn
% Reference:
%           J. HAN, S. ZHANG, Z.YE. LPEVP: Local Patch-wise Extreme Values Prior for Single Remote Sensing Image Dehazing

%% enhanced algorithm with bright channel
if ~exist('win_size','var')
    win_size = 9;
end
[m,n,D]   = size(IMG);
brig_chan = get_bright_channel_CPMMP(IMG, win_size);
atmos_b   = zeros(m,n,D);
for i= 1 : D
    atmos_b(:,:,i) = max(guidedfilter(IMG(:,:,i), brig_chan, 64, 0.001),0.001);
end
IMG_Mean = mean(IMG,3);
deta = brig_chan - IMG_Mean;
trans_est1  = get_bright_channel_CPMMP((IMG-deta)./max(atmos_b,0.01), win_size);
trans_est   = guidedfilter(rgb2gray(IMG), trans_est1, 64, 0.001);
J = (IMG - atmos_b)./max(trans_est,0.01) + atmos_b;
    
end