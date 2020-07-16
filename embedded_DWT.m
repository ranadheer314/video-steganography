function X = embedded_DWT(img,a3)
sX = size(img);
% Discrete Wavelet Transform
[LL LH HL HH] = dwt2(img,'haar');
dec = [...
    LL,LH
    HL,HH
    ...
    ];
figure;imshow(dec,[]);title ('DWT');
%Embedding Image in 3 X 3 bit Propagation
% Selected Band is LL.
b = 3;
txt = a3;
I = LL;
N = 8*numel(txt);
S = numel(I);
if N > S
    warning('Content Truncated')
    txt = txt(1:floor(S/8));
    N = 8*numel(txt);
end
p = 2^b;
h = 2^(b-1);
I1 = reshape(I,1,S);
addl = S-N;
dim = size(I);
I2 = round(abs(I1(1:N)));
si = sign(I1(1:N));
for k = 1:N
    if si(k) == 0
        si(k) = 1;
    end
    I2(k) = round(I2(k));
    if mod((I2(k)),p) >= h
        I2(k) = I2(k) - h;
    end
end
bt = dec2bin(txt,8);
bint = reshape(bt,1,N);
d = h*48;
bi = (h*bint) - d;
I3 = double(I2) + bi;
binadd = [bi zeros(1,addl)];
I4 = double(si).*double(I3);
I5 = [I4 I1(N+1:S)];
img = reshape(I5,dim);
% img = embedAction(double(HH),hcode,3);
%Perform Inverse Wavelet Transform
X = idwt2(img,LH,HL,HH,'haar',sX);
% figure;imshow(uint8(X));title('IDWT');
% Writing Embedded Image file
% imwrite(uint8(X),'embed.jpg','jpg');
figure;
imshow(uint8(X));title('EMBEDDED OUTPUT');