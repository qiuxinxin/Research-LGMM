clear all
clc

fid=fopen('./Dataset/index.txt','r');%%读取index文档中的图像配对情况
C=textscan(fid,'%s%s');%%按列读取配对文档中的视网膜图像的配对情况
fid2=fopen('./errortxt/error_bifur.txt');
bifur=textscan(fid2,'%s%s%s%s%s%s%s');
fid3=fopen('./errortxt/error_bifur_global.txt');
bifur_global=textscan(fid3,'%s%s%s%s%s%s%s');
fid4=fopen('./errortxt/lgmm-minerror-14.txt');
lgmm=textscan(fid4,'%s%s%s%s%s');

for i=1:numel(C{1,1})
    foldername1=C{1,1}{i};foldername2=C{1,2}{i};
    folder=strcat('./LGMM-VARIA/',foldername1,'-',foldername2);
    mkdir(folder);
    foldername=[foldername1,'-',foldername2];
    
    %%%%%%%%%%原始图像%%%%%%%%%%%%%%%%%%
    ori_src1=['./original_image/',foldername1,'.pgm'];
    ori_dest1=[folder,'/',foldername1,'.pgm'];
    copyfile(ori_src1,ori_dest1);
    ori_src2=['./original_image/',foldername2,'.pgm'];
    ori_dest2=[folder,'/',foldername2,'.pgm'];
    copyfile(ori_src2,ori_dest2);
    
    %%%%%%%bifurcation最优配准尺度骨架图%%%%%%%
    for k=1:1:numel(C{1,1})
        if strcmp(bifur{1,1}{k},foldername)==1
            break;
        end
    end
    s1=find(bifur{1,3}{k}=='-');
    if floor(log10(str2double(bifur{1,3}{k}(1:s1-1))))+1==1
        bs_src1=['./Dataset/Skeleton/',foldername1,'/','0',bifur{1,3}{k}(1:s1-1),'.tif'];
        bs_dest1=[folder,'/',foldername1,'-','Bifurcation-Skeleton-','0',bifur{1,3}{k}(1:s1-1),'.tif'];
    else
        bs_src1=['./Dataset/Skeleton/',foldername1,'/',bifur{1,3}{k}(1:s1-1),'.tif'];
        bs_dest1=[folder,'/',foldername1,'-','Bifurcation-Skeleton-',bifur{1,3}{k}(1:s1-1),'.tif'];
    end
    copyfile(bs_src1,bs_dest1);
    
    if floor(log10(str2double(bifur{1,3}{k}(s1+1:end))))+1==1
        bs_src2=['./Dataset/Skeleton/',foldername2,'/','0',bifur{1,3}{k}(s1+1:end),'.tif'];
        bs_dest2=[folder,'/',foldername2,'-','Bifurcation-Skeleton-','0',bifur{1,3}{k}(s1+1:end),'.tif'];
    else
        bs_src2=['./Dataset/Skeleton/',foldername2,'/',bifur{1,3}{k}(s1+1:end),'.tif'];
        bs_dest2=[folder,'/',foldername2,'-','Bifurcation-Skeleton-',bifur{1,3}{k}(s1+1:end),'.tif'];
    end
    copyfile(bs_src2,bs_dest2);
    
    %%%%%%%%%bifurcation最优配准结果骨架图%%%%%%%%%%%%%%
    bfresult_src1=['./bifur+glocal_results/',foldername,'/bifurcation+global/',bifur{1,3}{k},'-bifurcation*'];%num2str(error1),'.png'
    bfresult_dest1=[folder,'/'];
    copyfile(bfresult_src1,bfresult_dest1);
    objfile=dir([folder,'/',bifur{1,3}{k},'-bifurcation*']);
    ss1=find(objfile.name=='-');
    movefile([folder,'/',objfile.name],[folder,'/',foldername1,foldername2,'-Bifurcation-Skeleton-Registration',objfile.name(ss1(3):end)]);
    %%%%%%%%%%bifurcation+global最优配准尺度骨架图%%%%%%%%%%%%%
    for k=1:1:numel(C{1,1})
        if strcmp(bifur_global{1,1}{k},foldername)==1
            break;
        end
    end
    s2=find(bifur_global{1,3}{k}=='-');
    if floor(log10(str2double(bifur_global{1,3}{k}(1:s2-1))))+1==1
        bg_src1=['./Dataset/Skeleton/',foldername1,'/','0',bifur_global{1,3}{k}(1:s2-1),'.tif'];
        bg_dest1=[folder,'/',foldername1,'-','BifurcationGlobal-Skeleton-','0',bifur_global{1,3}{k}(1:s2-1),'.tif'];
    else
        bg_src1=['./Dataset/Skeleton/',foldername1,'/',bifur_global{1,3}{k}(1:s2-1),'.tif'];
        bg_dest1=[folder,'/',foldername1,'-','BifurcationGlobal-Skeleton-',bifur_global{1,3}{k}(1:s2-1),'.tif'];
    end
    copyfile(bg_src1,bg_dest1);
    
    if floor(log10(str2double(bifur_global{1,3}{k}(s2+1:end))))+1==1
        bg_src2=['./Dataset/Skeleton/',foldername2,'/','0',bifur_global{1,3}{k}(s2+1:end),'.tif'];
        bg_dest2=[folder,'/',foldername2,'-','BifurcationGlobal-Skeleton-','0',bifur_global{1,3}{k}(s2+1:end),'.tif'];
    else
        bg_src2=['./Dataset/Skeleton/',foldername2,'/',bifur_global{1,3}{k}(s2+1:end),'.tif'];
        bg_dest2=[folder,'/',foldername2,'-','BifurcationGlobal-Skeleton-',bifur_global{1,3}{k}(s2+1:end),'.tif'];
    end
    copyfile(bg_src2,bg_dest2);
    
    %%%%%%%%%bifurcation+global最优配准结果骨架图%%%%%%%%%%%%%%
    error2=str2double(bifur_global{1,2}{k});
    bfresult_src2=['./bifur+glocal_results/',foldername,'/bifurcation+global/',bifur_global{1,3}{k},'-bifur+global*'];
    copyfile(bfresult_src2,[folder,'/']);
    objfile2=dir([folder,'/',bifur_global{1,3}{k},'-bifur+global*']);
    ss2=find(objfile2.name=='-');
    movefile([folder,'/',objfile2.name],[folder,'/',foldername1,foldername2,'-BifurcationGlobal-Skeleton-Registration',objfile2.name(ss2(3):end)]);    
    %%%%%%%%%%%lgmm最优配准尺度骨架图%%%%%%%%%%%%%%%%
    for k=1:1:numel(C{1,1})
        if strcmp(lgmm{1,1}{k},foldername)==1
            break;
        end
    end
    s3=find(lgmm{1,4}{k}=='-');
    if floor(log10(str2double(lgmm{1,4}{k}(1:s3-1))))+1==1
        lgmm_src1=['./Dataset/Skeleton/',foldername1,'/','0',lgmm{1,4}{k}(1:s3-1),'.tif'];
        lgmm_dest1=[folder,'/',foldername1,'-','LGMM-Skeleton-','0',lgmm{1,4}{k}(1:s3-1),'.tif'];        
    else
        lgmm_src1=['./Dataset/Skeleton/',foldername1,'/',lgmm{1,4}{k}(1:s3-1),'.tif'];
        lgmm_dest1=[folder,'/',foldername1,'-','LGMM-Skeleton-',lgmm{1,4}{k}(1:s3-1),'.tif'];
    end
    copyfile(lgmm_src1,lgmm_dest1);
    
    if floor(log10(str2double(lgmm{1,4}{k}(s3+1:end))))+1==1
        lgmm_src2=['./Dataset/Skeleton/',foldername2,'/','0',lgmm{1,4}{k}(s3+1:end),'.tif'];
        lgmm_dest2=[folder,'/',foldername2,'-','LGMM-Skeleton-','0',lgmm{1,4}{k}(s3+1:end),'.tif'];
    else
        lgmm_src2=['./Dataset/Skeleton/',foldername2,'/',lgmm{1,4}{k}(s3+1:end),'.tif'];
        lgmm_dest2=[folder,'/',foldername2,'-','LGMM-Skeleton-',lgmm{1,4}{k}(s3+1:end),'.tif'];
    end
    copyfile(lgmm_src2,lgmm_dest2);
    
    
    %%%%%%%%%%%lgmm最优配准结果骨架图%%%%%%%%%%%%%%%%
    error3=str2double(lgmm{1,2}{k});
    if strcmp(lgmm{1,3}{k},'twice')
        lgmmresult_src=['/Users/qiuxinxin/Research/Retinal Image Registration/GLMM-3种方法选择/new-all/',foldername,'/',lgmm{1,5}{k},'/',lgmm{1,4}{k},'-twice-14-*'];
    else
        lgmmresult_src=['/Users/qiuxinxin/Research/Retinal Image Registration/GLMM-3种方法选择/new-all/',foldername,'/',lgmm{1,5}{k},'/',lgmm{1,4}{k},'-',lgmm{1,3}{k},'*'];
    end   
    lgmmresult_dest=[folder,'/'];
    copyfile(lgmmresult_src,lgmmresult_dest);
    objfile3=dir([folder,'/',lgmm{1,4}{k},'*']);
    ss3=find(objfile3.name=='-');
    if strcmp(lgmm{1,3}{k},'twice')
        movefile([folder,'/',objfile3.name],[folder,'/',foldername1,foldername2,'-LGMM-Skeleton-Registration-','twice',objfile3.name(ss3(3):end)]);
    else
        movefile([folder,'/',objfile3.name],[folder,'/',foldername1,foldername2,'-LGMM-Skeleton-Registration-',lgmm{1,3}{k},objfile3.name(ss3(3):end)]);
    end
    
end