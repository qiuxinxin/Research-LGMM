clear all
clc

fid2=fopen('./errortxt/error_bifur.txt');
bifur=textscan(fid2,'%s%s%s%s%s%s%s');

sae1=17*ones(1,155);
for i=1:numel(bifur{1,1})
    path(path,'./code');
    s1=find(bifur{1,1}{i}=='-');
    foldername1=bifur{1,1}{i}(1:s1-1);foldername2=bifur{1,1}{i}(s1+1:end);
    readfile1=imread(['./original_image/',foldername1,'.pgm']);
    readfile2=imread(['./original_image/',foldername2,'.pgm']);
    readfile1=im2double(readfile1);
    readfile2=im2double(readfile2);

    %%%%%%%%%%bifur%%%%%%%%%%%%
    s2=find(bifur{1,3}{i}=='-');
    scale1=bifur{1,3}{i}(1:s2-1);
    scale2=bifur{1,3}{i}(s2+1:end);
    if floor(log10(str2double(scale1)))+1==1
        bw1=imread(['./Dataset/Skeleton/',foldername1,'/','0',scale1,'.tif']);
    else
        bw1=imread(['./Dataset/Skeleton/',foldername1,'/',scale1,'.tif']);
    end
    if floor(log10(str2double(scale2)))+1==1
        bw2=imread(['./Dataset/Skeleton/',foldername2,'/','0',scale2,'.tif']);
    else
        bw2=imread(['./Dataset/Skeleton/',foldername2,'/',scale2,'.tif']);
    end
    bw1 = im2double(bw1);
    bw2 = im2double(bw2);
    
    radius = 3;
    NumMin = 20;
    [linktable1, featuremat1, bw1] = points_feature(bw1, radius);
    [linktable2, featuremat2, bw2] = points_feature(bw2, radius);
    if isempty(linktable1) || isempty(linktable2)
        continue;
    end
    [P1, P2, P2idx] = featurematch(featuremat1, featuremat2, NumMin);
    P1 = P1(P2idx==1);P2 = P2(P2idx==1);P2idx = P2idx(P2idx==1);
    [outP1,outP2,mytform1,base_points,input_points] = verifymatch(linktable1, linktable2, P1, P2, P2idx, bw1, bw2, 2);
    if ~isempty(mytform1)
        bw2_num=numel(find(bw2==1));
        outbw1 = bw1;
%         outbw2 = imtransform(bw2, mytform1, 'XData', [1 size(outbw1,2)], 'YData', [1 size(outbw1,1)]);
        outbw2 = imtransform(readfile2, mytform1, 'XData', [1 size(readfile1,2)], 'YData', [1 size(readfile1,1)]);
        outmosaic = readfile1+outbw2;
        imwrite(mat2gray(outmosaic),['./LGMM-VARIA/',foldername1,'-',foldername2,'/',foldername1,foldername2,'-Bifurcation-Registration.tif'],'Resolution',300);
%         sae1(i)=saem(bw1,outbw2,bw2_num);
%         ss=sae1(i)
    end  
end