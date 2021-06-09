function J = get_bright_channel_CPMMP(I, patch_size)
% Input:  (1) I:   IMAGE | format: gray 0~1
%         (2) patch_size: wins width, default is 9
% Output: J:   LPMaxVP map
% Usage:  for enhancement and improving the constrast of the dehazed image,
%         extract a simple, efficient and effective local patch-wise
%         maximal values prior (LPMaxVP) 
% Copyright:
%          
% Contract: jiehan_tj@tongji.edu.cn
% Reference:
%           J. HAN, S. ZHANG, Z.YE. LPEVP: Local Patch-wise Extreme Values Prior for Single Remote Sensing Image Dehazing

if ~exist('patch_size', 'var')
    patch_size = 9;
end

[M, N, ~] = size(I);
Mp = ceil(M/patch_size);
Np = ceil(N/patch_size);
J = zeros(M, N);  

for m = 1:Mp
    for n = 1:Np
        idx1 = [1,patch_size]+(m-1)*patch_size;
        idx2 = [1,patch_size]+(n-1)*patch_size;
        patch = I(idx1(1):min(idx1(2),M), idx2(1):min(idx2(2),N),:);
        
        [val,~]   = max(patch(:));
        [M1,N1,~] = size(patch);
        cur_patch = ones(M1,N1);
        cur_patch = val*cur_patch;
        
        J(idx1(1):min(idx1(2),M), idx2(1):min(idx2(2),N)) = cur_patch;
    end
end

end
