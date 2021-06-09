function score = DHQI(img1,img2)
% Input:  (1) img1: haze image
%         (2) img2: dehaze image
% Output: (1) score: the dehazing quality score
% Usage:  Given a haze image img1 and a dehaze image img2, whose dynamic range is 0-255
%         score = DHQI(img1,img2);

%%
CurrentPath = pwd;
[DHQIpath,~,~]=fileparts(which('DHQI'));

feat = DHQI_feature(img1,img2);

cd([DHQIpath '\SVM\'])

fid = fopen('test_ind.txt','w');
for itr_im = 1:size(feat,1)
    fprintf(fid,'%d ',1);
    for itr_param = 1:size(feat,2)
        fprintf(fid,'%d:%f ',itr_param,feat(itr_im,itr_param));
    end
    fprintf(fid,'\n');
end
fclose(fid);
delete test_ind_scaled
system('svm-scale -r range test_ind.txt >> test_ind_scaled');
system('svm-predict  -b 1  test_ind_scaled model output.txt>dump');
load output.txt;
score = output;

cd(CurrentPath)

end


