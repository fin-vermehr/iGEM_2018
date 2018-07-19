function distance = EuclideanNorm2D(P1, P2)
x1 = P1(1);
y1 = P1(2);
x2 = P2(1);
y2 = P2(2);
distance = sqrt((x2-x1)^2+(y2-y1)^2);
end
