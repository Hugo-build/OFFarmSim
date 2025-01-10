function D = dirSpread(Angle, n)

    D = zeros(size(Angle));
    for iAng = 1:length(Angle)
        if abs(Angle(iAng)) <= pi/2
           D(iAng) = 1/sqrt(pi)*gamma(1+n/2)/ gamma(1/2+n/2) * cos(Angle(iAng))^n;
        end
    end
end