function J = Dehaze_LPMinVP(IMG_Hazy)
% Input:  IMG_Hazy:   HAZY IMAGE | format: gray 0~1
% Output: J:     DEHAZED IMAGE
% Usage:  IMG_Hazy is a gray hazy image, which is dehazed based on LPMinVP
% Copyright:
%          
% Contract: jiehan_tj@tongji.edu.cn
% Reference:
%           J. HAN, S. ZHANG, Z.YE. LPEVP: Local Patch-wise Extreme Values Prior for Single Remote Sensing Image Dehazing

%% estimate the atmosphere arlight
win_size = 15;
dark_chan = get_dark_channel_CPMMP(IMG_Hazy, win_size);%

[m,n,D]   = size(IMG_Hazy);

sum_level = 0;
for i = 1 : D
    sum_level = sum_level + IMG_Hazy(:,:,i);
end
IMG_Mean = sum_level/D;
Gauss_kernel = ones(win_size,win_size)/win_size^2;

%% Atmosphere light estimation1 
r = 64;%% default = 64

Atmos1 = IMG_Hazy+ (sum(IMG_Mean(:))/(m*n) - sum(dark_chan(:))/(m*n));%
for i = 1 : D
    Atmos2(:,:,i) = guidedfilter(rgb2gray(IMG_Hazy), Atmos1(:,:,i), r, 0.001);
end
Atmos3 = min(Atmos2, max(max((IMG_Hazy))));
Atmos_fin = imfilter(Atmos3, Gauss_kernel,'symmetric');
% 
temp  = zeros(m,n,D);
for i = 1 : D
    temp(:,:,i) = IMG_Hazy(:,:,i)./Atmos_fin(:,:,i);%
end

    
    
%% estimate the transmission map

dark_chan2 =  get_dark_channel_CPMMP(temp, win_size);%
IMG_Min    =  min(IMG_Hazy,[],3);
beta       =  IMG_Mean - IMG_Min;

trans_map1 =  (1-0.95*dark_chan2)./max(1-beta, 0.001);
trans_map  =  guidedfilter(rgb2gray(IMG_Hazy),trans_map1, r,0.01);
trans_map  =  max(trans_map, 0.01);

%% recover the image brig_chan
J = (IMG_Hazy - Atmos_fin)./max(trans_map,0.01) + Atmos_fin;

  
    
end
