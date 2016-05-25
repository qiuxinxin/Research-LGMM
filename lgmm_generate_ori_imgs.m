clear all
clc
%得到原始图像与骨架图像结果%%%

% fid4=fopen('./errortxt/lgmm-minerror-14.txt');
fid4=fopen('./errortxt/lgmm-minerror-14.txt');
lgmm=textscan(fid4,'%s%s%s%s%s');
path(path,'./Registration');
for i=70:numel(lgmm{1,1})
    
    %%%lgmm最优骨架化图像配准结果对应的原始图像配准结果%%%
       
    s1=find(lgmm{1,1}{i}=='-');
    foldername1=lgmm{1,1}{i}(1:s1-1);foldername2=lgmm{1,1}{i}(s1+1:end);
    readfile1=imread(['./original_image/',foldername1,'.pgm']);
    readfile2=imread(['./original_image/',foldername2,'.pgm']);
    readfile1=im2double(readfile1);
    readfile2=im2double(readfile2);
    
    s2=find(lgmm{1,4}{i}=='-');
    scale1=lgmm{1,4}{i}(1:s2-1);
    scale2=lgmm{1,4}{i}(s2+1:end);
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
    [featuremat1_3,featuremat1_4,featuremat1_5,loop1_3,loop1_4,loop1_5,linktableoriginal1,bw1,ptbifu1] = export_featuremat( bw1 ); %获取环结构及其特征向量
    [featuremat2_3,featuremat2_4,featuremat2_5,loop2_3,loop2_4,loop2_5,linktableoriginal2,bw2,ptbifu2] = export_featuremat( bw2 );
    linktableoriginal1(:,2)=[];linktableoriginal2(:,2)=[];
    linktableoriginal1=linktableoriginal1';linktableoriginal2=linktableoriginal2';
    
    d=find(lgmm{1,5}{i}=='_');
    if numel(d)==0
        loop(1).st=lgmm{1,5}{i};
    elseif numel(d)==1
        loop(1).st=lgmm{1,5}{i}(1:d-1);
        loop(2).st=lgmm{1,5}{i}(d+1:end);
    else
        loop(1).st=lgmm{1,5}{i}(1:d(1)-1);
        loop(2).st=lgmm{1,5}{i}(d(1)+1:d(2)-1);
        loop(3).st=lgmm{1,5}{i}(d(2)+1:end);
    end
    
    matchingpair1=[];matchingpair2=[];
    matchingpairs1(3).points=[];matchingpairs2(3).points=[];
    for j=1:numel(loop)
        if strcmp(loop(j).st,'three')
            [P1,P2,Pidx1] = featurematching(featuremat1_3,featuremat2_3,5);
            m1=loop1_3(P1(1),:);m2=loop2_3(P2(1),:);
            if Pidx1~=1
                m2=circshift(m2, [0, (Pidx1(1)-1)*(5+2)]);
            end
            matchingpair1=[matchingpair1 m1];matchingpair2=[matchingpair2 m2];%得到最优的3点环匹配对
            matchingpairs1(1).points=m1;matchingpairs2(1).points=m2;
        elseif strcmp(loop(j).st,'four')
            [P3,P4,Pidx2] = featurematching(featuremat1_4,featuremat2_4,5);
            m1=loop1_4(P3(1),:);m2=loop2_4(P4(1),:);
            if Pidx2~=1
                m2=circshift(m2, [0, (Pidx2(1)-1)*(5+2)]);
            end
            matchingpair1=[matchingpair1 m1];matchingpair2=[matchingpair2 m2];%得到最优的4点环匹配对
            matchingpairs1(2).points=m1;matchingpairs2(2).points=m2;%得到最优的4点环匹配对  
        else
            [P5,P6,Pidx3] = featurematching(featuremat1_5,featuremat2_5,5);
            m1=loop1_5(P5(1),:);m2=loop2_5(P6(1),:);
            if Pidx3~=1
                m2=circshift(m2, [0, (Pidx3(1)-1)*(5+2)]);
            end
            matchingpair1=[matchingpair1 m1];matchingpair2=[matchingpair2 m2];%得到最优的5点环匹配对
            matchingpairs1(3).points=m1;matchingpairs2(3).points=m2;%得到最优的5点环匹配对
        end
    end
    bw2_num=numel(find(bw2==1));
    if strcmp(lgmm{1,3}{i},'cycle')%%%%只用环
        [M,N]=size(readfile1);
        points_aa= points_transform(matchingpair1', [M, N]);
        points_bb= points_transform(matchingpair2', [M, N]);
        mytform=cp2tform(points_bb,points_aa,'similarity');
        outbw2=imtransform(readfile2, mytform, 'XData', [1 size(readfile1,2)], 'YData', [1 size(readfile1,1)]);
        outmosaic = readfile1+outbw2;
%         outbw2=imtransform(bw2, mytform, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
%         outmosaic = 1-cat(3,bw1,outbw2,outbw2);
        sae(i)=saem(bw1,outbw2,bw2_num);
    else %%%%%%环加血管
        for k=1:numel(loop)
            if strcmp(loop(k).st,'three')
                M=3;
                l=1;
            elseif strcmp(loop(k).st,'four')
                M=4;
                l=2;
            else
                M=5;
                l=3;
            end
            [points_bb(k).points,points_aa(k).points]=featurepoints_extraction(bw1,bw2,matchingpairs1(l).points,matchingpairs2(l).points,linktableoriginal1,linktableoriginal2,M);
        end
        if numel(loop)==1
            points_bb_all=points_bb(1).points;points_aa_all=points_aa(1).points;
        elseif numel(loop)==2
            points_bb_all=[points_bb(1).points;points_bb(2).points];
            points_aa_all=[points_aa(1).points;points_aa(2).points];
        else
            points_bb_all=[points_bb(1).points;points_bb(2).points;points_bb(3).points];
            points_aa_all=[points_aa(1).points;points_aa(2).points;points_aa(3).points];
        end
        mytform=cp2tform(points_bb_all,points_aa_all,'similarity');
        outbw2=imtransform(readfile2, mytform, 'XData', [1 size(readfile1,2)], 'YData', [1 size(readfile1,1)]);
%         outbw2=imtransform(bw2, mytform, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
        
        if strcmp(lgmm{1,3}{i},'twice')
            [reference_points,transformed_points]=find_local_regis_points(bw1,outbw2,ptbifu1,5);%得到局部未配准的特征点
            [new_corresponding_points]=find_original_corresponding(bw2,ptbifu2,mytform,transformed_points(2).points);%由outbw2得到bw2对应的局部特征点
            reference = [reference_points(2).points;points_aa_all]; %与初始特征点集集合在一起
            transform = [new_corresponding_points;points_bb_all];
            mytform_twice= cp2tform(transform,reference,'similarity');           
%             outbw2_twice= imtransform(bw2, mytform_twice, 'XData', [1 size(bw1,2)], 'YData', [1 size(bw1,1)]);
            outbw2_twice=imtransform(readfile2, mytform, 'XData', [1 size(readfile1,2)], 'YData', [1 size(readfile1,1)]);
            outmosaic = readfile1+outbw2_twice;%原始图像结果 
%             outmosaic = 1-cat(3,bw1,outbw2_twice,outbw2_twice);           
%             sae(i)=saem(bw1,outbw2_twice,bw2_num);
        else
            outmosaic = readfile1+outbw2;
%             outmosaic = 1-cat(3,bw1,outbw2,outbw2);
            sae(i)=saem(bw1,outbw2,bw2_num);
        end
    end
%     imwrite(mat2gray(outmosaic),['./lgmm最优结果2/',foldername1,foldername2,'-',lgmm{1,4}{i},'-',lgmm{1,5}{i},'-',num2str(sae(i)),'.tif'],'Resolution',300);
    imwrite(mat2gray(outmosaic),['./LGMM-VARIA/',foldername1,'-',foldername2,'/',foldername1,foldername2,'-LGMM-Registration.tif'],'Resolution',300);
%     imshow(outmosaic);
    % imwrite(outmosaic,['./rr/',foldername1,foldername2,'-Bifurcation-Registration.tif'])
    clearvars -except lgmm sae
end