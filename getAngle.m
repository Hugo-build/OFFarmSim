function ang = getAngle(point1, point2)
    vec_p1p2 = point1-point2;
    ang = acos(vec_p1p2(1,:)/norm(vec_p1p2,1)); 
end