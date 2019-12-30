clc
close all


img0 = imread("m0.jpg");
img1 = imread("m1.jpg");
img2 = imread("m2.jpg");
img3 = imread("m3.jpg");
img4 = imread("m4.jpg");
img5 = imread("m5.jpg");

img01 = findMosic(img0,img1);
img02 = findMosic(img01,img2);
img03 = findMosic(img02,img3);
img04 = findMosic(img03,img4);
img05 = findMosic(img04,img5);

function newImg = findMosic(img1,img2)

img1_corner = findCornerPoints(img1) ;
img2_corner = findCornerPoints(img2) ;

figure,imshow(img1);
impixelinfo();
[x1, y1,~] = impixel;

img1_corrPts = findCorrPoints(x1,y1);

figure,imshow(img2);
impixelinfo();
[x2, y2, ~] = impixel;

img2_corrPts = findCorrPoints(x2,y2);

h = findHmatrix(img2_corrPts,img1_corrPts);
hi = inv(h);
newcorner_pts = findNewCornerPoints(h,img2_corner);

xmax =  max(max(newcorner_pts(:,1)),max(img1_corner(:,1)));
xmin =  min(min(newcorner_pts(:,1)),min(img1_corner(:,1)));
ymax =  max(max(newcorner_pts(:,2)),max(img1_corner(:,2)));
ymin =  min(min(newcorner_pts(:,2)),min(img1_corner(:,2)));

if xmin <= 0
    xoffset = ceil(abs(xmin));
else
    xoffset = 0 ;
end

if ymin <= 0
    yoffset = ceil(abs(ymin));
else
    yoffset = 0 ;
end

newH = ymax+yoffset ;
newW = xmax+xoffset ;

newImg = zeros(ceil(newW),ceil(newH));
newImg = uint8(newImg);
[rows,cols,~] = size(img1);

for i = 1:rows
    for j = 1:cols
        newImg(i+xoffset,j+yoffset,1) = img1(i,j,1) ;
        newImg(i+xoffset,j+yoffset,2) = img1(i,j,2) ;
        newImg(i+xoffset,j+yoffset,3) = img1(i,j,3);
    end
end
figure,imshow(uint8(newImg));    

[rows2,cols2,~] = size(img2);

for i = 1 : newW
    for j = 1 : newH
        if newImg(i,j) == 0
            corr = hi*[i-xoffset;j-yoffset;1];
            xcoor = corr(1,1)/corr(3,1);
            ycoor = corr(2,1)/corr(3,1);
            xcoor = round(xcoor);
            ycoor = round(ycoor);
            
            if xcoor <= rows2 && xcoor >=1 && ycoor <= cols2 && ycoor >=1
                newImg(i,j,1) = img2(xcoor,ycoor,1);
                newImg(i,j,2) = img2(xcoor,ycoor,2);
                newImg(i,j,3) = img2(xcoor,ycoor,3);
            end
        end
    end
end

figure,imshow(uint8(newImg));
end

function n = findNewCornerPoints(a,b)
    n = zeros(4,2) ;
    for i = 1: 4
        v = b(i,:) ;
        s = [v,1] ;
        s = s' ;
        p = a*s ;
        n(i,:) = p(1:2,1);
    end
end

function a = findHmatrix(corrPts1,corrPts2)
         h = zeros(8,9);
         for i = 1:4
             h(2*i-1,:) = [corrPts1(i,1),corrPts1(i,2),1,0,0,0,-corrPts2(i,1)*corrPts1(i,1),-corrPts2(i,1)*corrPts1(i,2),-corrPts2(i,1)] ;
             h(2*i,:)   = [0,0,0,corrPts1(i,1),corrPts1(i,2),1,-corrPts2(i,2)*corrPts1(i,1),-corrPts2(i,2)*corrPts1(i,2),-corrPts2(i,2)] ;
         end
         
         [~,~,v] = svd(h);
         
         a = zeros(3,3) ;
         k = 1 ;
         for i = 1:3
             for j = 1:3
                 a(i,j) = v(k,9);
                 k=k+1;
             end
         end
         
        for i = 1:3
             for j = 1:3
                 a(i,j) = a(i,j)/a(3,3);
                 
             end
         end
        
         
end


function b = findCorrPoints(p,q)
         
         b = zeros(4,2);
         
         for i = 1:4
             b(i,2) = p(i);
             b(i,1) = q(i);
         end
end


function a = findCornerPoints(image)
    
    [rows,cols,~]= size(image) ;
    a = ones(4,2);
    
    a(2,1) = rows ;
    a(3,2) = cols ;
    a(4,1) = rows ;
    a(4,2) = cols ;
    
end    
    
    
