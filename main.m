% % % A Robust and Secure Video Steganography Method in DWT-DCT Domains
% % % % % % % Based on Multiple Object Tracking and ECC
clc;
clear all;
close all;
warning('off','all');
%% Motion Object Detection and Region Extraction
folder = dir('View_001\*.jpg');
for x = 1:length(folder)
    f = folder(x).name;
    images{x,:} = imread(fullfile('View_001\',f));
end
load a1.mat;
ij = 1;l = 1;k = 1;
[z z1] = size(images);
for i = 2 : z
    c1 = (a1{i});
    [k1,k2] = size(c1);
    for j = 1:k1
        mm = c1(j,:);
        im = imcrop(images{i,:},mm);
        im1{ij,1} = im;
        ij = ij + 1;   
    end
end
% % % ForegroundMask
fg1Mask = images{14};
mask1 = imopen(fg1Mask, strel('rectangle', [3,3]));
mask2 = imclose(mask1, strel('rectangle', [15, 15]));
mask3 = imfill(mask2, 'holes');
mask3 = im2bw(mask3);
xx = imcrop(mask3,a1{14}(4,:));
% figure,imshow(xx);
im2 = cell(3,1);
im2{1} = im1(37:40);
im2{2} = im1(41:44);
im2{3} = im1(45:48);
% % % Secrete Message
aa = input('Enter the Message : '); 
[key1,key2,a3] = sec_Msg(aa);
% %% Apply 2D-DWT
% % % % % DWT Coefficiency of R,G,B
im3 = im2{3}{1};
X = embedded_DWT(im3,a3);
% %% Apply 2D-DCT
% % % % DCT Coefficiency od R,G B
[embimg,p] = wtmark(im3,a3);
embimg1 = imresize(embimg,[size(X(:,:,2))]);
figure,imshow(embimg1);
[wm]=exwmark(embimg);
figure,imshow(imresize(wm,[size(xx)]));
% Make Stego Video 
a = VideoWriter('myStego.avi');a
a.FrameRate = 3;
% open the video writer
open(a);
% write the frames to the video
for u = 3:length(images)
    % convert the image to a frame
    frame1 = im2frame(images{u});
    writeVideo(a, frame1);
end
% close the writer object
close(a);
% % % Data Extracting Stage 
vid = 'myStego.avi';
[a1,ou] = Data_Extracting_Stage(vid);
xx1 = imcrop(ou{14},a1{14}(4,:));
figure,imshow(xx1);title('Hided ROI');
%% Message Retrivel
% data = retrivel(uint8(xx1));
mm = 1;m1 = 1;m32 = 1;m11 = 1;
for i = 1:(key1*7)
    sg(mm:7) = a3(i);
    s1(mm,:) = sg;
    mm = mm+1;
    tem(m1:7) = key2(i);
    a12(m1,:) = logical(tem);
    m1 = m1 + 1;
    en_enb = xor(s1(i,:),a12(i,:));
    a31(m32,:) = en_enb;
    m32 = m32 + 1; 
    dec_data = decode(a31,7,4,'hamming/binary');
end
% nnn = Extracted(aa,X);
message = aa;
len = length(message) * 8;
%% Convert the message into binary form
AsciiCode = uint8(message); 
binaryString = de2bi(AsciiCode,8);
binaryString = binaryString(:);
 % set the gain factor for embbeding
 k = 2;                                    
%% read in the cover object
% file_name = 'lena.jpg';
% [filename,pathname] = uigetfile('*.jpg');
% cover_object = double(imread([pathname,filename]));
cover_object = X;
figure,imshow(cover_object,[]);
title('cover image');
%%  watermarked
cover_object = imresize(cover_object,[256 256]);
% determine size of watermarked image
Mc = size(cover_object,1);    %Height
Nc = size(cover_object,2);    %Width
% read in the message  and reshape it into a vector
Mm = size(message,1);                         %Height
Nm = size(message,2);                         %Width
message_vector = round(reshape(message,Mm*Nm,1));
[cA11,cH11,cV11,cD11] = dwt2(cover_object,'haar');
% figure,imshow([cA1,cH1,cV1,cD1]);
% add pn sequences to H1 and V1 componants when message = 0 
for (kk = 1:length(message_vector))
    pn_sequence_h = round(2*(rand(Mc/2,Nc/2)-2.5));
    pn_sequence_v = round(2*(rand(Mc/2,Nc/2)-2.5));
       if (message(kk) == 0)
        cH11 = cH11 + k * pn_sequence_h;
        cV11 = cV11 + k* pn_sequence_v;
    end
end
% % %  perform Reconstrction IDWT
watermarked_image = idwt2(cA11,cH11,cV11,cD11,'haar',[Mc,Nc]); 
% convert back to uint8
watermarked_image_uint8 = uint8(watermarked_image);
% imwrite(watermarked_image_uint8,'6.jpg');
%% 
% display watermarked image
% figure,
% imshow(watermarked_image_uint8,[]);
% title('Watermarked Image');

%% Watermark Recovery
 Mw = size(watermarked_image_uint8,1);           %Height
 Nw = size(watermarked_image_uint8,2);           %Width
% % read in original watermark message
orig_watermark = message;
% % determine size of original watermark
Mo = size(orig_watermark,1);  %Height
No = size(orig_watermark,2);  %Width
%  % initalize message to all ones
message_vector1 = round(reshape(orig_watermark,Mo*No,1));
[cA1,cH1,cV1,cD1] = dwt2(watermarked_image,'haar');
%% add pn sequences to H1 and V1 componants when message = 0 
 for (kk=1:length(message_vector1))
%      pn_sequence_h=round(2*(rand(Mw/2,Nw/2)-0.5));
%      pn_sequence_v=round(2*(rand(Mw/2,Nw/2)-0.5));
       correlation_h(kk)=corr2(cH1(:,:,1),pn_sequence_h);   
       correlation_v(kk)=corr2(cV1(:,:,1),pn_sequence_v);
       correlation(kk)=(correlation_h(kk)+correlation_v(kk))/2;
end
 for (kk=1:length(message_vector1))
     if (correlation(kk) > mean(correlation))
         message_vector1(kk) = 0;
     end
 end
%% reshape the message vector and display recovered watermark.
  figure,
message1 = reshape(message_vector1,Mm,Nm);
imshow(message1,[]);
title('Recovered Watermark');
b = dec2bin(message1);
nnn = char(bin2dec(b));
fprintf('RECOVERED STRING \n');
disp(nnn')
% ax = toc;
% %%  Performence evalution
% Gaussiannoise();
% % 
