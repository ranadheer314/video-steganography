%% Watermark Embbeding
% Get the Text msg
% message = 'hellorichardsonraja';
% msgbox('hellorichardsonraja');
function nnn = Extracted(aa,img)
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
cover_object = img;
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