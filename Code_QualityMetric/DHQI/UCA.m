function score = UCA(img,scale)
%% ===============================================================================
% The unified content-type adaptive (UCA) quality measure
% Copyright(c) 2017 Xiongkuo Min, Kede Ma, Ke Gu, Guangtao Zhai, Zhou Wang, and Weisi Lin
% All Rights Reserved.
% 
% --------------------------------------------------------------------------------------------
% Permission to use, copy, or modify this database and its documentation for educational
% and research purposes only and without fee is hereby granted, provided that this copyright
% notice and the original authors' names appear on all copies and supporting documentation.
% This database shall not be used, redistributed, or adapted as the basis of a commercial
% software or hardware product without first obtaining permission of the authors. The authors
% make no representations about the suitability of this database for any purpose. It is
% provided "as is" without express or implied warranty.
% --------------------------------------------------------------------------------------------
% 
% This is the unified content-type adaptive (UCA) measure described in the following paper:
% 
% Xiongkuo Min, Kede Ma, Ke Gu, Guangtao Zhai, Zhou Wang, and Weisi Lin, "Unified Blind Quality
% Assessment of Compressed Natural, Graphic and Screen Content Images," IEEE Transactions on
% Image Processing, to appear 2017.
% 
% Please contact Xiongkuo Min (minxiongkuo@gmail.com) if you have any questions.
% 
% --------------------------------------------------------------------------------------------
% 
% Input:  (1) img: test image
%         (2) scale: the number of scales considered. It's set according to the codec.
%                    scale = 4/3/2/1 if the codec is HEVC/H.264/MPEG-2/JPEG, respectively.
% Output: (1) score: quality score
% 
% Usage:  Given a test image img and the scale
%         score = UCA(img,4)
% 
%% ===============================================================================
% Multi-scale weights derived from CSF
switch scale
    case 4
        NSI_weight = [0.2066 0.3329 0.2855 0.1749];
        SCI_weight = [0.3858 0.3309 0.2026 0.0807];
    case 3
        NSI_weight = [0.2504 0.4035 0.3461];
        SCI_weight = [0.4197 0.3599 0.2204];
    case 2
        NSI_weight = [0.3830 0.6170];
        SCI_weight = [0.5383 0.4617];
    case 1
end

% Gamma fitting parameters
NSI_gammaPDF.alpha = 1.6876;
NSI_gammaPDF.beta = 33.3924;
SCI_gammaPDF.alpha = 3.2516;
SCI_gammaPDF.beta = 140.6982;

img = double(img);
if size(img,3)==3
    img = 0.299*img(:,:,1) + 0.587*img(:,:,2) + 0.114*img(:,:,3);
end
imgDown = img;

% Corner and edge scores for multi-scales
win = ones(2)/4;
for i = 1:scale
    Corner_feature(i) = calcCorner(imgDown);
    Edge_feature(i) = calcEdge(imgDown);
    if i==scale
        continue
    end
    imgDown = imfilter(imgDown,win,'symmetric','same');
    imgDown = imgDown(1:2:end,1:2:end);
end

% Content-adaptive multi-scale weighting
if scale==1
    weight = 1;
else
    volv = calcVOLV(img);
    NSI_pro = gampdf(volv,NSI_gammaPDF.alpha,NSI_gammaPDF.beta) / (gampdf(volv,NSI_gammaPDF.alpha,NSI_gammaPDF.beta)+gampdf(volv,SCI_gammaPDF.alpha,SCI_gammaPDF.beta));
    weight = NSI_pro*NSI_weight + (1-NSI_pro)*SCI_weight;
end
score = sum(Corner_feature.*Edge_feature.*weight);
score = score/(4*7/64)^2;


%% ===============================================================================
function corners = calcCorner(img)
win = fspecial('gaussian',[3,1],0.5);
corners1 = corner(img,'MinimumEigenvalue',10^10,'FilterCoefficients',win,'QualityLevel',0.0005);
corners2 = corners1(((mod(corners1(:,1),8)==1)|(mod(corners1(:,1),8)==0))|((mod(corners1(:,2),8)==1)|(mod(corners1(:,2),8)==0)),:);
corners = size(corners2,1)/size(corners1,1);

%% ===============================================================================
function edges = calcEdge(img)
BW = double(edge(img,'Prewitt',2));
mask = zeros(size(BW));
mask(1:8:end,:) = 1;
mask(:,1:8:end) = 1;
mask(8:8:end,:) = 1;
mask(:,8:8:end) = 1;
edges1 = sum(sum(BW.*mask));
edges2 = sum(sum(BW));
edges = edges1/edges2;

%% ===============================================================================
function volv = calcVOLV(img)
win = fspecial('gaussian',7,1);
win = win/sum(sum(win));
mu = imfilter(img,win,'replicate');
mu_sq = mu.*mu;
sigma = sqrt(abs(imfilter(img.*img,win,'replicate')-mu_sq));
volv = var(sigma(:));
