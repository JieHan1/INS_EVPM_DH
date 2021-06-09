function feat = DHQI_feature(img1,img2)
% img1: haze image
% img2: dehaze image
%%
img1 = double(img1);
img2 = double(img2);

%% Basic features
img1_gray = 0.299*img1(:,:,1) + 0.587*img1(:,:,2) + 0.114*img1(:,:,3);
img2_gray = 0.299*img2(:,:,1) + 0.587*img2(:,:,2) + 0.114*img2(:,:,3);
if sum(size(img1_gray)==size(img2_gray))~=2
    img2_gray = imresize(img2_gray,size(img1_gray));
end

% local mean and variance
win = fspecial('gaussian',7,7/6);
win = win/sum(sum(win));
mu1 = imfilter(img1_gray,win,'replicate');
mu_sq1 = mu1.*mu1;
sigma1 = sqrt(abs(imfilter(img1_gray.*img1_gray,win,'replicate') - mu_sq1));
mu2 = imfilter(img2_gray,win,'replicate');
mu_sq2 = mu2.*mu2;
sigma2 = sqrt(abs(imfilter(img2_gray.*img2_gray,win,'replicate') - mu_sq2));
% normalized local variance
nv1 = sigma1./(mu1+1);
nv2 = sigma2./(mu2+1);

%% Feature Group 1: haze-removing features
% feature 1: pixel-wise DCP
dark = min(min(img2(:,:,1),img2(:,:,2)),img2(:,:,3))/255;
dark_mean = nanmean(dark(:));
% feature 2: image entropy
img_entropy = entropy(uint8(img2_gray));
% feature 3: local variance 
sigma_mean = nanmean(sigma2(:));
% feature 4: normalized local variance
nv_mean = nanmean(nv2(:));
% feature 5: contrast energy
[CE_gray,~,~] = CE(img2);
CE_gray_mean = nanmean(CE_gray(:));

hazeFeature = [dark_mean img_entropy sigma_mean nv_mean CE_gray_mean];

%% Feature Group 2: structure-preserving features
% feature 6: variance similarity
sigmaSIM = (2*sigma1.*sigma2+1)./(sigma1.^2+sigma2.^2+1);
sigmaSIM_mean = nanmean(sigmaSIM(:));
% feature 7: normalized variance similarity
constForNV = 0.01;
nvSIM = (2*nv1.*nv2+constForNV)./(nv1.^2+nv2.^2+constForNV);
nvSIM_mean = nanmean(nvSIM(:));
% feature 8: normalize image similarity
imgNor1 = (img1_gray-mu1) ./ (sigma1+1)+3;
imgNor2 = (img2_gray-mu2) ./ (sigma2+1)+3;
imgNorSIM = (2*imgNor1.*imgNor2)./(imgNor1.^2+imgNor2.^2);
imgNorSIM_mean = nanmean(imgNorSIM(:));

structureFeature = [sigmaSIM_mean nvSIM_mean imgNorSIM_mean];

%% Feature Group 3: over-enhancement features
% feature 9-11: over-enhancement in low contrast areas
lowContrastArea = sigma1 < mean2(sigma1);
highEnhancementArea = sigma2-sigma1 > mean2(sigma2-sigma1);
area = lowContrastArea & highEnhancementArea;
if sum(area(:))==0
    area = logical(ones(size(sigmaSIM)));
end
overEnhancement = [nanmean(sigmaSIM(area)) nanmean(nvSIM(area)) nanmean(imgNorSIM(area))];
% feature 12: blockiness
blockFeature = UCA(img2,1);

overEnhancementFeature = [overEnhancement blockFeature];

%% All features
feat = [hazeFeature structureFeature overEnhancementFeature];

end
