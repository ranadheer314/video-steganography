function data = retrivel(target)
%  target=imread('stego.bmp');
        n=size(target);
txtsz=target(n(1),n(2),1);% Text Size
        width=target(n(1),n(2),2);% Image's Width
 
        i=1;j=1;k=1;
while k<=txtsz
 
        r1=target(i,j,1);
        r2=target(i,j,2);
        r3=target(i,j,3);
 
        data(k)=findtext(r1,r2,r3);
 
if(i<width)
             i=i+1;
else
            i=1;
            j=j+1;
end
            k=k+1;
end
end
%         fid = fopen('secret.txt','wb');


