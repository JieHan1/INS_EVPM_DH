clc;
clear
close all

addpath('Code_Improved');                           %% CORRESPONDING EXTERNAL FUNCTION CODE PATH FOR DEHAZE
addpath('Code_QualityMetric\DHQI');                 %% CORRESPONDING EXTERNAL FUNCTION CODE PATH FOR IQA-DHQI
addpath('Code_QualityMetric\FADE_release');         %% CORRESPONDING EXTERNAL FUNCTION CODE PATH FOR IQA-FADE
addpath('Code_QualityMetric\EvaluationDescriptor'); %% CORRESPONDING EXTERNAL FUNCTION CODE PATH FOR IQA-BECQ

%% ergodic filenames are read 
filename = 'Image_Test\hazy_Xu\Dictionary.txt';% IMAGES Path: Image_Test\hazy_Xu\Dictionary.txt|Image_Test\hazy_Xie\Dictionary.txt
fidin    = fopen(filename,'r');
nline    = 0;
while ~feof(fidin)
    tline = fgetl(fidin);
    nline = nline + 1;
    imgName{nline,:} = tline;
end
fclose(fidin);

[n, ~] = size(imgName);

for idx =1:n
    
    Image_Input    = imread(strcat('Image_Test\hazy_Xu\',imgName{idx,:}));  %% read images | format: Uint8
    Image_Input_GR = im2double(Image_Input);  %% format transfer | from Uint8 to Gray
    
    %% Implement LPMinVP to restore hazy images
    t1 = clock;
    Image_DH_RS = Dehaze_LPMinVP(Image_Input_GR);   
    t2 = clock;
    t_DH(idx) = etime(t2,t1);
    t1 = clock;
    Image_EH_RS = Enhancement_LPMaxVP(Image_DH_RS);
    t2 = clock;
    t_EH(idx) = etime(t2,t1);
    
    %% IMAGES format tranformation, from Gray to Uint8
    Image_DH_RS_FT  = uint8(255*(Image_DH_RS));
    Image_EH_RS_FT  = uint8(255*(Image_EH_RS));
    
    %% Image Quality Assessment (IQA)
    % 1. DHQI -- Min,X.,Zhai,G.,Gu, K.,Yang, X.,& Guan, X..(2018).
    % Objective quality evaluation of dehazed images. 
    % IEEE Transactions on Intelligent Transportation Systems, 1-14.
    % (Before use the CODE, please contract the authors and CITE IT)
    
    DHQI_DH(idx,1) = DHQI(Image_Input, Image_EH_RS_FT);
    DHQI_EH(idx,1) = DHQI(Image_Input, Image_DH_RS_FT);
    
%     % 2. BECA -- N. Hauti¨¨re,J.P.Tarel,D.Aubert,E.DUMONT,Blind contrast
%     % enhancement assessment by gradient ratioing at visible edges, 
%     % Image Anal. Stereol. 27 (2) (2008) 87¨C95 .
%     % (Before use the CODE, please contract the authors and CITE IT)
%     
%     [e_DH(idx,1), ~, r_DH(idx,1)]=...
%         evaluationESR(Image_Input, Image_EH_RS_FT);
%     [e_EH(idx,1), ~, r_EH(idx,1)]=...
%         evaluationESR(Image_Input, Image_DH_RS_FT);
    
    % 3. FADE -- [14]	L. K. Choi, J. You, and A. C. Bovik, 
    % Referenceless prediction of perceptual fog density and perceptual image defogging,
    % IEEE Trans. Image Process., vol. 24, no. 11, pp. 3888_3901, Nov. 2015.
    % (Before use the CODE, please contract the authors and CITE IT)
    
    Fade_DH(idx,1)  = FADE(Image_DH_RS_FT);
    Fade_EH(idx,1)  = FADE(Image_EH_RS_FT);
    
    %% output the results
    Xlabel_Text_DH = strcat('Image_Results/DeHazed_Xu/LPMinVP_',imgName{idx,:});%4Yuan
    imwrite(Image_DH_RS, Xlabel_Text_DH);
    Xlabel_Text_EH = strcat('Image_Results/DeHazed_Xu/LPEVP_',imgName{idx,:});%4Yuan/
    imwrite(Image_EH_RS_FT, Xlabel_Text_EH);

end