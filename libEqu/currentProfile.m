function u = currentProfile(z, v, zRange)
    u = zeros(size(z));
    u(z<=zRange(1)) = (v(1)-v(2))/(zRange(1)-zRange(2)) * (z(z<=zRange(1))- zRange(1)) + v(1);
end