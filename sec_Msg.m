% % % % % Secrete Messeage
% clc;
% clear all;
% close all;
% warning('off','all');
function [ key1,key2,a3] = sec_Msg(a)
% a = input('Enter the Message : ');
% a = fileread('text.txt');
message = strtrim(a);
len = length(message) * 8;
%% Convert the message into binary form
AsciiCode = uint8(message); 
binaryString = de2bi(AsciiCode,8);
bin = binaryString(:);  %%%%%Binary vector
%% Stego Key Generation
key1 = length(bin) ./ 4;   %%%Size of  Hidden Message
key2 = rand(2^7,key1,1)';   %%%Randomized the secrete key1
%%  Encryption Of Secrete Message
cipher = xor(bin,key1);
% ciphertext = encrypt(bin, key1)
%% % % Encode Method Using Hamming & BCH 
m1 = 3;    
 % Codeword length
n = 2^m1-1;    
 % message length
k = length(message); 
% % % number of words in given message using regular expression   
nwords = length(regexp(message, '\s+'))+1;
%% Hamming Code
matr  = mat2cell(cipher,4*ones(key1,1),1);
t = 1;
for h = 1:length(matr)
    h1 = matr{h};
    h2(t,:) = h1';
    t = t + 1;
end
% data = logical(h2);
% encData = encode(data,n,4,'hamming/binary');      
% bit_4data = reshape(encData,[],7);
%% Galois field GF(2^m)
msgTx = gf(randi([0,1],nwords,key1));
[~,t] = bchgenpoly(n,4);
enc = bchenc(msgTx',n,4);
m = 1; m1 = 1;pm1 = 1;m12 = 1;
for i = 1:(key1*7)
    tem(m:7) = key2(i);
    a1(m,:) = logical(tem);
    m = m + 1;
    enc_data = encode(logical(h2),n,4,'hamming/binary');
    tem1(m1:7) = enc_data(i);
    a2(m1,:) = tem1;
    m1 = m1 + 1; 
    Encdmsg = xor(a1(i,:),a2(i,:));
    a3(m12,:) = Encdmsg;
    m12 = m12 + 1; 
end
% figure,imshow(a3);